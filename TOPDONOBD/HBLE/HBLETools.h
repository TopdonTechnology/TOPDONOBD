//
//  HBLETools.h
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBLETools : NSObject

///string转data
+ (NSData *)convertHexStrToData:(NSString *)str;

///10进制转16进制
+ (NSString *)getHexByDecimal:(NSInteger)decimal;

///data转换为十六进制的。
+ (NSString *)hexStringFromData:(NSData *)myD;
@end

NS_ASSUME_NONNULL_END
