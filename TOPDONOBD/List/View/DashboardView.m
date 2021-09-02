//
//  DashboardView.m
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "DashboardView.h"

@implementation DashboardView{
    CAShapeLayer * _progressLayer;
    UILabel * _speedLabel;
    UILabel * _contentLabel;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
       
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
//    float width  = self.frame.size.width;
//    float height = self.frame.size.height;
//
//    CGPoint centers = CGPointMake(width / 2, height / 2);
//
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15],NSFontAttributeName,[UIColor colorWithRed:0.62 green:0.84 blue:0.93 alpha:1.0], NSForegroundColorAttributeName, nil];
//
//    [self.listModel.unit drawInRect:CGRectMake(centers.x - 15, centers.y - 20, 60, 20) withAttributes:attributes];
//    [self.listModel.describe drawInRect:CGRectMake(centers.x - 15, centers.y, 60, 20) withAttributes:attributes];
}

- (void)setListModel:(ListModel *)listModel{
    _listModel = listModel;
    
    [self creatView];
}

- (void)creatView{
    float width  = self.frame.size.width;
    float height = self.frame.size.height;
    
    CGPoint centers = CGPointMake(width / 2, height / 2);
    
    //主要解释一下各个参数的意思
    //center  中心点（可以理解为圆心）
    //radius  半径
    //startAngle 起始角度
    //endAngle  结束角度
    //clockwise  是否顺时针
    UIBezierPath *cicrle     = [UIBezierPath bezierPathWithArcCenter:centers
                                                              radius:95
                                                          startAngle:- M_PI - M_PI / 4
                                                            endAngle: M_PI / 4
                                                           clockwise:YES];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth     = 5.f;
    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor   = RgbColor(185,243,110,1).CGColor;
    shapeLayer.path          = cicrle.CGPath;
    [self.layer addSublayer:shapeLayer];
    
    CGFloat perAngle = (M_PI + M_PI / 2) / 50;
    //我们需要计算出每段弧线的起始角度和结束角度
    //这里我们从- M_PI 开始，我们需要理解与明白的是我们画的弧线与内侧弧线是同一个圆心
    for (int i = 0; i< 51; i++) {
        
        CGFloat startAngel = (-M_PI - M_PI / 4 + perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/5;
        
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:centers radius:150 startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        
        if (i % 5 == 0) {
            
            perLayer.strokeColor = [UIColor colorWithRed:0.62 green:0.84 blue:0.93 alpha:1.0].CGColor;
            perLayer.lineWidth   = 10.f;
            
            CGPoint point      = [self calculateTextPositonWithArcCenter:centers Angle:M_PI + M_PI / 4 - perAngle * i];
            
            float value = [self.listModel.max floatValue] - [self.listModel.min floatValue];
            
            if (value > 10000) {
                value = value / 1000;
            }
            
            NSString *tickText = [NSString stringWithFormat:@"%.1f",[self.listModel.min floatValue] + i * value / 50.0];
            
            //默认label的大小14 * 14
            UILabel *text      = [[UILabel alloc] initWithFrame:CGRectMake(point.x - 10, point.y - 10, 20, 20)];
            text.text          = tickText;
            text.font          = [UIFont systemFontOfSize:16];
            text.textColor     = [UIColor colorWithRed:0.54 green:0.78 blue:0.91 alpha:1.0];
            text.textAlignment = NSTextAlignmentCenter;
            [text sizeToFit];
            text.center        = CGPointMake(point.x, point.y);
            [self addSubview:text];
            
        }else{
            perLayer.strokeColor = [UIColor colorWithRed:0.22 green:0.66 blue:0.87 alpha:1.0].CGColor;
            perLayer.lineWidth   = 5;
            
        }
        
        perLayer.path = tickPath.CGPath;
        [self.layer addSublayer:perLayer];
        
        
    }
    
    // 进度的曲线
    UIBezierPath *progressPath  = [UIBezierPath bezierPathWithArcCenter:centers
                                                                 radius:120
                                                             startAngle:- M_PI - M_PI / 4
                                                               endAngle:M_PI / 4
                                                              clockwise:YES];
    CAShapeLayer * progressLayer = [CAShapeLayer layer];
    progressLayer.lineWidth     =  50.f;
    progressLayer.fillColor     = [UIColor clearColor].CGColor;
    progressLayer.strokeColor   =  RgbColor(185,243,110,0.2).CGColor;
    progressLayer.path          = progressPath.CGPath;
    progressLayer.strokeStart   = 0;
    progressLayer.strokeEnd     = 0;
    _progressLayer = progressLayer;
    [self.layer addSublayer:progressLayer];
    
    UILabel *text      = [[UILabel alloc] initWithFrame:self.bounds];
    text.center        = CGPointMake(centers.x, centers.y);
    text.font          = [UIFont systemFontOfSize:40];
    text.textColor     = [UIColor colorWithRed:0.54 green:0.78 blue:0.91 alpha:1.0];
    text.textAlignment = NSTextAlignmentCenter;
    [self addSubview:text];
    _speedLabel = text;
    
    UILabel *contenttext      = [[UILabel alloc] initWithFrame:self.bounds];
    contenttext.center        = CGPointMake(centers.x, centers.y + 40);
    contenttext.font          = [UIFont systemFontOfSize:20];
    contenttext.textColor     = [UIColor colorWithRed:0.54 green:0.78 blue:0.91 alpha:1.0];
    contenttext.textAlignment = NSTextAlignmentCenter;
    [self addSubview:contenttext];
    _contentLabel = contenttext;
}

//- (void)creatView{
//    float width  = self.frame.size.width;
//    float height = self.frame.size.height;
//
//    CGPoint centers = CGPointMake(width / 2, height / 2);
//
//    //主要解释一下各个参数的意思
//    //center  中心点（可以理解为圆心）
//    //radius  半径
//    //startAngle 起始角度
//    //endAngle  结束角度
//    //clockwise  是否顺时针
//    UIBezierPath *cicrle     = [UIBezierPath bezierPathWithArcCenter:centers
//                                                              radius:95
//                                                          startAngle:- M_PI
//                                                            endAngle: 0
//                                                           clockwise:YES];
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.lineWidth     = 5.f;
//    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
//    shapeLayer.strokeColor   = RgbColor(185,243,110,1).CGColor;
//    shapeLayer.path          = cicrle.CGPath;
//    [self.layer addSublayer:shapeLayer];
//
//    CGFloat perAngle = M_PI / 50;
//    //我们需要计算出每段弧线的起始角度和结束角度
//    //这里我们从- M_PI 开始，我们需要理解与明白的是我们画的弧线与内侧弧线是同一个圆心
//    for (int i = 0; i< 51; i++) {
//
//        CGFloat startAngel = (-M_PI + perAngle * i);
//        CGFloat endAngel   = startAngel + perAngle/5;
//
//        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:centers radius:150 startAngle:startAngel endAngle:endAngel clockwise:YES];
//        CAShapeLayer *perLayer = [CAShapeLayer layer];
//
//        if (i % 5 == 0) {
//
//            perLayer.strokeColor = [UIColor colorWithRed:0.62 green:0.84 blue:0.93 alpha:1.0].CGColor;
//            perLayer.lineWidth   = 10.f;
//
//            CGPoint point      = [self calculateTextPositonWithArcCenter:centers Angle:M_PI - perAngle * i];
//
//            float value = [self.listModel.max floatValue] - [self.listModel.min floatValue];
//
//            if (value > 10000) {
//                value = value / 1000;
//            }
//
//            NSString *tickText = [NSString stringWithFormat:@"%.0f",[self.listModel.min floatValue] + i * value / 50.0];
//
//            //默认label的大小14 * 14
//            UILabel *text      = [[UILabel alloc] initWithFrame:CGRectMake(point.x - 10, point.y - 10, 20, 20)];
//            text.text          = tickText;
//            text.font          = [UIFont systemFontOfSize:16];
//            text.textColor     = [UIColor colorWithRed:0.54 green:0.78 blue:0.91 alpha:1.0];
//            text.textAlignment = NSTextAlignmentCenter;
//            [text sizeToFit];
//            text.center        = CGPointMake(point.x, point.y);
//            [self addSubview:text];
//
//        }else{
//            perLayer.strokeColor = [UIColor colorWithRed:0.22 green:0.66 blue:0.87 alpha:1.0].CGColor;
//            perLayer.lineWidth   = 5;
//
//        }
//
//        perLayer.path = tickPath.CGPath;
//        [self.layer addSublayer:perLayer];
//
//
//    }
//
//    // 进度的曲线
//    UIBezierPath *progressPath  = [UIBezierPath bezierPathWithArcCenter:centers
//                                                                 radius:120
//                                                             startAngle:- M_PI
//                                                               endAngle:0
//                                                              clockwise:YES];
//    CAShapeLayer * progressLayer = [CAShapeLayer layer];
//    progressLayer.lineWidth     =  50.f;
//    progressLayer.fillColor     = [UIColor clearColor].CGColor;
//    progressLayer.strokeColor   =  RgbColor(185,243,110,0.2).CGColor;
//    progressLayer.path          = progressPath.CGPath;
//    progressLayer.strokeStart   = 0;
//    progressLayer.strokeEnd     = 0;
//    _progressLayer = progressLayer;
//    [self.layer addSublayer:progressLayer];
//
//    UILabel *text      = [[UILabel alloc] initWithFrame:self.bounds];
//    text.center        = CGPointMake(centers.x, centers.y - 40);
//    text.font          = [UIFont systemFontOfSize:40];
//    text.textColor     = [UIColor colorWithRed:0.54 green:0.78 blue:0.91 alpha:1.0];
//    text.textAlignment = NSTextAlignmentCenter;
//    [self addSubview:text];
//    _speedLabel = text;
//
//    UILabel *contenttext      = [[UILabel alloc] initWithFrame:self.bounds];
//    contenttext.center        = CGPointMake(centers.x, centers.y);
//    contenttext.font          = [UIFont systemFontOfSize:20];
//    contenttext.textColor     = [UIColor colorWithRed:0.54 green:0.78 blue:0.91 alpha:1.0];
//    contenttext.textAlignment = NSTextAlignmentCenter;
//    [self addSubview:contenttext];
//    _contentLabel = contenttext;
//}

//默认计算半径135
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center Angle:(CGFloat)angel
{
    CGFloat x = 125 * cosf(angel);
    CGFloat y = 125 * sinf(angel);
    
    return CGPointMake(center.x + x, center.y - y);
}

//提供一个外部的接口，通过重写setter方法来改变进度
- (void)setValue:(double)value{
    _value = value;
    
    if (_value < 0) {
        _value = -_value;
    }
    
    float progress = (_value - [self.listModel.min floatValue]) / ([self.listModel.max floatValue] - [self.listModel.min floatValue]);
    
    _progressLayer.strokeEnd = progress;
    
    _speedLabel.text = [NSString stringWithFormat:@"%.f%@", value, self.listModel.unit];
    _contentLabel.text = self.listModel.describe;
}
    
//- (void)setProgress:(double)progress
//{
//    _progress = progress;
//    _progressLayer.strokeEnd = _progress;
//    _speedLabel.text = [NSString stringWithFormat:@"%.f%@",_progress * ([self.listModel.max floatValue] - [self.listModel.max floatValue]), self.listModel.unit];
//    _contentLabel.text = self.listModel.describe;
//}

@end
