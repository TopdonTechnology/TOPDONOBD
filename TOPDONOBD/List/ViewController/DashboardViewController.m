//
//  DashboardViewController.m
//  OBD
//
//  Created by 何可人 on 2021/8/24.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "DashboardViewController.h"
#import "DashboardView.h"

@interface DashboardViewController ()<UIScrollViewDelegate>
{
    int _getValueNub;//指令编号
    UIPageControl * _pageController;
}

@property (nonatomic, strong) NSArray * listArr; //列表数据
@property (nonatomic, strong) NSMutableArray * dashboardArr; //仪表盘数据
@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"仪表盘";
    
    [self getListData];
    
    [self creatUI];
    
    [self createPageController];
   
    [self getValueData];
}

- (void)getListData{
   
    self.listArr = [self getListPlistData];
}

- (void)creatUI{
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NavigationHeight, IphoneWidth, IphoneHeight - NavigationHeight - iPhoneX_D)];
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(IphoneWidth * 3, 0);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    for (int i = 0; i < self.listArr.count; i ++) {
        double center_x = 0;
        double center_y = 0;
        double scale = 1;
        
        if (i < 4) {
            center_x = scrollView.frame.size.width / 2.0 + scrollView.frame.size.width * (i / 2);
            
            center_y = scrollView.frame.size.height / 4.0 + scrollView.frame.size.height / 2.0 * (i % 2);
        }else{
            int index = i - 4;
            
            center_x = scrollView.frame.size.width / 4.0 + scrollView.frame.size.width / 2.0 * (index % 2) + scrollView.frame.size.width * 2;
            
            center_y = scrollView.frame.size.height / 6.0 + scrollView.frame.size.height / 3.0 * (index / 2);
            
            scale = 0.6;
        }
        
        ListModel * mod = self.listArr[i];
        
        DashboardView * dashboardView = [[DashboardView alloc] initWithFrame:CGRectMake(0, 0, IphoneWidth, IphoneWidth)];
        dashboardView.center = CGPointMake(center_x, center_y);
        dashboardView.listModel = mod;
        dashboardView.transform = CGAffineTransformMakeScale(scale, scale);
        dashboardView.value = [mod.min floatValue];
        [scrollView addSubview:dashboardView];
        
        [self.dashboardArr addObject:dashboardView];
    }

}

- (void)createPageController{
    //实例化页面管理
    _pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 60, IphoneWidth, 20)];
    _pageController.center = CGPointMake(IphoneWidth / 2, IphoneHeight - iPhoneX_D - 40);
    //一共有多少页（滚动循环多了两张）
    _pageController.numberOfPages = 3;
    //设置选中页
    _pageController.currentPage = 0;
    //设置点击换页码   默认no（切换）
    _pageController.defersCurrentPageDisplay = YES;
    
    [self.view addSubview:_pageController];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _pageController.currentPage = scrollView.contentOffset.x / IphoneWidth;
}

- (void)getValueData{
    ListModel * mod = self.listArr[_getValueNub];
    
    [self.bleDataManage sendInfoWithListModel:mod];
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
        ListModel * mod = self.listArr[_getValueNub];
        
        NSString * sendStr = [NSString stringWithFormat:@"%@%@\r", mod.service,mod.PID];
        
        if ([sendStr isEqualToString:@"ATRV\r"]) {
            float value = [[info substringToIndex:info.length - 1] floatValue];
            
            if (value > 0 && value < 24) {
                mod.value = info;
            }
        }else{
            NSRange range = [info rangeOfString:[NSString stringWithFormat:@"41%@", mod.PID]];
            
            if (range.length && info.length >= range.location + range.length + [mod.bytes intValue] * 2) {
                info = [info substringWithRange:NSMakeRange(range.location + range.length, [mod.bytes intValue] * 2)];
                
                float value = [self getInfoConvertedValueWithPID:mod.PID info:info];
                
                mod.value = [NSString stringWithFormat:@"%.0f%@", value, mod.unit];
            }
        }
        
        DashboardView * dashboardView = self.dashboardArr[_getValueNub];
        
        dashboardView.value = [mod.value floatValue];
    }
    
    _getValueNub ++;
    
    if (_getValueNub >= self.listArr.count) {
        _getValueNub = 0;
    }
    
    [self getValueData];
}

- (NSMutableArray *)dashboardArr{
    if (!_dashboardArr) {
        _dashboardArr = [[NSMutableArray alloc] init];
    }
    
    return _dashboardArr;
}
@end
