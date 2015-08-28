//
//  LoginViewController.m
//  02.用户登录&注册
//
//  Created by apple on 13-11-28.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+Helper.h"
#import "AppDelegate.h"
#import "LoginUser.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *hostNameText;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

#pragma mark - AppDelegate 的助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1. 拉伸按钮背景图片
    // 1) 登录按钮
    UIImage *loginImage = [UIImage imageNamed:@"LoginGreenBigBtn"];
    loginImage = [loginImage stretchableImageWithLeftCapWidth:loginImage.size.width * 0.5 topCapHeight:loginImage.size.height * 0.5];
    [_loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
    
    // 2) 注册按钮
    UIImage *registerImage = [UIImage imageNamed:@"LoginwhiteBtn"];
    registerImage = [registerImage stretchableImageWithLeftCapWidth:registerImage.size.width * 0.5 topCapHeight:registerImage.size.height * 0.5];
    [_registerButton setBackgroundImage:registerImage forState:UIControlStateNormal];
    
    // 2. 设置界面文本的初始值
    _userNameText.text = [[LoginUser sharedLoginUser] userName];
    _passwordText.text = [[LoginUser sharedLoginUser] password];
    _hostNameText.text = [[LoginUser sharedLoginUser] hostName];
    
    // 3. 设置文本焦点
    if ([_userNameText.text isEmptyString]) {
        [_userNameText becomeFirstResponder];
    } else {
        [_passwordText becomeFirstResponder];
    }
}

#pragma mark UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameText) {
        [_passwordText becomeFirstResponder];
    } else if (textField == _passwordText && [_hostNameText.text isEmptyString]) {
        [_hostNameText becomeFirstResponder];
    } else {
        [self userLoginAndRegister:nil];
    }
    
    return YES;
}

#pragma mark - Actions
#pragma mark 用户登录
- (IBAction)userLoginAndRegister:(UIButton *)button
{
    // 1. 检查用户输入是否完整，在商业软件中，处理用户输入时
    // 通常会截断字符串前后的空格（密码除外），从而可以最大程度地降低用户输入错误
    NSString *userName = [_userNameText.text trimString];
    // 用些用户会使用空格做密码，因此密码不能去除空白字符
    NSString *password = _passwordText.text;
    NSString *hostName = [_hostNameText.text trimString];
    
    if ([userName isEmptyString] ||
        [password isEmptyString] ||
        [hostName isEmptyString]) {
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录信息不完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alter show];
        
        return;
    }
    
    // 2. 将用户登录信息写入系统偏好
    [[LoginUser sharedLoginUser] setUserName:userName];
    [[LoginUser sharedLoginUser] setPassword:password];
    [[LoginUser sharedLoginUser] setHostName:hostName];
    
    // 3. 让AppDelegate开始连接
    // 告诉AppDelegate，当前是注册用户
    NSString *errorMessage = nil;
    
    if (button.tag == 1) {
        [self appDelegate].isRegisterUser = YES;
        errorMessage = @"注册用户失败！";
    } else {
        errorMessage = @"用户登录失败！";
    }
    
    [[self appDelegate] connectWithCompletion:nil failed:^{
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alter show];
        
        if (button.tag == 1) {
            // 注册用户失败通常是因为用户名重复
            [_userNameText becomeFirstResponder];
        } else {
            // 登录失败通常是密码输入错误
            [_passwordText setText:@""];
            [_passwordText becomeFirstResponder];
        }
    }];
}

@end
