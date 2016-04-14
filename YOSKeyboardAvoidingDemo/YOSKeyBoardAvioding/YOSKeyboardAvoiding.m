//
//  YOSKeyboardAvoiding.m
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/3/16.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import "YOSKeyboardAvoiding.h"
#import "YOSKeyboardAvoidingConst.h"
#import "YOSKeyboardToolbar.h"
#import "UITextField+YOSKeyboardAvioding.h"
#import "UITextView+YOSKeyboardAvoiding.h"
#import <objc/runtime.h>

static YOSKeyboardAvoiding *_keyboardAvoiding;

@interface YOSKeyboardAvoiding()

@property (nonatomic, assign) CGFloat padding;

@end


@interface YOSKeyboardAvoiding()

@property (nonatomic, strong) YOSKeyboardToolbar  *toolbar;

@property (nonatomic, weak) UIView *avoidingView;

@property (nonatomic, strong) NSMutableArray <__kindof UIView *>*triggerViews;

@property (nonatomic, assign) UIInterfaceOrientation lastStatusBarOrientation;

@property (nonatomic, strong) NSNotification *lastNotification;

@property (nonatomic, assign) CGFloat scrollViewOffsetY;

@property (nonatomic, assign) NSUInteger currentTriggerViewIndex;

@property (nonatomic, assign) BOOL isKeyboardVisible;

@property (nonatomic, assign) BOOL isShowToolbar;

@property (nonatomic, assign) BOOL isTriggerView;

@end

@implementation YOSKeyboardAvoiding

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - APIs

+ (void)setAvoidingView:(UIView *)avoidingView {
    
    NSArray *views = [self _getEduitSubviewsFromSuperView:avoidingView];
    
    [self setAvoidingView:avoidingView withTriggerViews:views];
}

+ (void)setAvoidingView:(UIView *)avoidingView withTriggerView:(UIView *)triggerView {

    [self setAvoidingView:avoidingView withTriggerViews:@[triggerView]];
    
}

+ (void)setAvoidingView:(UIView *)avoidingView withTriggerViews:(NSArray <__kindof UIView *>*)triggerViews {
    
    [self _init];
    
    BOOL status = YES;
    
    for (NSUInteger i = 0; i < triggerViews.count; ++i) {
        UIView *tempView = triggerViews[i];
        while (tempView != avoidingView) {
            tempView = tempView.superview;
            
            if (tempView) {
                continue;
            } else {
                status = NO;
                break;
            }
        }
    }
    
    // avoidingView must be triggerView's ancestor view.
    NSAssert(status, @"avoidingView must equal to triggerView, or to be triggerView's ancestor view");
    
    NSMutableArray *weakTriggerViews = [NSMutableArray array];
    
    [triggerViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        __weak UIView *weakView = obj;
        [weakTriggerViews addObject:weakView];
        
    }];
    
    // 先清除上一个avoidingView的transform
    [_keyboardAvoiding.triggerViews removeAllObjects];
    _keyboardAvoiding.avoidingView = avoidingView;
    _keyboardAvoiding.avoidingView.transform = CGAffineTransformIdentity;
    
    _keyboardAvoiding.triggerViews = weakTriggerViews;
    _keyboardAvoiding.currentTriggerViewIndex = 0;
    
    // 键盘已经被某个控件呼出的时候, 点击其他能呼出键盘的控件, 立即调整距离
    // 典型case: 从一个UITextField 点击到另一个 UITextField上
    if (_keyboardAvoiding.isKeyboardVisible && _keyboardAvoiding.lastNotification) {
        [_keyboardAvoiding _keyboardWillChangeFrame:_keyboardAvoiding.lastNotification];
    }
    
    [self _setupToolbar];
}

+ (void)setPadding:(CGFloat)padding {
    [self _init];
    
    _keyboardAvoiding.padding = padding;
}

+ (void)setShowToolbar:(BOOL)flag {
    [self _init];
    
    _keyboardAvoiding.isShowToolbar = flag;
    
    [self _setupToolbar];
}

+ (void)removeTriggerView:(UIView *)triggerView {
    [self _init];
    
    [_keyboardAvoiding.triggerViews removeObject:triggerView];
}

+ (void)resume {
    [self _init];
    
    [_keyboardAvoiding.avoidingView endEditing:YES];
    
    [_keyboardAvoiding.triggerViews removeAllObjects];
    _keyboardAvoiding.avoidingView = nil;
    _keyboardAvoiding.lastNotification = nil;
}

#pragma mark - init

+ (void)_init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _keyboardAvoiding = [YOSKeyboardAvoiding new];
        [[NSNotificationCenter defaultCenter] addObserver:_keyboardAvoiding selector:@selector(_keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_keyboardAvoiding selector:@selector(_touchView:) name:YOSTouchViewNotification object:nil];
        
        _keyboardAvoiding.padding = 0;
        _keyboardAvoiding.isShowToolbar = YES;
        
        YOSKeyboardToolbar *toolbar = [YOSKeyboardToolbar new];
        toolbar.frame = CGRectMake(0, 0, [_keyboardAvoiding _screenSize].width, 40);
        
        YOSKeyboardToolbarVoidBlock leftHander = ^{
            
            if (_keyboardAvoiding.currentTriggerViewIndex > 0) {
                _keyboardAvoiding.currentTriggerViewIndex -= 1;
            }
            
            if (_keyboardAvoiding.triggerViews.count -1 >= _keyboardAvoiding.currentTriggerViewIndex) {
                [[_keyboardAvoiding _currentTriggerView] becomeFirstResponder];
                [[NSNotificationCenter defaultCenter] postNotificationName:YOSTouchViewNotification object:[_keyboardAvoiding _currentTriggerView]];
            }
            
        };
        
        YOSKeyboardToolbarVoidBlock rightHandler = ^{
            if (_keyboardAvoiding.currentTriggerViewIndex + 1 < _keyboardAvoiding.triggerViews.count) {
                _keyboardAvoiding.currentTriggerViewIndex += 1;
            }
            
            if (_keyboardAvoiding.triggerViews.count -1 >= _keyboardAvoiding.currentTriggerViewIndex) {
                [[_keyboardAvoiding _currentTriggerView] becomeFirstResponder];
                [[NSNotificationCenter defaultCenter] postNotificationName:YOSTouchViewNotification object:[_keyboardAvoiding _currentTriggerView]];
            }
        };
        
        YOSKeyboardToolbarVoidBlock downHandler = ^{
            [_keyboardAvoiding.avoidingView endEditing:YES];
        };
        
        toolbar.leftHandler = leftHander;
        toolbar.rightHandler = rightHandler;
        toolbar.downHandler = downHandler;
        
        _keyboardAvoiding.toolbar = toolbar;
    });
}

+ (void)_setupToolbar {
    NSArray *views = [self _getEduitSubviewsFromSuperView:_keyboardAvoiding.avoidingView];
    
    if (views.count >= 2) {
        [_keyboardAvoiding.toolbar showLeftRightButton];
    } else {
        [_keyboardAvoiding.toolbar hideLeftRightButton];
    }
    
    [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[UITextField class]]) {
            UITextField *tf = obj;
            
            if (_keyboardAvoiding.isShowToolbar) {
                tf.inputAccessoryView = _keyboardAvoiding.toolbar;
            } else {
                tf.inputAccessoryView = nil;
            }
            
        } else if ([obj isKindOfClass:[UITextView class]]) {
            UITextView *tv = obj;
            
            if (_keyboardAvoiding.isShowToolbar) {
                tv.inputAccessoryView = _keyboardAvoiding.toolbar;
            } else {
                tv.inputAccessoryView = nil;
            }
        }
        
    }];
}

#pragma mark - helpers

+ (NSArray *)_getEduitSubviewsFromSuperView:(UIView *)superView {
    // 获取UITextField/UITextView
    NSMutableArray *tempArrayM = [NSMutableArray array];
    
    if (superView.subviews.count) {
        [superView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[UITextField class]]) {
                [tempArrayM addObject:obj];
            } else if ([obj isKindOfClass:[UITextView class]]) {
                [tempArrayM addObject:obj];
            } else if ([obj isKindOfClass:[UIView class]]) {
                [tempArrayM addObjectsFromArray:[self _getEduitSubviewsFromSuperView:obj]];
            }
            
        }];
    } else {
        if ([superView isKindOfClass:[UITextField class]]) {
            [tempArrayM addObject:superView];
        } else if ([superView isKindOfClass:[UITextView class]]) {
            [tempArrayM addObject:superView];
        }
    }
    
    return tempArrayM;
}

- (BOOL)_isLandscape {
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
}

- (CGSize)_screenSize {
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    CGFloat max = ((size.width > size.height) ? size.width : size.height);
    CGFloat min = ((size.width < size.height) ? size.width : size.height);
    
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    systemVersion = floor(systemVersion);
    
    // iOS8.x 特殊处理
    if (systemVersion == 8) {

        if (self.lastStatusBarOrientation != [[UIApplication sharedApplication] statusBarOrientation]) {
            
            self.lastStatusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            self.avoidingView.transform = CGAffineTransformIdentity;
            
            if ([self _isLandscape]) {
                return CGSizeMake(min, max);
            } else {
                return CGSizeMake(max, min);
            }
            
        } else {
            if ([self _isLandscape]) {
                return CGSizeMake(max, min);
            } else {
                return CGSizeMake(min, max);
            }
        }
        
    } else {
        
        if ([self _isLandscape]) {
            return CGSizeMake(max, min);
        } else {
            return CGSizeMake(min, max);
        }
        
    }
    
}

- (CGRect)_getOrientedRect:(CGRect)originalRect {
    
    // iOS8 以下[UIScreen mainScreen].bounds, 以及获取键盘(键盘其实也是在某个window上)的
    // frame, 或者转移某个view的frame到window上, 无论屏幕朝向，都是以Portrait模式返回的, 不以当前的UIInterfaceOrientation返回, iOS8以后就跟当前的UIInterfaceOrientation相关了
    // 另外, 无论iOS几, VC中的view都和自己当前视图UIInterfaceOrientation相关
    
    CGRect orientedRect = originalRect;
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat x = originalRect.origin.x;
        CGFloat y = originalRect.origin.y;
        CGFloat width = originalRect.size.width;
        CGFloat height = originalRect.size.height;
        
        // 在Portrait模式下, 该frame距离四周的距离
        CGFloat offsetTop = y;
        CGFloat offsetBottom = screenHeight - y - height;
        CGFloat offsetLeft = x;
        CGFloat offsetRight = screenWidth - x - width;
        
        switch (orientation) {
            case UIInterfaceOrientationUnknown: {
                // do nothing...
                break;
            }
            case UIInterfaceOrientationPortrait: {
                // do nothing...
                break;
            }
            case UIInterfaceOrientationPortraitUpsideDown: {
                // 4s keyboard
                // end frame    {{0, 0}, {320, 202}}
                // must be      {{0, 480 - 202}, {320, 202}}
                
                orientedRect = CGRectMake(offsetRight, offsetBottom, width, height);
                
                break;
            }
            case UIInterfaceOrientationLandscapeLeft: {
                // 4s keyboard
                // end frame    {{162, 0}, {158, 480}}
                // must be      {{0, 320 - 158}, {480, 158}}
                
                orientedRect = CGRectMake(offsetBottom, offsetLeft, height, width);
                break;
            }
            case UIInterfaceOrientationLandscapeRight: {
                // 4s keyboard
                // end frame    {{0, 0}, {158, 480}}
                // must be      {{0, 320 - 158}, {480, 158}}
                
                orientedRect = CGRectMake(offsetTop, offsetRight, height, width);
                break;
            }
        }
        
    }
    
    return orientedRect;
}

- (void)_scrollWithOffsetY:(CGFloat)offsetY durtion:(NSTimeInterval)animationDurtion {
    __weak UIScrollView *scrollView = (UIScrollView *)self.avoidingView;
    
    CGPoint point = CGPointMake(scrollView.contentOffset.x, offsetY);
    
    [UIView animateWithDuration:animationDurtion delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    
        NSLog(@"\r\n\r\n_scrollWithOffsetY %@ --- \r\n\r\n", scrollView.delegate);
        
        scrollView.contentOffset = point;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (nullable UIView *)_currentTriggerView {
    if (self.triggerViews.count >= self.currentTriggerViewIndex + 1) {
        return self.triggerViews[self.currentTriggerViewIndex];
    } else {
        return nil;
    }
}

- (UIInterfaceOrientation)_currentInterfaceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)_moveUIScrollViewWithAnimationDurtion:(NSTimeInterval)animationDurtion keyboardFrameEnd:(CGRect)keyboardFrameEnd {
    
    // 计算是否需要移动avoidingView
    UIView *currentTriggerView = [self _currentTriggerView];
    CGRect triggerViewRectInWindow = [currentTriggerView convertRect:currentTriggerView.bounds toView:nil];
    
    // iOS7 下 convertRect to window 同样一直是Portrait模式下的坐标，需要转换
    triggerViewRectInWindow = [self _getOrientedRect:triggerViewRectInWindow];
    
    CGFloat triggerViewMaxY = 0;
    
    // triggerView在屏幕中并没有完全显示的时候，且avoidingView 是普通的UIScrollView，移动的最大距离是MaxY
    triggerViewMaxY = CGRectGetMaxY(triggerViewRectInWindow);
    
    CGFloat offsetY = triggerViewMaxY + _keyboardAvoiding.padding - CGRectGetMinY(keyboardFrameEnd);
    
    YOSLog(@"\r\n\r\n offsetY : %f \r\n\r\n", offsetY);
    
    // avoidingView需要移动(avoidingView是UIScrollView)
    UIScrollView *scrollView = (UIScrollView *)self.avoidingView;
    
    if (self.isKeyboardVisible) {
        
        self.scrollViewOffsetY = scrollView.contentOffset.y;
        
        // offsetY > 0 triggerView会被键盘遮盖，肯定移动
        // offsetY < 0 在triggerView 没有完全在avoidingView中显示的情况下会移动，移动到triggerView正好出现在屏幕上
        if (offsetY < 0) {
            CGFloat contentOffsetY = scrollView.contentOffset.y;
            CGFloat triggerViewHeight = [self _currentTriggerView].frame.size.height;
            CGFloat triggerOffsetMaxY = CGRectGetMaxY([self _currentTriggerView].frame);
            CGFloat scrollViewInsetY = scrollView.contentInset.top;
            
            CGFloat tempOffsetY = contentOffsetY + triggerViewHeight + scrollViewInsetY - triggerOffsetMaxY;
            
            // triggerView 没有完全在avoidingView中显示
            if (tempOffsetY > 0) {
                offsetY = -tempOffsetY;
                offsetY = scrollView.contentOffset.y + offsetY;
                
                [self _scrollWithOffsetY:offsetY durtion:animationDurtion];
            }
        } else {
            offsetY = scrollView.contentOffset.y + offsetY;
            
            [self _scrollWithOffsetY:offsetY durtion:animationDurtion];
        }
    } else {
        
        CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height;
        
        offsetY = MIN(maxOffsetY, self.scrollViewOffsetY);
        
        [self _scrollWithOffsetY:offsetY durtion:animationDurtion];
    }
}

- (void)_moveUIViewWithAnimationDurtionn:(NSTimeInterval)animationDurtion keyboardFrameEnd:(CGRect)keyboardFrameEnd animationCurve:(UIViewAnimationCurve)animationCurve {
    
    // 计算是否需要移动avoidingView
    UIView *currentTriggerView = [self _currentTriggerView];
    CGRect triggerViewRectInWindow = [currentTriggerView convertRect:currentTriggerView.bounds toView:[UIApplication sharedApplication].keyWindow];
    
    // iOS7 下 convertRect to window 同样一直是Portrait模式下的坐标，需要转换
    triggerViewRectInWindow = [self _getOrientedRect:triggerViewRectInWindow];
    
    NSLog(@"triggerViewRectInWindow : %@", NSStringFromCGRect(triggerViewRectInWindow));
    
    CGFloat triggerViewMaxY = 0;
    
    // triggerView在屏幕中并没有完全显示的时候，且avoidingView 是普通的UIScrollView，移动的最大距离是MaxY
    triggerViewMaxY = CGRectGetMaxY(triggerViewRectInWindow);
    
    CGFloat offsetY = triggerViewMaxY + _keyboardAvoiding.padding - CGRectGetMinY(keyboardFrameEnd);
    
    YOSLog(@"\r\n\r\n offsetY : %f \r\n\r\n", offsetY);
    
    if (self.isKeyboardVisible) {
        
        [UIView animateWithDuration:animationDurtion delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            // 在上一次transform的基础上再次transform
            // 应对键盘显示时, 键盘变高或者变低的情况
            CGAffineTransform transform = _keyboardAvoiding.avoidingView.transform;
            transform = CGAffineTransformTranslate(transform, 0, -offsetY);
            _keyboardAvoiding.avoidingView.transform = transform;
            
        } completion:^(BOOL finished) {
            
        }];
    } else {
        
        UIView *avoidingView = _keyboardAvoiding.avoidingView;
        [UIView animateWithDuration:animationDurtion delay:0 options:animationCurve << 16 animations:^{
            
            avoidingView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {

        }];
    }
}

#pragma mark - deal notification

- (void)_keyboardWillChangeFrame:(NSNotification *)noti {
    
    if (!self.isTriggerView) return;
    
    if (self.lastStatusBarOrientation == UIInterfaceOrientationUnknown) {
        self.lastStatusBarOrientation = [self _currentInterfaceOrientation];
    }
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect keyboardFrameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 获取当前屏幕模式下的frame
    keyboardFrameBegin = [self _getOrientedRect:keyboardFrameBegin];
    keyboardFrameEnd = [self _getOrientedRect:keyboardFrameEnd];
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGFloat animationDurtion = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    NSLog(@"\r\n\r\n statusBarOrientation - %zi \r\n\r\n", [[UIApplication sharedApplication] statusBarOrientation]);
    
    CGSize screenSize = [self _screenSize];
    
    // if split keyboard is being dragged, then skip notification
    if (keyboardFrameEnd.size.height == 0 && !IS_PHONE) {
        if (![self _isLandscape] && keyboardFrameBegin.origin.y + keyboardFrameBegin.size.height == screenSize.height) {
            return;
        } else if (![self _isLandscape] && keyboardFrameBegin.origin.x + keyboardFrameBegin.size.width == screenSize.width) {
            return;
        }
    }
    
    YOSLog(@"\r\n\r\n screenSize : %@ \r\n\r\n", NSStringFromCGSize(screenSize));
    
    // 判断 keyboard 即将显示 or 隐藏
    BOOL isKeyboardShowing = (keyboardFrameEnd.origin.y < screenSize.height);
    
    // 搜狗之类的第三方键盘, 弹出键盘的时候会触发3次will change通知
    // 第三次才是有效数据
    // 类似这样:
    // 1. {{0, 568}, {320, 0}}
    // 1. {{0, 352}, {320, 216}}
    // 1. {{0, 286}, {320, 282}}
    
    YOSLog(@"\r\n\r\n end frame : %@ --- avoidingView frame : %@ \r\n\r\n", NSStringFromCGRect(keyboardFrameEnd), NSStringFromCGRect(self.avoidingView.frame));
    
    static NSUInteger notificationCount = 0;
    static BOOL isOtherKeyboard = NO;
    if (keyboardFrameEnd.size.height == 0) {
        isOtherKeyboard = YES;
    }
    
    if (isOtherKeyboard) {
        notificationCount++;
        notificationCount = notificationCount % 3;
    }
    
    if (notificationCount == 0) {
        if (isKeyboardShowing) {
            _keyboardAvoiding.lastNotification = noti;
        }
        
        _keyboardAvoiding.isKeyboardVisible = isKeyboardShowing;
        
        isOtherKeyboard = NO;
    } else {
        // 第1,2 次通知直接略过
        return;
    }
    
    BOOL avoidingViewIsScrollView = [self.avoidingView isKindOfClass:[UIScrollView class]];
    
    if (avoidingViewIsScrollView) {
        
        [self _moveUIScrollViewWithAnimationDurtion:animationDurtion keyboardFrameEnd:keyboardFrameEnd];
        
    } else {
        
        [self _moveUIViewWithAnimationDurtionn:animationDurtion keyboardFrameEnd:keyboardFrameEnd animationCurve:animationCurve];
        
    }
    
}

- (void)_touchView:(NSNotification *)noti {
    UIView *view = noti.object;
    
    [self.triggerViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (obj == view) {
            self.isTriggerView = YES;
            
            self.currentTriggerViewIndex = idx;
            
            if (self.currentTriggerViewIndex == 0) {
                [self.toolbar disableLeftButton];
            } else {
                [self.toolbar enableLeftButton];
            }
            
            if (self.currentTriggerViewIndex + 1 == self.triggerViews.count) {
                [self.toolbar disableRightButton];
            } else {
                [self.toolbar enableRightButton];
            }

            if (_lastNotification) {
                [self _keyboardWillChangeFrame:_lastNotification];
            }
            
            *stop = YES;
        } else if ((idx + 1) == self.triggerViews.count) {
            self.isTriggerView = NO;
        }
        
    }];
}

@end
