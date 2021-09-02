//
//  ErrorCodeListViewController.m
//  OBD
//
//  Created by 何可人 on 2021/8/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "ErrorCodeListViewController.h"
#import "ErrorCodeModel.h"

@interface ErrorCodeListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ErrorCodeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatTableView];
}

- (void)creatTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 0.01f;
    tableView.estimatedSectionHeaderHeight = 0.01f;
    tableView.estimatedSectionFooterHeight = 0.01f;
    tableView.bounces = NO;
    [tableView setSeparatorColor:HLightGrayColor];
    [self.view insertSubview:tableView atIndex:0];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NavigationHeight, 0, iPhoneX_D, 0));
    }];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentify"];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify =@"cellIdentify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.numberOfLines = 0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row < self.listArr.count) {
        ErrorCodeModel * mod = self.listArr[indexPath.row];
       
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", mod.code, mod.describe];
        
        cell.textLabel.textColor = HWhiteColor;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
@end
