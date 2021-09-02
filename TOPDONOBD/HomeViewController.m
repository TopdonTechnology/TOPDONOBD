//
//  HomeViewController.m
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "HomeViewController.h"
#import "ListViewController.h"
#import "DiagnoseViewController.h"
#import "DashboardViewController.h"
#import "LoginViewController.h"
#import <SDCycleScrollView.h>
@interface HomeViewController ()<HBLECenterDelegate,SDCycleScrollViewDelegate>
{
    UIButton * _bleBtn;
    NSTimer * _bleTimer;
    int _coommandNub;
}

@end

@implementation HomeViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIButton * btn = [self.view viewWithTag:103];
    
    if ([LMSHManager userIsLogin]) {
        [btn setTitle:@"已登录" forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"登录" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatUI];
    
    [self addObserver];
    
    _bleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showBLE) userInfo:nil repeats:YES];
}

- (void)creatUI{
    UIImageView * logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, StatusBarHeight + 10, IphoneWidth, 30)];
    logoImgView.image = [UIImage imageNamed:@"logo"];
    logoImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoImgView];
    
    UIButton * bleBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(IphoneWidth - 60, StatusBarHeight + 10, 30, 30);
        [btn setImage:[UIImage imageNamed:@"device_scan_ble"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(bleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    _bleBtn = bleBtn;
    [self.view addSubview:bleBtn];
    
    // 本地加载图片的轮播器
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, StatusBarHeight + 60, IphoneWidth, 150) imageNamesGroup:@[[UIImage imageNamed:@"banner1"],[UIImage imageNamed:@"banner2"],[UIImage imageNamed:@"banner3"]]];
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    cycleScrollView.delegate = self;
    [self.view addSubview:cycleScrollView];
    
    NSArray * titleArr = @[@"诊断",@"仪表盘",@"实时监控",@"登录"];
    
    float btn_w = (IphoneWidth - 30 * 2 - 20) / 2.0;
    
    float btn_h = (IphoneHeight - StatusBarHeight - 270 - iPhoneX_D) / 2.0;
    
    for (int i = 0; i < titleArr.count; i ++) {
        
        float btn_x = IphoneWidth / 2 + 10;
        float btn_y = StatusBarHeight + 230 + (btn_h + 20) * (int)(i / 2);
        
        if (i % 2 == 0) {
            btn_x = IphoneWidth / 2 - 10 - btn_w;
        }
        
        UIButton * homeBtn = ({
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100 + i;
            btn.backgroundColor = [HLightGrayColor colorWithAlphaComponent:0.3];
            btn.frame = CGRectMake(btn_x, btn_y, btn_w, btn_h);
            [btn addTarget:self action:@selector(homeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:titleArr[i] forState:UIControlStateNormal];
            btn.layer.cornerRadius = 10;
            btn;
        });
        
        [self.view addSubview:homeBtn];
    }
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral) name:HDidConnectPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiscoverCharacteristics) name:HDidDiscoverCharacteristics object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral) name:HDidDisconnectPeripheral object:nil];
}

- (void)didConnectPeripheral{
    [SVProgressHUD showSuccessWithStatus:@"蓝牙连接成功"];
    
    if (_bleTimer) {
        [_bleTimer invalidate];
        _bleTimer = nil;
    }
    
    [_bleBtn setImage:[UIImage imageNamed:@"device_scan_ble"] forState:UIControlStateNormal];
}

- (void)didDiscoverCharacteristics{
    //重置
    _coommandNub = 0;
    
    [self OBDInit];
}

- (void)didDisconnectPeripheral{
    [SVProgressHUD showErrorWithStatus:@"蓝牙已断开"];
    
    if (!_bleTimer) {
        _bleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showBLE) userInfo:nil repeats:YES];
    }
}

- (void)OBDInit{
    
    if (!HBLEManager.isConnect) {
        [SVProgressHUD showErrorWithStatus:@"初始化失败，请重新连接蓝牙"];
        return;
    }
    
    [SVProgressHUD showProgress:_coommandNub / 8.0 status:@"正在初始化..."];
    
    NSArray * initArr = @[@"ATD\r",@"ATZ\r",@"ATE0\r",@"ATL0\r",@"ATS0\r",@"ATH0\r",@"ATSP0\r",@"0100\r"];
    
    [[HMBLECenterHandle sharedHMBLECenterHandle] sendDataString:initArr[_coommandNub] WithUUID:@"FFF2"];
    
    [HMBLECenterHandle sharedHMBLECenterHandle].delegate = self;
}

- (void)didUpdateValueForUUID:(NSString *)UUID withHexString:(NSString *)hexString{
    static NSString * receivedStr = @"";
    
    receivedStr = [receivedStr stringByAppendingString:hexString];
    
    NSString * lastStr = [receivedStr substringFromIndex:receivedStr.length - 1];
    
    if ([lastStr isEqualToString:@">"]) {
        receivedStr = [receivedStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        receivedStr = [receivedStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        receivedStr = [receivedStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        receivedStr = [receivedStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (_coommandNub == 7) {
            if ([receivedStr containsString:@"4100"]) {
                [SVProgressHUD showSuccessWithStatus:@"初始化完成"];
            }else{
                [SVProgressHUD showErrorWithStatus:@"初始化失败，请重新连接蓝牙"];
            }
        }else{
            _coommandNub ++;
            [self OBDInit];
        }
    }
    
}

- (void)homeBtnClick:(UIButton *)btn{
    int i = (int)btn.tag - 100;
    
    if (i == 3) {
        LoginViewController * vc = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (!HBLEManager.isConnect) {
        [SVProgressHUD showInfoWithStatus:@"请连接蓝牙"];
        return;
    }
    
    switch (i) {
        case 0:
        {
            DiagnoseViewController * vc = [[DiagnoseViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            DashboardViewController * vc = [[DashboardViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            ListViewController * vc = [[ListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    

}

/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    switch (index) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.topdon.com"] options:@{} completionHandler:nil];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.topdon.com/collections/diy-code-reader"] options:@{} completionHandler:nil];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.topdon.com/products/phoenix-pro"] options:@{} completionHandler:nil];
            break;
            
        default:
            break;
    }
}

- (void)bleBtnClick{
    ListViewController * vc = [[ListViewController alloc] init];
    vc.vcType = ListVCType_BLE;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBLE{
    _bleBtn.selected = !_bleBtn.isSelected;
    
    if (_bleBtn.isSelected) {
        [_bleBtn setImage:nil forState:UIControlStateNormal];
    }else{
        [_bleBtn setImage:[UIImage imageNamed:@"device_scan_ble"] forState:UIControlStateNormal];
    }
}

@end
