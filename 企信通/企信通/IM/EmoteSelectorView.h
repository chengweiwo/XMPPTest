//
//  EmoteSelectorView.h
//  企信通
//
//  Created by apple on 13-12-6.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmoteSelectorViewDelegate <NSObject>

// 选择表情字符串
- (void)emoteSelectorViewSelectEmoteString:(NSString *)emote;
// 删除字符
- (void)emoteSelectorViewRemoveChar;

@end

@interface EmoteSelectorView : UIView

@property (weak, nonatomic) id <EmoteSelectorViewDelegate> delegate;

@end
