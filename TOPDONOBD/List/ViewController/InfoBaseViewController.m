//
//  InfoBaseViewController.m
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "InfoBaseViewController.h"

@interface InfoBaseViewController ()

@end

@implementation InfoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral) name:HDidDisconnectPeripheral object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)willEnterForegroundNotification{
    NSLog(@"将要进入前台");
    
}

- (void)didDisconnectPeripheral{
    [SVProgressHUD showErrorWithStatus:@"蓝牙已断开"];
    
    [self backClick];
}

- (HBLEDataManage *)bleDataManage{
    if (!_bleDataManage) {
        _bleDataManage = [[HBLEDataManage alloc] init];
    }
    _bleDataManage.delegata = self;
    
    return _bleDataManage;
}

- (float)getInfoConvertedValueWithPID:(NSString *)PID info:(NSString *)info{
    NSArray * infoArr = [self dealData:info WithDigits:2];
    
    float value = 0;
    
    if (infoArr.count == 0) {
        return value;
    }
    
    value = [infoArr[0] intValue];
    
    if ([PID isEqualToString:@"05"] || [PID isEqualToString:@"0F"]) {
        value = value - 40;
    }else if ([PID isEqualToString:@"04"]) {
        value = value / 2.55;
    }else if ([PID isEqualToString:@"0A"]) {
        value = 3 * value;
    }else if ([PID isEqualToString:@"0C"]) {
        
        if (infoArr.count < 2) {
            return 0;
        }
        
        float value2 = [infoArr[1] intValue];
        
        value = (256 * value + value2) / 4.0;
        
    }else if ([PID isEqualToString:@"11"]) {
        value = value * 100 / 255.0;
    }
    
    return [[NSString stringWithFormat:@"%.2f", value] floatValue];
}

#pragma mark 16进制转10进制数组
- (NSArray *)dealData:(NSString *)hexString WithDigits:(int)digits{
    //ff01取8位，别的取4位
    
    NSMutableArray * marr = @[].mutableCopy;
    
    for (int i = 0; i < hexString.length / digits; i ++) {
        //取n位数
        NSString * str = [hexString substringWithRange:NSMakeRange(i * digits, digits)];
        
        //前后交换
        NSMutableString * mstr = @"".mutableCopy;
        for (int i = 0; i < digits / 2; i ++) {
            [mstr appendString:[str substringWithRange:NSMakeRange(digits - (i + 1) * 2, 2)]];
        }
        
        //16进制转10进制
        str = [NSString stringWithFormat:@"%lu",strtoul([mstr UTF8String],0,16)];
        
        [marr addObject:@(str.intValue)];
    }
    
    return marr;
}

- (NSMutableArray *)getListPlistData{
    NSMutableArray * mArr = [[NSMutableArray alloc] init];
    
    NSArray * plistArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OBDList.plist" ofType:nil]];
    
    for (NSDictionary * dic in plistArr) {
        ListModel * mod = [[ListModel alloc] initWithDictionary:dic error:nil];
        [mArr addObject:mod];
    }
    
    return mArr;
}


@end
