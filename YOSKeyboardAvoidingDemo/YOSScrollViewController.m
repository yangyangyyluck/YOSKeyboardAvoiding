//
//  YOSScrollViewController.m
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/4/8.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import "YOSScrollViewController.h"
#import "Masonry.h"
#import "YOSKeyboardAvoiding.h"
#import "UITextField+YOSKeyboardAvioding.h"
#import "UITextView+YOSKeyboardAvoiding.h"

@interface YOSScrollViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation YOSScrollViewController {
    UITextField *_tf0;
    UITextField *_tf1;
    UITextField *_tf2;
    
    UITextView *_tv0;
    UITextView *_tv1;
    UITextView *_tv2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cyanColor];

    self.scrollView = [UIScrollView new];
    
    self.scrollView.delegate  = self;
    self.scrollView.backgroundColor = [UIColor purpleColor];
    
    [self.view addSubview:self.scrollView];
    
    _tf0 = [UITextField new];
    _tf0.tag = 1;
    _tf0.borderStyle = UITextBorderStyleRoundedRect;
    [self.scrollView addSubview:_tf0];
    
    [_tf0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.top.mas_equalTo(10);
    }];
    
    _tf1 = [UITextField new];
    _tf1.tag = 2;
    _tf1.borderStyle = UITextBorderStyleRoundedRect;
    [self.scrollView addSubview:_tf1];
    
    [_tf1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.top.mas_equalTo(_tf0.mas_bottom).offset(20);
    }];
    
    _tf2 = [UITextField new];
    _tf2.tag = 3;
    _tf2.borderStyle = UITextBorderStyleRoundedRect;
    [self.scrollView addSubview:_tf2];
    
    [_tf2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.top.mas_equalTo(_tf1.mas_bottom).offset(200);
    }];
    
    _tv0 = [UITextView new];
    _tv0.layer.borderWidth = 0.5;
    _tv0.layer.borderColor = [UIColor blackColor].CGColor;
    [self.scrollView addSubview:_tv0];
    
    [_tv0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 100));
        make.top.mas_equalTo(_tf2.mas_bottom).offset(30);
    }];
    
    _tv1 = [UITextView new];
    _tv1.layer.borderWidth = 0.5;
    _tv1.layer.borderColor = [UIColor blackColor].CGColor;
    [self.scrollView addSubview:_tv1];
    
    [_tv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 100));
        make.top.mas_equalTo(_tv0.mas_bottom).offset(50);
    }];
    
    _tv2 = [UITextView new];
    _tv2.layer.borderWidth = 0.5;
    _tv2.layer.borderColor = [UIColor blackColor].CGColor;
    [self.scrollView addSubview:_tv2];
    
    [_tv2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 70));
        make.top.mas_equalTo(_tv1.mas_bottom).offset(60);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero).priorityLow();
        make.bottom.mas_equalTo(_tv2.mas_bottom);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [YOSKeyboardAvoiding setAvoidingView:self.scrollView];
    [YOSKeyboardAvoiding setPadding:50];
    [YOSKeyboardAvoiding setShowToolbar:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [YOSKeyboardAvoiding resume];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat triggerViewHeight = _tf2.frame.size.height;
    CGFloat triggerOffsetMaxY = CGRectGetMaxY(_tf2.frame);
    CGFloat scrollViewInsetY = scrollView.contentInset.top;
    
    CGFloat tempOffsetY = contentOffsetY + triggerViewHeight + scrollViewInsetY - triggerOffsetMaxY;
    
    NSLog(@"\r\n\r\n contentOffsetY : %f\r\n triggerViewHeight : %f\r\n triggerOffsetMaxY : %f\r\n scrollViewInsetY : %f\r\n tempOffsetY : %f \r\n\r\n",contentOffsetY, triggerViewHeight, triggerOffsetMaxY, scrollViewInsetY, tempOffsetY);
}

- (void)dealloc {
#warning UIScrollView.delegate 一定要设置为nil, 否则可能crash, 因为在UINavgationViewController push/pop等情况下会触发键盘事件, UIView animation: 会持有一个UIScrollView的zombie object, 给改对象发送消息导致crash
    _scrollView.delegate = nil;
}

@end
