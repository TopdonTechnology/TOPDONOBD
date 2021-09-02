//
//  Tools.m
//  OBD
//
//  Created by 何可人 on 2021/8/25.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "Tools.h"

@implementation Tools
///获取文字长度
+ (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)textHeight fontSize:(UIFont *)font{
   NSDictionary *dict = @{NSFontAttributeName:font};
   CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, textHeight) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
   //返回计算出的长
   return rect.size.width + 1;
}
@end
