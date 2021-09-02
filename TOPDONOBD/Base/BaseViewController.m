//
//  BaseViewController.m
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![self isKindOfClass:NSClassFromString(@"HomeViewController")]) { self.navigationController.navigationBarHidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if ([self isKindOfClass:NSClassFromString(@"HomeViewController")]) { self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:HWhiteColor}; // title颜色
    
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    
    self.navigationItem.backBarButtonItem = backBtn;
    
    [self.navigationItem.backBarButtonItem setTintColor:HWhiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral) name:HDidDisconnectPeripheral object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didDisconnectPeripheral{
//    [self backClick];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"%@--dealloc", self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
