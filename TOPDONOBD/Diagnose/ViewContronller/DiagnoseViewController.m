//
//  DiagnoseViewController.m
//  OBD
//
//  Created by 何可人 on 2021/8/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "DiagnoseViewController.h"
#import "ErrorCodeListViewController.h"
#import "ErrorCodeModel.h"
#import "FMDB.h"

@interface DiagnoseViewController ()
{
    UIButton * _clearBtn;
    UIButton * _diagnoseBtn;
    int _codeTime;
}

@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) NSMutableArray * allCodeArr;
@end

@implementation DiagnoseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"诊断";
    
    [self creatUI];
}

#pragma mark 创建UI
- (void)creatUI{
    NSArray * arr = @[@"动力系统",@"底盘系统",@"车身系统",@"信号系统"];
    
    for (int i = 0; i < arr.count; i ++) {
        
        UIButton * btn = ({
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.tag = 100 + i;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.frame = CGRectMake(0, NavigationHeight + 40 * i, IphoneWidth, 40);
//            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:HWhiteColor forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
            btn;
        });
        [self.view addSubview:btn];
        
        UILabel * btnLab = ({
            UILabel * label = [[UILabel alloc] init];
            label.tag = 200 + i;
            label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
            label.frame = CGRectMake(IphoneWidth - 60, 5, 30, 30);
            label.text = [NSString stringWithFormat:@"100"];
            label.textColor = HWhiteColor;
            label.layer.cornerRadius = label.frame.size.height / 2;
            label.clipsToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        btnLab.hidden = YES;
        [btn addSubview:btnLab];
        
        float line_x = 20;
        
        if (i == arr.count - 1) {
            line_x = 0;
        }
        
        if (i == 0) {
            UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, NavigationHeight, IphoneWidth, 1)];
            lineView.backgroundColor = HLightGrayColor;
            [self.view addSubview:lineView];
        }
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(line_x, NavigationHeight + 40 * (i + 1), IphoneWidth, 1)];
        lineView.backgroundColor = HLightGrayColor;
        [self.view addSubview:lineView];
    }
    
    UIButton * diagnoseBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, NavigationHeight + 40 * 5, 120, 40);
        btn.center = CGPointMake(IphoneWidth / 2, btn.center.y);
        btn.backgroundColor = HBlueColor;
        [btn addTarget:self action:@selector(diagnoseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"开始诊断" forState:UIControlStateNormal];
        [btn setTitleColor:HWhiteColor forState:UIControlStateNormal];
        btn.layer.cornerRadius = 10;
        btn;
    });
    _diagnoseBtn = diagnoseBtn;
    [self.view addSubview:diagnoseBtn];
    
    UIButton * clearBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, NavigationHeight + 40 * 7, 120, 40);
        btn.center = CGPointMake(IphoneWidth / 2, btn.center.y);
        btn.backgroundColor = HBlueColor;
        [btn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"清除错误码" forState:UIControlStateNormal];
        [btn setTitleColor:HWhiteColor forState:UIControlStateNormal];
        btn.layer.cornerRadius = 10;
        btn;
    });
    _clearBtn = clearBtn;
    clearBtn.hidden = YES;
    [self.view addSubview:clearBtn];
}

#pragma mark 更新错误码按钮状态
- (void)updateBtnLab{
    for (int i = 0; i < 4; i ++) {
        NSArray * arr = self.dataArr[i];
        
        UILabel * btnLab = [self.view viewWithTag:200 + i];
        
        if (arr.count) {
            btnLab.hidden = NO;
            btnLab.text = [NSString stringWithFormat:@"%lu", (unsigned long)arr.count];
        }else{
            btnLab.hidden = YES;
        }
    }
}

#pragma mark - 故障码点击
- (void)btnClick:(UIButton *)btn{
  
    int index = (int)btn.tag - 100;
    
    if ([self.dataArr[index] count]) {
        NSArray * arr = @[@"动力系统",@"底盘系统",@"车身系统",@"信号系统"];
        ErrorCodeListViewController * vc = [[ErrorCodeListViewController alloc] init];
        vc.listArr = self.dataArr[index];
        vc.navigationItem.title = arr[index];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark 开始诊断按钮点击
- (void)diagnoseBtnClick{

    [SVProgressHUD showWithStatus:@"正在获取故障码"];
    
    _codeTime = 0;
    
    [self clearData];

    [self updateBtnLab];
    
    [self beginReadCode];
}

- (void)clearData{
    [_allCodeArr removeAllObjects];
    
    _dataArr = nil;
}

#pragma mark 开始诊断
- (void)beginReadCode{
    if (!HMBLECenterHandle.sharedHMBLECenterHandle.isConnect) {
        [SVProgressHUD showErrorWithStatus:@"蓝牙未连接"];
        return;
    }
    
    NSArray * arr = @[@"03",@"07"];
    
    if (_codeTime < arr.count) {
        ListModel * listMod = [[ListModel alloc] init];
        listMod.service = arr[_codeTime];
        listMod.PID = @"";
        self.listMod = listMod;
        
        [self.bleDataManage sendInfoWithListModel:listMod];
        
        _codeTime ++;
    }else{
        //诊断完成
        BOOL isCode = NO;
        
        for (NSArray * arr in self.dataArr) {
            if (arr.count) {
                isCode = YES;
                break;
            }
        }
        
        if (isCode) {
            [SVProgressHUD showErrorWithStatus:@"有故障"];
            
            _clearBtn.hidden = NO;
            
            [self updateBtnLab];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"无故障"];
        }
        
        [_diagnoseBtn setTitle:@"重新诊断" forState:UIControlStateNormal];
    }
}

#pragma mark 清除故障码点击
- (void)clearBtnClick{
    ListModel * listMod = [[ListModel alloc] init];
    listMod.service = @"04";
    listMod.PID = @"";
    self.listMod = listMod;
    
    [self.bleDataManage sendInfoWithListModel:listMod];
    
    [self clearData];
    
    [self updateBtnLab];
    
    _clearBtn.hidden = YES;
    
    [_diagnoseBtn setTitle:@"开始诊断" forState:UIControlStateNormal];
    
    [SVProgressHUD showWithStatus:@"正在清除故障码"];
}

#pragma mark - 接收消息
- (void)HBLEDataManageReceivedInfo:(NSString *)info{
    
    if ([self.listMod.service isEqualToString:@"04"]) {
        [SVProgressHUD showSuccessWithStatus:@"清除完成"];
        return;
    }
    
    NSArray * errorArr = @[@"UNABLETOCONNECT", @"NODATA"];
    
    BOOL isError = NO;
    
    for (NSString * errorStr in errorArr) {
        if ([info containsString:errorStr]) {
            isError = YES;
            break;
        }
    }
    
    if (!isError) {
        [self toDealWithCodeInfo:info];
    }
    
    [self beginReadCode];
}

#pragma mark 处理错误码信息
- (void)toDealWithCodeInfo:(NSString *)info{
    //找到起始位置
    NSRange range = [info rangeOfString:[NSString stringWithFormat:@"4%@", [self.listMod.service substringWithRange:NSMakeRange(1, 1)]]];
    
    if (range.length == 0){
        return;
    }
    
    info = [info substringFromIndex:range.location];
    
    //分割字符串再合并
    NSArray * arr = [info componentsSeparatedByString:@":"];
    
    NSMutableString * allStr = [[NSMutableString alloc] init];
    
    for (NSString * str in arr) {
        if (str.length > 1) {
            [allStr appendString:[str substringToIndex:str.length - 1]];
        }
    }
    
    if (allStr.length < 4) {
        return;
    }
    
    //重新划分字符串
    int allCodeNub = 0;
    
    NSArray * codeBigArr = @[@"P",@"C",@"B",@"U"];
    
    for (int i = 0; i < allStr.length / 4; i ++) {
        int nub = 4;
        
        if (i * 4 + nub > allStr.length) {
            nub = (int)allStr.length - i * 4;
        }
        
        NSString * codeStr = [allStr substringWithRange:NSMakeRange(i * 4, nub)];
        
        if (i == 0) {
            NSString * allCodeNubStr = [codeStr substringFromIndex:2];
            allCodeNub = (int)strtoul(allCodeNubStr.UTF8String, 0, 16);
        }else if (i < allCodeNub && nub == 4){
            if ([codeStr isEqualToString:@"0000"]) {
                continue;
            }
            
            if ([self.allCodeArr containsObject:codeStr]) {
                continue;
            }
            
            [self.allCodeArr addObject:codeStr];
            
            ErrorCodeModel * mod = [self getCodeModelWithCodeStr:codeStr];
            
            NSString * codeBigStr = [mod.code substringToIndex:1];
            
            if ([codeBigArr containsObject:codeBigStr]) {
                NSInteger index = [codeBigArr indexOfObject:codeBigStr];
                
                [self.dataArr[index] addObject:mod];
            }
        }
    }
    
}

#pragma mark - 错误码转为mod
- (ErrorCodeModel *)getCodeModelWithCodeStr:(NSString *)codeStr{
    NSArray * codeBigArr = @[@"P",@"C",@"B",@"U"];
    
    NSString * codeBigStr = [codeStr substringToIndex:1];
    
    NSString * codeSmallStr = [codeStr substringFromIndex:1];
    
    int codeNub = (int)strtoul(codeBigStr.UTF8String, 0, 16);
    
    int codeBigNub = codeNub / 4;
    
    int codeSmallNub = codeNub % 4;
    
    NSString * code = [NSString stringWithFormat:@"%@%d%@", codeBigArr[codeBigNub], codeSmallNub, codeSmallStr];
    
    ErrorCodeModel * mod = [[ErrorCodeModel alloc] init];
    mod.code = code;
    mod.describe = [self findCarErrorCodeFromeDBWithCode:code];
    
    return mod;
}

#pragma mark 数据库获取错误码信息
- (NSString *)findCarErrorCodeFromeDBWithCode:(NSString *)code{
    NSString * dbPath = [[NSBundle mainBundle] pathForResource:@"CarErrorCode" ofType:@"db"];
    
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
   
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * sql = [NSString stringWithFormat:@"select * from trouble_cn where code = '%@'", code];
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet) {
            while ([resultSet next]) {
                NSString * trouble_detail = [resultSet stringForColumn:@"trouble_detail"];
                [arr addObject:trouble_detail];
            }
        }else{
            NSLog(@"数据库查询错误");
        }
    }];
    
    NSString * codeStr = @"未知错误码";
    
    if (arr.count) {
        codeStr = arr[0];
    }
    
    return codeStr;
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 4; i ++) {
            [_dataArr addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    return _dataArr;
}

- (NSMutableArray *)allCodeArr{
    if (!_allCodeArr) {
        _allCodeArr = [[NSMutableArray alloc] init];
    }
    
    return _allCodeArr;
}

@end
