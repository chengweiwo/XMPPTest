//
//  LoginUser.h
//  企信通
//
//  Created by apple on 13-11-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface LoginUser : NSObject
single_interface(LoginUser)

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *hostName;

@property (strong, nonatomic, readonly) NSString *myJIDName;

@end
