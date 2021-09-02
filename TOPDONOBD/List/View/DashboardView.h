//
//  DashboardView.h
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DashboardView : UIView
@property (nonatomic, assign) double value;
@property (nonatomic, strong) ListModel * listModel;
@end

NS_ASSUME_NONNULL_END
