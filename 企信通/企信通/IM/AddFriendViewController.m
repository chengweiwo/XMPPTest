//
//  AddFriendViewController.m
//  企信通
//
//  Created by apple on 13-12-3.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "AddFriendViewController.h"
#import "AppDelegate.h"

@interface AddFriendViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *friendNameText;

@end

@implementation AddFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_friendNameText becomeFirstResponder];
}

#pragma mark - UITextField代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 1. 判断文本框中是否输入了内容
    NSString *name = [textField.text trimString];
    if (![name isEmptyString]) {
        // 2. 如果输入，调用添加好友方法
        [self addFriendWithName:name];
    }

    return YES;
}

#pragma mark - 添加好友
- (void)addFriendWithName:(NSString *)name
{
    // 1. 判断输入是否由域名
    NSRange range = [name rangeOfString:@"@"];
    
    if (NSNotFound == range.location) {
        // 2. 如果没有，添加域名合成完整的JID字符串
        // 在name尾部添加域名
        name = [NSString stringWithFormat:@"%@@%@", name, [LoginUser sharedLoginUser].hostName];
    }
    
    // 3. 判断是否与当前用户相同
    if ([name isEqualToString:[LoginUser sharedLoginUser].myJIDName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"自己不用添加自己！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    // 4. 判断是否已经是自己的好友
    // 注释：userExistsWithJID方法仅用于检测指定的JID是否是用户的好友，而不是检测是否是合法的JID账户
    if ([[xmppDelegate xmppRosterStorage] userExistsWithJID:[XMPPJID jidWithString:name] xmppStream:[xmppDelegate xmppStream]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已经是好友，无需添加！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    // 5. 发送添加好友请求
    [[xmppDelegate xmppRoster] subscribePresenceToUser:[XMPPJID jidWithString:name]];
    
    // 6. 提示用户发送成功
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友请求已发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark - UIAlertView代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 返回上级页面
    [self.navigationController popViewControllerAnimated:YES];
}

@end
