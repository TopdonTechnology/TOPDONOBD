//
//  ChartViewController.m
//  OBD
//
//  Created by 何可人 on 2021/6/22.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "ChartViewController.h"
#import <AAChartKit/AAGlobalMacro.h>
#import <AAChartKit/AAChartKit.h>

@interface ChartViewController ()
{
    float _resultData;
}
@property (nonatomic, strong) AAChartModel * aaChartModel;
@property (nonatomic, strong) AAChartView  * aaChartView;
@property (nonatomic, strong) NSMutableArray  * dataArr;
@property (nonatomic, strong) NSTimer * showTimer;
@end

@implementation ChartViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if (self.showTimer) {
        [self.showTimer invalidate];
        self.showTimer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.showTimer) {
        self.showTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(chartAddPoint) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.showTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.listMod.describe;
    
    _resultData = 0;
    
    [self drawChart];
    
    [self setupTimer];
}

- (void)willEnterForegroundNotification{
    [self sendInfo];
}

- (void)drawChart{
    CGFloat chartViewWidth  = self.view.frame.size.width;
    CGFloat chartViewHeight = self.view.frame.size.height - NavigationHeight - iPhoneX_D;
    _aaChartView = [[AAChartView alloc]init];
    _aaChartView.isClearBackgroundColor = YES;
    _aaChartView.frame = CGRectMake(0, NavigationHeight, chartViewWidth, chartViewHeight);
    _aaChartView.userInteractionEnabled = NO;
    ////禁用 AAChartView 滚动效果(默认不禁用)
    self.aaChartView.scrollEnabled = NO;
    [self.view addSubview:_aaChartView];
    
    self.aaChartModel= AAObject(AAChartModel)
    .yAxisAllowDecimalsSet(false) //是否允许 y 轴显示小数
    .colorsThemeSet(@[ChartColor])
    .yAxisLabelsStyleSet(AAObject(AAStyle)//y 轴文字样式
                         .colorSet(ChartColor))
    .xAxisLabelsStyleSet(AAObject(AAStyle)//x 轴文字样式
                         .colorSet(ChartColor))
    .chartTypeSet(AAChartTypeSpline)//设置图表的类型
    .subtitleSet([NSString stringWithFormat:@"%@(%@)", self.listMod.describe, self.listMod.unit])//副标题
    .subtitleStyleSet(AAObject(AAStyle)//副标题文字样式
                      .colorSet(ChartColor))
    .yAxisTitleSet(@"")//设置图表 y 轴的单位
    .markerRadiusSet(@0)//折线连接点的半径长度
    .legendEnabledSet(NO)//是否显示图例
    .seriesSet(@[
            AAObject(AASeriesElement)
            .dataSet(@[@0])
                     ])
    ;
    
    AAOptions *aaOptions = self.aaChartModel.aa_toAAOptions;
    //设置刻度线个数
    aaOptions.yAxis.tickAmount = @6;
    
    [_aaChartView aa_drawChartWithChartModel:self.aaChartModel];
    
    [_aaChartView aa_drawChartWithOptions:aaOptions];
    
    [self.dataArr addObject:@((int)_resultData)];
}

- (void)setupTimer{
    if (!self.showTimer) {
        self.showTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(chartAddPoint) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.showTimer forMode:NSRunLoopCommonModes];
    }
    [self sendInfo];
}

- (void)sendInfo{
    if (!self.showTimer) {
        return;
    }
   
    [self.bleDataManage sendInfoWithListModel:self.listMod];
}

- (void)HBLEDataManageReceivedInfo:(NSString *)info{
    NSArray * errorArr = @[@"UNABLETOCONNECT", @"NODATA"];
    
    BOOL isError = NO;
    
    for (NSString * errorStr in errorArr) {
        if ([info containsString:errorStr]) {
            isError = YES;
            break;
        }
    }
    
    if (!isError) {
        NSString * sendStr = [NSString stringWithFormat:@"%@%@\r", self.listMod.service,self.listMod.PID];
        
        if ([sendStr isEqualToString:@"ATRV\r"]) {
            _resultData = [[info substringToIndex:info.length - 1] floatValue];
        }else{
            NSRange range = [info rangeOfString:[NSString stringWithFormat:@"41%@", self.listMod.PID]];
            
            if (range.length && info.length > range.location + range.length + [self.listMod.bytes intValue] * 2) {
                info = [info substringWithRange:NSMakeRange(range.location + range.length, [self.listMod.bytes intValue] * 2)];
                
                _resultData = [self getInfoConvertedValueWithPID:self.listMod.PID info:info];
            }
        }
    }
    
    [self performSelector:@selector(sendInfo) withObject:nil afterDelay:0.5];
}

- (void)chartAddPoint{
    self.navigationItem.title = [NSString stringWithFormat:@"%@:%.0f%@",self.listMod.describe, _resultData, self.listMod.unit];
    
    [self.dataArr addObject:@(_resultData)];
    
    if (self.dataArr.count >= 11) {
        // options 支持 NSNuber, NSArray 和 AADataElement 三种类型
        AADataElement * options;
        options = AADataElement.new
        .ySet(self.dataArr.lastObject);
        [self.aaChartView aa_addPointsToChartSeriesArrayWithOptionsArray:@[options]];
        [self.dataArr removeObjectAtIndex:0];
    }else{
        NSArray *series = @[
            AASeriesElement.new
            .dataSet(self.dataArr)
        ];

        [_aaChartView aa_onlyRefreshTheChartDataWithChartModelSeries:series];
    }
    
}

#pragma mark 10进制转16进制
- (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    
    if (hex.length < 2) {
        hex = [NSString stringWithFormat:@"0%@", hex];
    }
    
    return hex;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
        [_dataArr addObject:@(_resultData)];
    }
    return _dataArr;
}

@end
