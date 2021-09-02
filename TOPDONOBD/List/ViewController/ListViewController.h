//
//  ListViewController.h
//  OBD
//
//  Created by 何可人 on 2021/6/22.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "InfoBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum _ListVCType {
    ListVCType_command = 0,
    ListVCType_BLE
} ListVCType;

@interface ListViewController : InfoBaseViewController
@property (nonatomic, assign) ListVCType vcType;
@end

NS_ASSUME_NONNULL_END
