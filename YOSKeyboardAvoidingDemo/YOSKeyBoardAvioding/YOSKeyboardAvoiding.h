//
//  YOSKeyboardAvoiding.h
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/3/16.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YOSKeyboardAvoiding : NSObject

+ (void)setAvoidingView:(UIView *)avoidingView;

/**
 * triggerView被上升的键盘遮挡住的时候, 移动avoidingView, 
 * triggerView距离键盘顶部padding[default 0]个距离
 *
 * @param avoidingView: 需要移动的view
 * @param triggerView:  触发移动的view
 */
+ (void)setAvoidingView:(UIView *)avoidingView withTriggerView:(UIView *)triggerView;

+ (void)setAvoidingView:(UIView *)avoidingView withTriggerViews:(NSArray <__kindof UIView *>*)triggerViews;

/**
 * 设置padding, [default 0]
 *
 * @param triggerView:  触发移动的view
 */
+ (void)setPadding:(CGFloat)padding;

/**
 * 设置是否显示toolbar, [default YES]
 *
 * @param triggerView:  触发移动的view
 */
+ (void)setShowToolbar:(BOOL)flag;

/**
 * 移除某个特定的triggerView
 */
+ (void)removeTriggerView:(UIView *)triggerView;

/**
 * 页面切换的时候, 关闭键盘, 且做一些还原操作
 * 典型case: push/present之前
 */
+ (void)resume;


@end
