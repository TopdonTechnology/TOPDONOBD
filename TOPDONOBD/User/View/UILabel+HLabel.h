//
//  UILabel+HLabel.h
//  OBD
//
//  Created by 何可人 on 2021/3/18.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (HLabel)
+ (UILabel *)createBtnFrame:(CGRect)frame title:(NSString *)title fontName:(NSString *)fontName fontSize:(float)fontSize textColor:(UIColor *)textColor;
@end

NS_ASSUME_NONNULL_END
