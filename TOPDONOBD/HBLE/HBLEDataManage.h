//
//  HBLEDataManage.h
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListModel.h"
NS_ASSUME_NONNULL_BEGIN


@protocol HBLEDataManageDelegate <NSObject>

@optional
- (void)HBLEDataManageReceivedInfo:(NSString *)info;

@end

@interface HBLEDataManage : NSObject
@property (nonatomic, assign) id<HBLEDataManageDelegate> delegata;

- (void)sendInfoWithListModel:(ListModel *)mod;
@end

NS_ASSUME_NONNULL_END
