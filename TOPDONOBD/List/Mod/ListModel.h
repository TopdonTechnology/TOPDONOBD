//
//  ListModel.h
//  OBD
//
//  Created by 何可人 on 2021/6/22.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListModel : JSONModel
@property(nonatomic, retain) NSString *service;  // service
@property(nonatomic, retain) NSString *PID;  // PID
@property(nonatomic, retain) NSString *bytes;  // bytes
@property(nonatomic, retain) NSString *describe;  // describe
@property(nonatomic, retain) NSString *unit;  // unit
@property(nonatomic, retain) NSString *min;  // min
@property(nonatomic, retain) NSString *max;  // max
@property(nonatomic, retain) NSString<Optional> *value;  // value
@end

NS_ASSUME_NONNULL_END
