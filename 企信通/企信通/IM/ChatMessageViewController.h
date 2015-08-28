//
//  ChatMessageViewController.h
//  企信通
//
//  Created by apple on 13-12-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageViewController : UIViewController

// 对话方JID
@property (strong, nonatomic) NSString *bareJidStr;
// 对话方头像
@property (strong, nonatomic) UIImage *bareImage;
// 我的头像
@property (strong, nonatomic) UIImage *myImage;

@end
