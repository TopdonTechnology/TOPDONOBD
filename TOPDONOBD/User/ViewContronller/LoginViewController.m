//
//  LoginViewController.m
//  OBD
//
//  Created by 何可人 on 2021/8/25.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpOrInDataManage.h"
#import "RegisterViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView * centerView;
@property (nonatomic, strong) UITextField * emailText;
@property (nonatomic, strong) UITextField * passwordText;
@property (nonatomic, strong) UIButton * boxBtn;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"TOPDON";
    
    [self setUI];
    
}

#pragma mark 创建UI
- (void)setUI{
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375 * H_Height, IphoneHeight)];
    self.centerView.center = CGPointMake(IphoneWidth / 2, IphoneHeight / 2);
    [self.view insertSubview:self.centerView atIndex:0];
    
    float origin_x = 31 * H_Height;
    
    //sign in
    UILabel * signLabel = [UILabel createBtnFrame:CGRectMake(origin_x,121.5 * H_Height + NavigationHeight,IphoneWidth - 60 * H_Height,43 * H_Height) title:@"登录" fontName:@"" fontSize:28 textColor:HWhiteColor];
    [self.centerView addSubview:signLabel];
    
    //create an account
    float account_W = [Tools getWidthWithText:@"创建账号" height:16 * H_Height + 10 fontSize:[UIFont systemFontOfSize:16]];
    
    UIButton * accountBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    accountBtn.frame = CGRectMake(origin_x + 313 * H_Height - account_W,171.5 * H_Height + NavigationHeight,account_W,16 * H_Height + 10);
    [accountBtn addTarget:self action:@selector(createAnAccount) forControlEvents:UIControlEventTouchUpInside];
    [accountBtn setTitle:@"创建账号" forState:UIControlStateNormal];
    [accountBtn setTitleColor:HBlueColor forState:UIControlStateNormal];
    accountBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.centerView addSubview:accountBtn];
    
    //email
    UIView *emailView = [[UIView alloc] init];
    emailView.frame = CGRectMake(origin_x,212 * H_Height + NavigationHeight,313 * H_Height,44 * H_Height);
    emailView.layer.borderColor = HWhiteColor.CGColor;
    emailView.layer.borderWidth = 0.5 * H_Height;
    emailView.layer.cornerRadius = 2.5 * H_Height;
    [self.centerView addSubview:emailView];
    
    self.emailText = [[UITextField alloc] initWithFrame:emailView.bounds];
    self.emailText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邮箱" attributes:@{NSForegroundColorAttributeName:HLightGrayColor,NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    self.emailText.keyboardType = UIKeyboardTypeEmailAddress;
//    self.emailText.adjustsFontSizeToFitWidth=YES;
//    self.emailText.minimumFontSize=9;
    self.emailText.font = [UIFont systemFontOfSize:16];
    self.emailText.textColor = HWhiteColor;
    self.emailText.delegate = self;
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10 * H_Height, 0)];
    self.emailText.leftView = leftView;
    self.emailText.leftViewMode = UITextFieldViewModeAlways;
    //    self.emailText.secureTextEntry = YES;
    [emailView addSubview:self.emailText];
    
    //Password
    UIView *passwordView = [[UIView alloc] init];
    passwordView.frame = CGRectMake(origin_x,266 * H_Height + NavigationHeight,313 * H_Height,44 * H_Height);
    passwordView.layer.borderColor = HWhiteColor.CGColor;
    passwordView.layer.borderWidth = 0.5 * H_Height;
    passwordView.layer.cornerRadius = 2.5 * H_Height;
    [self.centerView addSubview:passwordView];
    
    self.passwordText = [[UITextField alloc] initWithFrame:passwordView.bounds];
    self.passwordText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:HLightGrayColor,NSFontAttributeName: [UIFont systemFontOfSize: 16]}];
//    self.emailText.adjustsFontSizeToFitWidth=YES;
//    self.emailText.minimumFontSize=9;
    self.passwordText.font = [UIFont systemFontOfSize:16];
    self.passwordText.textColor=HWhiteColor;
    self.passwordText.delegate = self;
    UIView * leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10 * H_Height, 0)];
    self.passwordText.leftView = leftView2;
    self.passwordText.leftViewMode = UITextFieldViewModeAlways;
    self.passwordText.secureTextEntry = YES;
    [passwordView addSubview:self.passwordText];
    
    UIButton * signBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = HBlueColor;
        btn.frame = CGRectMake(origin_x,370 * H_Height + NavigationHeight,313 * H_Height,44 * H_Height);
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        btn.layer.cornerRadius = 4;
        [btn addTarget:self action:@selector(signBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"登录" forState:UIControlStateNormal];
        btn;
    });
    [self.centerView addSubview:signBtn];

    //Forgotten your password?
    UIButton * forgottenBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(origin_x,431.5 * H_Height + NavigationHeight,200 * H_Height,16.5 * H_Height);
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        btn.layer.cornerRadius = 4;
        [btn setTitle:@"忘记密码？" forState:UIControlStateNormal];
        btn;
    });
    forgottenBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    forgottenBtn.center = CGPointMake(self.centerView.frame.size.width / 2, forgottenBtn.center.y);
    [forgottenBtn setTitleColor:HWhiteColor forState:UIControlStateNormal];
    [forgottenBtn addTarget:self action:@selector(forgottenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.centerView addSubview:forgottenBtn];
 
}

#pragma mark - 注册按钮点击
- (void)createAnAccount{
    [self.view endEditing:YES];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllers) {
        if ([vc isKindOfClass:[RegisterViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    RegisterViewController * vc = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 登录点击
- (void)signBtnClick{
    [self.view endEditing:YES];
    
    if (![SignUpOrInDataManage isValidateEmail:self.emailText.text]) {
        //邮箱格式不正确
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确"];
        return;
    }
    
    if (![SignUpOrInDataManage checkPassword:self.passwordText.text]) {
        //密码格式不正确
        [SVProgressHUD showErrorWithStatus:@"请输入6-8位数字和字母"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"请稍等"];
    
    [LMSHManager loginWithEmail:self.emailText.text password:self.passwordText.text isOtherLogin:NO otherLoginID:nil completion:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [SVProgressHUD dismiss];
        
        if (responseObject) {
            int user_id = 0;
            
            if ([[responseObject allKeys] containsObject:@"user_id"]) {
                user_id = [responseObject[@"user_id"] intValue];
            }
            
            if (user_id != 0) {
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                
                [self backClick];
            }
        }
    }];
}

#pragma mark 忘记密码点击
- (void)forgottenBtnClick{
    RegisterViewController * vc = [[RegisterViewController alloc] init];
    vc.type = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

@end
