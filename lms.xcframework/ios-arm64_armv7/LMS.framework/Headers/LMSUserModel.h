//
//  LMSUserModel.h
//  LMS
//
//  Created by 何可人 on 2021/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMSUserModel : NSObject
@property (nonatomic, assign) int userID; //id
@property (nonatomic, copy) NSString * token; //令牌
@property (nonatomic, copy) NSString * email; //邮箱
@property (nonatomic, copy) NSString * name; //名字
@property (nonatomic, copy) NSString * faceUrl; //头像地址
@property (nonatomic, copy) NSString * birthday; //生日
@property (nonatomic, assign) int sex; //性别 1、男 0、女
@end

NS_ASSUME_NONNULL_END
