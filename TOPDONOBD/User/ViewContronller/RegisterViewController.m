//
//  RegisterViewController.m
//  OBD
//
//  Created by 何可人 on 2021/8/25.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "RegisterViewController.h"
#import "SignUpOrInDataManage.h"
#import "LoginViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
{
    UIButton * _codeBtn;
    int _codeNub;
    BOOL _isSave;
}

@property (nonatomic, strong) NSTimer * codeTimer;
@end

@implementation RegisterViewController

- (void)viewDidDisappear:(BOOL)animate{
    [super viewDidDisappear:animate];
    
    if (!_isSave) {
        if (self.codeTimer) {
            [self.codeTimer invalidate];
            self.codeTimer = nil;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _isSave = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"TOPDON";
    
    [self setUI];
}

#pragma mark 创建UI
- (void)setUI{
    float bindingEmail = 0 * H_Height;
    
    float TextField_w = 313 * H_Height;
    
    float origin_x = IphoneWidth / 2 - TextField_w / 2;
    
    NSString * sign_text = @"注册";
    NSString * logIn_text = @"登录";
    NSString * password_text = @"密码";
    NSString * signBtn_text = @"注册";
    
    UIColor * logIn_color = HBlueColor;
    
    if (self.type == 1) {
        sign_text = @"忘记密码";
        logIn_text = @"输入您的电子邮件地址以重置密码";
        password_text = @"新密码";
        signBtn_text = @"提交";
        logIn_color = HWhiteColor;
    }
    
    //sign in
    UILabel * signLabel = [UILabel createBtnFrame:CGRectMake(origin_x,90 * H_Height + NavigationHeight,IphoneWidth - origin_x - 20 * H_Height,43 * H_Height) title:sign_text fontName:@"" fontSize:28 textColor:HWhiteColor];
    [self.view addSubview:signLabel];

    //or log in
    float logIn_w = [Tools getWidthWithText:logIn_text height:16.5 * H_Height + 20 fontSize:[UIFont systemFontOfSize:16]];
    
    UIButton * logInBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    logInBtn.frame = CGRectMake(IphoneWidth / 2 + TextField_w / 2 - logIn_w,139.5 * H_Height + NavigationHeight - 10,logIn_w,16.5 * H_Height + 20);
    [logInBtn addTarget:self action:@selector(logInBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [logInBtn setTitle:logIn_text forState:UIControlStateNormal];
    logInBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [logInBtn setTitleColor:logIn_color forState:UIControlStateNormal];
    [self.view addSubview:logInBtn];
    
    if (self.type == 1) {
        logInBtn.enabled = NO;
        logInBtn.frame = CGRectMake(IphoneWidth / 2 - TextField_w / 2, 139.5 * H_Height + NavigationHeight - 10, logIn_w, 16.5 * H_Height + 20);
    }
    
    //4个输入框
    NSArray * TextFieldArr = @[@"邮箱",@"验证码",password_text,@"确认密码"];
    for (int i = 0; i < TextFieldArr.count; i ++) {
        UIView *boxView = [[UIView alloc] init];
        boxView.frame = CGRectMake(origin_x,180 * H_Height + NavigationHeight + 54 * H_Height * i,TextField_w,44 * H_Height);
        boxView.center = CGPointMake(IphoneWidth / 2, boxView.center.y);
        boxView.layer.borderColor = HWhiteColor.CGColor;
        boxView.layer.borderWidth = 0.5 * H_Height;
        boxView.layer.cornerRadius = 2.5 * H_Height;
        [self.view addSubview:boxView];
        
        if (i == 1) {
            CGRect rect = boxView.frame;
            rect.size.width = 192 * H_Height;
            boxView.frame = rect;
        }
        
        UITextField * textField = [[UITextField alloc] initWithFrame:boxView.bounds];
        textField.tag = 100 + i;
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TextFieldArr[i] attributes:@{NSForegroundColorAttributeName:HLightGrayColor,NSFontAttributeName: [UIFont systemFontOfSize: 16]}];
        textField.font = [UIFont systemFontOfSize:16];
        textField.textColor=HWhiteColor;
        textField.delegate = self;
        textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10 * H_Height, 0)];
        //设置显示模式为永远显示(默认不显示)
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        if (i >= TextFieldArr.count - 2) {
            textField.secureTextEntry = YES;
        }
        [boxView addSubview:textField];
        
        if (i == 0) {
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
    }
    
    //register_code
    UIButton * codeBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = HBlueColor;
        btn.frame = CGRectMake(origin_x + 202 * H_Height, 234 * H_Height + NavigationHeight, 111 * H_Height, 44 * H_Height);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.layer.cornerRadius = 4;
        [btn addTarget:self action:@selector(codeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"验证码" forState:UIControlStateNormal];
        btn;
    });
    [self.view addSubview:codeBtn];
    _codeBtn = codeBtn;
    
    //Sign up
    UIButton * signUpBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = HBlueColor;
        btn.frame = CGRectMake(origin_x, 446.5 * H_Height + NavigationHeight + bindingEmail, TextField_w, 44 * H_Height);
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        [btn addTarget:self action:@selector(signUpBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:signBtn_text forState:UIControlStateNormal];
        btn.layer.cornerRadius = 4;
        btn;
    });
    [self.view addSubview:signUpBtn];
}

- (void)logInBtnClick{
    [self.view endEditing:YES];
    
    [self gotoSignInViewController];
}

- (void)gotoSignInViewController{
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    for (UIViewController *vc in viewControllers) {
        if ([vc isKindOfClass:[LoginViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    _isSave = YES;
    LoginViewController * vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)codeBtnClick{
    [self.view endEditing:YES];

    UITextField * textField = [self.view viewWithTag:100];
    //验证邮箱是否有效
    if ([SignUpOrInDataManage isValidateEmail:textField.text]) {
        if (!self.codeTimer) {
            _codeBtn.enabled = NO;
            _codeBtn.backgroundColor = HLightGrayColor;
            _codeBtn.titleLabel.text = @"60s";
            [_codeBtn setTitle:@"60s" forState:UIControlStateNormal];
            _codeNub = 60;
            
            [SVProgressHUD showWithStatus:@"请稍等"];
            
            [LMSHManager getVerifyCodeWithEmail:textField.text type:self.type + 1 completion:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                [SVProgressHUD dismiss];
                
                if (error) {
                    
                }else
                {
                    NSInteger a =[responseObject[@"code"] integerValue];
                    
                    if (a==0) {
                        [SVProgressHUD showSuccessWithStatus:@"请在电子邮箱里查收验证码"];
                    }
                }
            }];
            
            self.codeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeCodeBtn) userInfo:nil repeats:YES];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确"];
    }
}

- (void)changeCodeBtn{
    _codeNub --;
    NSString * codeNub = [NSString stringWithFormat:@"%ds", _codeNub];
    _codeBtn.titleLabel.text = codeNub;
    [_codeBtn setTitle:codeNub forState:UIControlStateNormal];
    if (_codeNub == 0) {
        if (self.codeTimer) {
            [self.codeTimer invalidate];
            self.codeTimer = nil;
        }
        
        [_codeBtn setTitle:@"验证码" forState:UIControlStateNormal];
        _codeBtn.enabled = YES;
        _codeBtn.backgroundColor = HBlueColor;
    }
}

- (void)signUpBtnClick{
    [self.view endEditing:YES];
    
    UITextField * emailTextField = [self.view viewWithTag:100];
    UITextField * codeTextField = [self.view viewWithTag:101];
    UITextField * pTextField1 = [self.view viewWithTag:102];
    UITextField * pTextField2 = [self.view viewWithTag:103];
    
    if (![SignUpOrInDataManage isValidateEmail:emailTextField.text]) {
        //验证邮箱是否有效
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确"];
        return;
    }else if (codeTextField.text.length == 0) {
        //验证码是否填写
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }else if (pTextField1.text.length == 0 || pTextField2.text.length == 0) {
        //密码是否填写
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }else if (![pTextField1.text isEqualToString:pTextField2.text]) {
        //密码是否一致
        [SVProgressHUD showErrorWithStatus:@"密码不一致"];
        return;
    }else if (![SignUpOrInDataManage checkPassword:pTextField1.text]) {
        //密码是否符合要求
        [SVProgressHUD showErrorWithStatus:@"请输入6-8位数字和字母"];
        return;
    }
    
    //注册请求
    [SVProgressHUD showWithStatus:@"请稍等"];
    kWeakSelf(self);
    if (self.type == 0) {
        [LMSHManager registerWithEmail:emailTextField.text VerifyCode:codeTextField.text Password:pTextField1.text isOtherLogin:NO otherLoginID:nil otherType:0 completion:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            [SVProgressHUD dismiss];
            
            if (error) {
                
            }else
            {
                NSInteger a =[responseObject[@"code"] integerValue];
                
                if (a==0) {
                    [weakself.view endEditing:YES];
                    [weakself logInBtnClick];
                    [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                }
            }
        }];
    }else{
        [LMSHManager postForgetPwdUrlWithEmail:emailTextField.text VerifyCode:codeTextField.text Password:pTextField1.text completion:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                
            }else
            {
                NSInteger a =[responseObject[@"code"] integerValue];
                
                if (a==0) {
                    [weakself.view endEditing:YES];
                    [weakself logInBtnClick];
                    [SVProgressHUD showSuccessWithStatus:@"修改密码成功"];
                }
            }
        }];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)backClick{
    [super backClick];
    
    if (self.codeTimer) {
        [self.codeTimer invalidate];
        self.codeTimer = nil;
    }
}


@end
