//
//  HBLEDataManage.m
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "HBLEDataManage.h"
#import "HMBLECenterHandle.h"

@interface HBLEDataManage ()<HBLECenterDelegate>
{
    NSString * _receivedStr;
}
@end

@implementation HBLEDataManage

- (instancetype)init{
    self = [super init];
    if (self) {
        HMBLECenterHandle.sharedHMBLECenterHandle.delegate = self;
    }
    return self;
}

- (void)setDelegata:(id<HBLEDataManageDelegate>)delegata{
    _delegata = delegata;
    HMBLECenterHandle.sharedHMBLECenterHandle.delegate = self;
}

- (void)sendInfoWithListModel:(ListModel *)mod{
    _receivedStr = @"";
    
    NSString * PIDStr = mod.PID;
    
    NSString * sendStr = [NSString stringWithFormat:@"%@%@\r", mod.service,PIDStr];
    
    [[HMBLECenterHandle sharedHMBLECenterHandle] sendDataString:sendStr WithUUID:@"FFF2"];
}

- (void)didUpdateValueForUUID:(NSString *)UUID withHexString:(NSString *)hexString{
    _receivedStr = [_receivedStr stringByAppendingString:hexString];
    
    NSString * lastStr = [_receivedStr substringFromIndex:_receivedStr.length - 1];
    
    if ([lastStr isEqualToString:@">"]) {
        _receivedStr = [_receivedStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        _receivedStr = [_receivedStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        _receivedStr = [_receivedStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        _receivedStr = [_receivedStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([self.delegata respondsToSelector:@selector(HBLEDataManageReceivedInfo:)]) {
            [self.delegata HBLEDataManageReceivedInfo:_receivedStr];
        }
    }
}

@end
