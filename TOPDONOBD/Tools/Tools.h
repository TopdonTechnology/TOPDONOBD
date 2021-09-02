//
//  Tools.h
//  OBD
//
//  Created by 何可人 on 2021/8/25.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject
///获取文字长度
+ (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)textHeight fontSize:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
