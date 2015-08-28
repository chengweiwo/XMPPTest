//
//  ChatMessageCell.m
//  企信通
//
//  Created by apple on 13-12-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "ChatMessageCell.h"

@interface ChatMessageCell()
{
    UIImage *_receiveImage;
    UIImage *_receiveImageHL;
    UIImage *_senderImage;
    UIImage *_senderImageHL;
}

@end

@implementation ChatMessageCell

- (UIImage *)stretcheImage:(UIImage *)img
{
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5 topCapHeight:img.size.height * 0.6];
}

- (void)awakeFromNib
{
    // 实例化表格行背景使用的图像
    _receiveImage = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    _receiveImageHL = [UIImage imageNamed:@"ReceiverTextNodeBkgHL"];
    _senderImage = [UIImage imageNamed:@"SenderTextNodeBkg"];
    _senderImageHL = [UIImage imageNamed:@"SenderTextNodeBkgHL"];
    
    // 处理图像拉伸（因为iOS 6不支持图像切片）
//    _receiveImage = [_receiveImage stretchableImageWithLeftCapWidth:_receiveImage.size.width * 0.5 topCapHeight:_receiveImage.size.height * 0.6];
    _receiveImage = [self stretcheImage:_receiveImage];
    _receiveImageHL = [self stretcheImage:_receiveImageHL];
    _senderImage = [self stretcheImage:_senderImage];
    _senderImageHL = [self stretcheImage:_senderImageHL];
}

- (void)setMessage:(NSString *)message isOutgoing:(BOOL)isOutgoing
{
    // 1. 根据isOutgoing判断消息是发送还是接受，依次来设置按钮的背景图片
    if (isOutgoing) {
        [_messageButton setBackgroundImage:_senderImage forState:UIControlStateNormal];
        [_messageButton setBackgroundImage:_senderImageHL forState:UIControlStateHighlighted];
    } else {
        [_messageButton setBackgroundImage:_receiveImage forState:UIControlStateNormal];
        [_messageButton setBackgroundImage:_receiveImageHL forState:UIControlStateHighlighted];
    }
    
    // 2. 设置按钮文字
    // 2.1 计算文字占用的区间
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, 10000.0)];
    
    // 2.2 使用文本占用空间设置按钮的约束
    // 提示：需要考虑到在Stroyboard中设置的间距
    _messageHeightConstraint.constant = size.height + 30.0;
    _messageWeightConstraint.constant = size.width + 30.0;
    
    // 2.3 设置按钮文字
    [_messageButton setTitle:message forState:UIControlStateNormal];
    
    // 2.4 重新调整布局
    [self layoutIfNeeded];
}

@end
