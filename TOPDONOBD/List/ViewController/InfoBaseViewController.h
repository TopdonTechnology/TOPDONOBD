//
//  InfoBaseViewController.h
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "HBLEDataManage.h"
#import "ListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface InfoBaseViewController : BaseViewController<HBLEDataManageDelegate>
@property(nonatomic, strong) ListModel * listMod;
@property (nonatomic, strong) HBLEDataManage * bleDataManage;

- (float)getInfoConvertedValueWithPID:(NSString *)PID info:(NSString *)info;

- (NSMutableArray *)getListPlistData;
@end

NS_ASSUME_NONNULL_END
