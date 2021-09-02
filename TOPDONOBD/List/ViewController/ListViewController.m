//
//  ListViewController.m
//  OBD
//
//  Created by 何可人 on 2021/6/22.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "ListViewController.h"
#import "ListModel.h"
#import "ChartViewController.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIBarButtonItem * _BLEBtn;
    int _getValueNub;//指令编号
}
@property (nonatomic, strong) NSArray * listArr; //列表数据
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ListViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.vcType == ListVCType_command) {
        [self getValueData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _getValueNub = 0;
    
    if (self.vcType == ListVCType_BLE) {
        self.navigationItem.title = @"蓝牙连接";
        [HMBLECenterHandle.sharedHMBLECenterHandle scan];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral) name:HDidConnectPeripheral object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiscoverPeripheral) name:HDidDiscoverPeripheral object:nil];
        
    }else{
        self.navigationItem.title = @"实时监控";
    }
    
    [self creatTableView];
    
    [self getListData];
}

- (void)willEnterForegroundNotification{
    if (self.vcType == ListVCType_command) {
        [self getValueData];
    }
}

- (void)didConnectPeripheral{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didDiscoverPeripheral{
    [self.tableView reloadData];
}

- (void)didDisconnectPeripheral{
    if (self.vcType == ListVCType_command) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.tableView reloadData];
    }
}

- (void)getListData{
    if (self.vcType == ListVCType_BLE) {
        self.listArr = HMBLECenterHandle.sharedHMBLECenterHandle.peripheralArr;
    }else{
        self.listArr = [self getListPlistData];
    }
    
    [self.tableView reloadData];
}

- (void)creatTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 0.01f;
    tableView.estimatedSectionHeaderHeight = 0.01f;
    tableView.estimatedSectionFooterHeight = 0.01f;
    tableView.bounces = NO;
    [tableView setSeparatorColor:HLightGrayColor];
    [self.view insertSubview:tableView atIndex:0];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NavigationHeight, 0, iPhoneX_D, 0));
    }];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentify"];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify =@"cellIdentify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel * nubLab = [cell.contentView viewWithTag:100];
    
    if (!nubLab) {
        nubLab = ({
            UILabel * label = [[UILabel alloc] init];
            label.tag = 100;
            label.text = [NSString stringWithFormat:@" "];
            label.textColor = HBlueColor;
            label.textAlignment = NSTextAlignmentRight;
            label;
        });
        [cell.contentView addSubview:nubLab];
        
        [nubLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 20));
        }];
    }
    
    if (indexPath.row < self.listArr.count) {
        
        if (self.vcType == ListVCType_command) {
            ListModel * mod = self.listArr[indexPath.row];
            
            cell.textLabel.text = mod.describe;
            
            if (mod.value.length) {
                nubLab.text = mod.value;
            }else{
                nubLab.text = @" ";
            }
        }else{
            CBPeripheral * peripheral = self.listArr[indexPath.row];
            
            NSString * name = peripheral.name;
            
            cell.textLabel.text = name;
        }
        
        cell.textLabel.textColor = HWhiteColor;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.vcType == ListVCType_command) {
        
        if (!HBLEManager.isConnect) {
            [SVProgressHUD showInfoWithStatus:@"请连接蓝牙"];
            return;
        }
        
        ListModel * mod = self.listArr[indexPath.row];
        
        if (mod.service.length > 0) {
            InfoBaseViewController * vc;
            vc = [[ChartViewController alloc] init];
//            if ([mod.service isEqualToString:@"01"]) {
//                vc = [[ChartViewController alloc] init];
//            }else{
//                vc = [[SendInfoViewController alloc] init];
//            }
            vc.listMod = mod;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        if (![SVProgressHUD isVisible]) {
            [SVProgressHUD showWithStatus:@"正在连接中，请稍等..."];
            
            CBPeripheral * peripheral = self.listArr[indexPath.row];
            
            [HMBLECenterHandle.sharedHMBLECenterHandle ConnectedDevicesWithPeripheral:peripheral];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)getValueData{
    ListModel * mod = self.listArr[_getValueNub];
    
    [self.bleDataManage sendInfoWithListModel:mod];
}

- (void)HBLEDataManageReceivedInfo:(NSString *)info{
    NSArray * errorArr = @[@"UNABLETOCONNECT", @"NODATA"];
    
    BOOL isError = NO;
    
    for (NSString * errorStr in errorArr) {
        if ([info containsString:errorStr]) {
            isError = YES;
            break;
        }
    }
    
    if (!isError) {
        ListModel * mod = self.listArr[_getValueNub];
        
        NSString * sendStr = [NSString stringWithFormat:@"%@%@\r", mod.service,mod.PID];
        
        if ([sendStr isEqualToString:@"ATRV\r"]) {
            float value = [[info substringToIndex:info.length - 1] floatValue];
            
            if (value > 0 && value < 24) {
                mod.value = info;
            }
        }else{
            NSRange range = [info rangeOfString:[NSString stringWithFormat:@"41%@", mod.PID]];
            
            if (range.length && info.length >= range.location + range.length + [mod.bytes intValue] * 2) {
                info = [info substringWithRange:NSMakeRange(range.location + range.length, [mod.bytes intValue] * 2)];
                
                float value = [self getInfoConvertedValueWithPID:mod.PID info:info];
                
                mod.value = [NSString stringWithFormat:@"%.0f%@", value, mod.unit];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_getValueNub inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    _getValueNub ++;
    
    if (_getValueNub >= self.listArr.count) {
        _getValueNub = 0;
    }
    
    [self getValueData];
}

- (void)dealloc{
    if (self.vcType == ListVCType_BLE && HMBLECenterHandle.sharedHMBLECenterHandle.isConnect) {
        [HMBLECenterHandle.sharedHMBLECenterHandle stop];
    }
}

@end
