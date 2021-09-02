//
//  ErrorCodeModel.h
//  OBD
//
//  Created by 何可人 on 2021/8/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorCodeModel : NSObject
@property (nonatomic, copy) NSString * code;
@property (nonatomic, copy) NSString * describe;
@end

NS_ASSUME_NONNULL_END
