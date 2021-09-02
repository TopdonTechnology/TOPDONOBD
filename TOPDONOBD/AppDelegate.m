//
//  AppDelegate.m
//  OBD
//
//  Created by 何可人 on 2021/6/10.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ListViewController.h"

@interface AppDelegate ()<LMSHManagerDelegata>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [LMSHManager initWithDelegata:self Language:nil];
    
    [LMSHManager setLogEnable:YES];
    
    [HMBLECenterHandle sharedHMBLECenterHandle];//蓝牙
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    
    [self initHomeVC];
    
    return YES;
}

#pragma mark - homeVC初始化
- (void)initHomeVC{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = HWhiteColor;   //设置通用背景颜色
    
    HomeViewController * vc = [[HomeViewController alloc] init];
//    ListViewController * vc = [[ListViewController alloc] init];
    
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBarHidden = YES;
    self.window.rootViewController = nvc;
    
    [self.window makeKeyAndVisible];
    
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}


/// 所有接口的回调
/// @param response 回应对象
/// @param responseObject 回应内容
/// @param error 错误
- (void)LMSHManagerGetAllURLCallbackWithResponse:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error{
    if (responseObject) {
        int result = [responseObject[@"code"] intValue];
        
        if (result != 0 && ![[responseObject allKeys] containsObject:@"access_token"]) {
            if ([[responseObject allKeys] containsObject:@"msg"]) {
                [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
            }else{
                [SVProgressHUD showErrorWithStatus:@"服务器错误"];
            }
        }
    }else{
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

@end
