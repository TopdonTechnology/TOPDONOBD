//
//  SignUpOrInDataManage.h
//  OBD
//
//  Created by 何可人 on 2021/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignUpOrInDataManage : NSObject
+(BOOL)isValidateEmail:(NSString *)email;
+(BOOL)checkPassword:(NSString *) password;
@end

NS_ASSUME_NONNULL_END
