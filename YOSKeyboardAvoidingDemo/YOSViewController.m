//
//  ViewController.m
//  YOSKeyboardAvoidingDemo
//
//  Created by yangyang on 16/4/12.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import "YOSViewController.h"
#import "YOSScrollViewController.h"
#import "YOSKeyboardAvoiding.h"
#import "Masonry.h"

@interface YOSViewController ()

@property (nonatomic, strong) UIButton *pushButton;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITextField *tf;

@property (nonatomic, strong) UITextField *tf2;

@end

@implementation YOSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pushButton = [UIButton new];
    [self.pushButton setTitle:@"push" forState:UIControlStateNormal];
    self.pushButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.pushButton];
    [self.pushButton addTarget:self action:@selector(tappedPush) forControlEvents:UIControlEventTouchUpInside];
    [self.pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.top.mas_equalTo(100);
    }];
    

    UITextField *tf = [UITextField new];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tf];
    tf.backgroundColor = [UIColor yellowColor];
    self.tf = tf;
    
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pushButton.mas_bottom).offset(100);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.centerX.mas_equalTo(self.view);
    }];
    
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(150);
        make.top.mas_equalTo(tf.mas_bottom).offset(100);
    }];
    
    UITextField *tf2 = [UITextField new];
    tf2.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:tf2];
    self.tf2 = tf2;
    
    [tf2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(tf);
        make.center.mas_equalTo(self.contentView);
    }];
}

- (void)tappedPush {
    
    YOSScrollViewController *vc = [YOSScrollViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [YOSKeyboardAvoiding setAvoidingView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [YOSKeyboardAvoiding resume];
}

@end
