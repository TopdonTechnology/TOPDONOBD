//
//  SignUpOrInDataManage.m
//  OBD
//
//  Created by 何可人 on 2021/4/1.
//

#import "SignUpOrInDataManage.h"

@implementation SignUpOrInDataManage
#pragma mark  判斷郵箱是否合法
+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark  判斷密码是否合法
+(BOOL)checkPassword:(NSString *) password{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}
@end
