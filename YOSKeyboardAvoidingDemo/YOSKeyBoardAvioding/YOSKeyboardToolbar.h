//
//  YOSKeyboardToolbar.h
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/4/7.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^YOSKeyboardToolbarVoidBlock)();

@interface YOSKeyboardToolbar : UIToolbar

@property (nonatomic, copy) YOSKeyboardToolbarVoidBlock leftHandler;

@property (nonatomic, copy) YOSKeyboardToolbarVoidBlock rightHandler;

@property (nonatomic, copy) YOSKeyboardToolbarVoidBlock downHandler;

- (void)hideLeftRightButton;
- (void)showLeftRightButton;

- (void)enableLeftButton;
- (void)disableLeftButton;

- (void)enableRightButton;
- (void)disableRightButton;

@end
