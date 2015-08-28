//
//  EditVCardViewController.h
//  企信通
//
//  Created by apple on 13-12-1.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditVCardViewController;

@protocol EditVCardViewControllerDelegate <NSObject>

- (void)editVCardViewControllerDidFinished;

@end

@interface EditVCardViewController : UIViewController

@property (weak, nonatomic) id<EditVCardViewControllerDelegate> delegate;

// 内容标题
@property (strong, nonatomic) NSString *contentTitle;
// 内容标签
@property (weak, nonatomic) UILabel *contentLable;

@end
