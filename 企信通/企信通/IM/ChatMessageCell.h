//
//  ChatMessageCell.h
//  企信通
//
//  Created by apple on 13-12-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageWeightConstraint;

- (void)setMessage:(NSString *)message isOutgoing:(BOOL)isOutgoing;

@end
