//
//  UILabel+HLabel.m
//  OBD
//
//  Created by 何可人 on 2021/3/18.
//

#import "UILabel+HLabel.h"

@implementation UILabel (HLabel)
+ (UILabel *)createBtnFrame:(CGRect)frame title:(NSString *)title fontName:(NSString *)fontName fontSize:(float)fontSize textColor:(UIColor *)textColor
{
    UILabel * titleLab = [[UILabel alloc] init];
    titleLab.frame = frame;
    titleLab.text = title;
    titleLab.font = [UIFont systemFontOfSize:fontSize];
    titleLab.textColor = textColor;
    
    return titleLab;
}
@end
