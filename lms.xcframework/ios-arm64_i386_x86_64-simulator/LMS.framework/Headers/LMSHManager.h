//
//  Topdon_HLogin.h
//  LoginDemo
//
//  Created by 何可人 on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import "LMSUserModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^Topdon_HReturnBlock)(NSURLResponse * __nullable response, id __nullable responseObject, NSError * __nullable error);

@protocol LMSHManagerDelegata <NSObject>

@optional

/// 所有接口的回调
/// @param response 回应对象
/// @param responseObject 回应内容
/// @param error 错误
- (void)LMSHManagerGetAllURLCallbackWithResponse:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error;

/// 用户信息回调--回到前台时触发
/// @param userModel 用户信息Model
- (void)LMSHManagerGetUserInfo:(LMSUserModel *)userModel;
@end

@interface LMSHManager : NSObject

/// 初始化
/// @param delegata 代理
/// @param language 语言--默认为英语，传空则设置为英语
+ (void)initWithDelegata:(id<LMSHManagerDelegata>)delegata Language:(NSString *__nullable)language;

/// 设置代理回调
/// @param delegata 代理
+ (void)setLMSHManagerDelegata:(id <LMSHManagerDelegata>)delegata;

/// 设置日志是否开启
/// @param enable 是否开启日志，默认关闭
+ (void)setLogEnable:(BOOL)enable;

/// 获取日志输出状态
+ (BOOL)getLogEnable;

/// 设置语言
/// @param language 语言--默认为英语，传空则设置为英语
+ (void)setLanguage:(NSString *__nullable)language;

///获取当前语言
+ (NSString *)getLanguage;

/// 是否登录
+ (BOOL)userIsLogin;

/// 退出登录
+ (void)userLogOut;

/// 获取本地用户信息
+ (LMSUserModel *)getUserInfo;

///取消所有的网络请求
+ (void)cancelRequest;

/// 账号密码登陆/第三方登录
/// @param email 邮箱--如果是第三方登录传获取到的邮箱
/// @param password 密码--密码长度为6-8位，必须含字母加数字--如果是第三方登录传获取到的密码
/// @param isOtherLogin 是否是第三方登录
/// @param otherLoginID 第三方ID--可为空
/// @param block 回调
+ (NSURLSessionDataTask *)loginWithEmail:(NSString *)email password:(NSString *)password isOtherLogin:(BOOL)isOtherLogin otherLoginID:(NSString * __nullable)otherLoginID completion:(Topdon_HReturnBlock)block;

/// 获取验证码
/// @param email 邮箱
/// @param type 类型，1 注册，2 忘记密码
/// @param block 回调
+ (NSURLSessionDataTask *)getVerifyCodeWithEmail:(NSString *)email type:(int)type completion:(Topdon_HReturnBlock)block;

/// 忘记密码
/// @param email 邮箱
/// @param verifyCode 验证码
/// @param password 密码--密码长度为6-8位，必须含字母加数字
/// @param block 回调
+ (NSURLSessionDataTask *)postForgetPwdUrlWithEmail:(NSString *)email VerifyCode:(NSString *)verifyCode Password:(NSString *)password completion:(Topdon_HReturnBlock)block;

/// 根据第三方id获取用户邮箱以及密码
/// @param openType 第三方类型：1:wx,2:facebook,3:twitter,4,apple
/// @param openId 第三方ID
/// @param block 回调
+ (NSURLSessionDataTask *)getEmailByThirdKeyWithOpenType:(int)openType openId:(NSString *)openId completion:(Topdon_HReturnBlock)block;

/// 账号密码注册/第三方注册
/// @param email 邮箱
/// @param verifyCode 验证码
/// @param password 密码--密码长度为6-8位，必须含字母加数字
/// @param isOtherLogin 是否是第三方注册
/// @param otherLoginID 第三方ID--可为空
/// @param otherType 第三方类型:1:wx,2:facebook,3:twitter,4,apple
/// @param block 回调
+ (NSURLSessionDataTask *)registerWithEmail:(NSString *)email VerifyCode:(NSString *)verifyCode Password:(NSString *)password isOtherLogin:(BOOL)isOtherLogin otherLoginID:(NSString * __nullable)otherLoginID otherType:(int)otherType completion:(Topdon_HReturnBlock)block;

/// 修改密码
/// @param password 密码--密码长度为6-8位，必须含字母加数字
/// @param block 回调
+ (NSURLSessionDataTask *)resetPasswordWithPassword:(NSString *)password completion:(Topdon_HReturnBlock)block;

/// 获取服务器用户信息
/// @param block 回调
+ (NSURLSessionDataTask *)getUserInfoCompletion:(Topdon_HReturnBlock)block;

/// 修改用户信息接口
/// @param name 昵称
/// @param faceUrl 头像url
/// @param sex 性别 1 男 0 女
/// @param birthday 生日（MM-DD ）
/// @param block 回调
+ (NSURLSessionDataTask *)setUserInfoWithName:(NSString * __nullable)name faceUrl:(NSString * __nullable)faceUrl sex:(int)sex birthday:(NSString * __nullable)birthday completion:(Topdon_HReturnBlock)block;
@end

NS_ASSUME_NONNULL_END
