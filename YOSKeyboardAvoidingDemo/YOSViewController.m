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
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pushButton = [UIButton new];
    [self.pushButton setTitle:@"push" forState:UIControlStateNormal];
    self.pushButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.pushButton];
    [self.pushButton addTarget:self action:@selector(tappedPush) forControlEvents:UIControlEventTouchUpInside];

    UITextField *tf = [UITextField new];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tf];
    tf.backgroundColor = [UIColor yellowColor];
    self.tf = tf;
    
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.contentView];
    
    UITextField *tf2 = [UITextField new];
    tf2.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:tf2];
    self.tf2 = tf2;
    
    [tf2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(tf);
        make.center.mas_equalTo(self.contentView);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 100));
        make.bottom.mas_equalTo(self.view).offset(-20);
    }];
    
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_top).offset(-20);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.bottom.mas_equalTo(tf.mas_top).offset(-20);
    }];
}

- (void)tappedPush {
    
    YOSScrollViewController *vc = [YOSScrollViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"frame : %@", NSStringFromCGRect(self.view.frame));
    
    if (CGAffineTransformIsIdentity(self.view.transform)) {
        NSLog(@"yes identity");
    } else {
        NSLog(@"no identity");
    }
    
//    [self.view setNeedsUpdateConstraints];
//    [self.view updateConstraintsIfNeeded];
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];
//    [self.view setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [YOSKeyboardAvoiding setAvoidingView:self.view];
    [YOSKeyboardAvoiding setPadding:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [YOSKeyboardAvoiding resume];
}

@end
