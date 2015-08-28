//
//  LoginUser.m
//  企信通
//
//  Created by apple on 13-11-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "LoginUser.h"
#import "NSString+Helper.h"

#define kXMPPUserNameKey    @"xmppUserName"
#define kXMPPPasswordKey    @"xmppPassword"
#define kXMPPHostNameKey    @"xmppHostName"

@implementation LoginUser
single_implementation(LoginUser)

#pragma mark - 私有方法
- (NSString *)loadStringFromDefaultsWithKey:(NSString *)key
{
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    return (str) ? str : @"";
}

#pragma mark - getter & setter
- (NSString *)userName
{
    return [self loadStringFromDefaultsWithKey:kXMPPUserNameKey];
}

- (void)setUserName:(NSString *)userName
{
    [userName saveToNSDefaultsWithKey:kXMPPUserNameKey];
}

- (NSString *)password
{
    return [self loadStringFromDefaultsWithKey:kXMPPPasswordKey];
}

- (void)setPassword:(NSString *)password
{
    [password saveToNSDefaultsWithKey:kXMPPPasswordKey];
}

- (NSString *)hostName
{
    return [self loadStringFromDefaultsWithKey:kXMPPHostNameKey];
}

- (void)setHostName:(NSString *)hostName
{
    [hostName saveToNSDefaultsWithKey:kXMPPHostNameKey];
}

- (NSString *)myJIDName
{
    return [NSString stringWithFormat:@"%@@%@", self.userName, self.hostName];
}

@end
