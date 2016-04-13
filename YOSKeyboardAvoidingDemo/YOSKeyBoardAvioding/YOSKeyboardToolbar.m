//
//  YOSKeyboardToolbar.m
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/4/7.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import "YOSKeyboardToolbar.h"
#import "YOSKeyboardAvoidingConst.h"

@implementation YOSKeyboardToolbar {
    UIButton *_leftButton;
    UIButton *_rightButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    [self setupSubviews];
    
    return self;
}

- (void)setupSubviews {

    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *leftBtn = [UIButton new];
    _leftButton = leftBtn;
    leftBtn.frame = CGRectMake(0, 0, 35, 35);
    [leftBtn setBackgroundImage:[UIImage imageNamed:YOSKeyboardAvoidingImageName(@"yos_left.png")] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[UIImage imageNamed:YOSKeyboardAvoidingImageName(@"yos_left_disable.png")] forState:UIControlStateDisabled];
    [leftBtn addTarget:self action:@selector(tappedLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIButton *rightBtn = [UIButton new];
    _rightButton = rightBtn;
    rightBtn.frame = CGRectMake(100, 0, 35, 35);
    [rightBtn setBackgroundImage:[UIImage imageNamed:YOSKeyboardAvoidingImageName(@"yos_right.png")] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:YOSKeyboardAvoidingImageName(@"yos_right_disable.png")] forState:UIControlStateDisabled];
    [rightBtn addTarget:self action:@selector(tappedRightBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIButton *downBtn = [UIButton new];
    downBtn.frame = CGRectMake(0, 0, 35, 35);
    [downBtn setBackgroundImage:[UIImage imageNamed:YOSKeyboardAvoidingImageName(@"yos_down.png")] forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(tappedDownBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:downBtn];

    [self setItems:@[leftItem, rightItem, flexItem, downItem]];
    
}

#pragma mark - handler event

- (void)tappedLeftBtn {
    
    if (self.leftHandler) {
        self.leftHandler();
    }
}

- (void)tappedRightBtn {
    
    if (self.rightHandler) {
        self.rightHandler();
    }
}

- (void)tappedDownBtn {
    
    if (self.downHandler) {
        self.downHandler();
    }
}

#pragma mark - APIs
- (void)hideLeftRightButton {
    _leftButton.hidden = YES;
    _rightButton.hidden = YES;
}
- (void)showLeftRightButton {
    _leftButton.hidden = NO;
    _rightButton.hidden = NO;
}

- (void)enableLeftButton {
    _leftButton.enabled = YES;
}
- (void)disableLeftButton {
    _leftButton.enabled = NO;
}

- (void)enableRightButton {
    _rightButton.enabled = YES;
}
- (void)disableRightButton {
    _rightButton.enabled = NO;
}

@end
