//
//  UITextField+YOSKeyboardAvioding.m
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/4/8.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#import "UITextField+YOSKeyboardAvioding.h"
#import "YOSKeyboardAvoidingConst.h"

@implementation UITextField (YOSKeyboardAvioding)

- (BOOL)canBecomeFirstResponder {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YOSTouchViewNotification object:self];
    
    return YES;
}

@end
