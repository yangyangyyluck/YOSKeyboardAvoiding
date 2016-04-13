//
//  YOSKeyboardAvoidingConst.h
//  keyboardAvoidingTest
//
//  Created by yangyang on 16/4/7.
//  Copyright © 2016年 yy.inc. All rights reserved.
//

#ifndef YOSKeyboardAvoidingConst_h
#define YOSKeyboardAvoidingConst_h

#import <UIKit/UIKit.h>

#ifndef DEBUG
    #define YOSLog(...) NSLog(__VA_ARGS__)
#else
    #define YOSLog(...)
#endif

// 图片路径
#define YOSKeyboardAvoidingImageName(file) [@"YOSKeyboardAvoiding.bundle" stringByAppendingPathComponent:file]

#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif

#ifndef IS_PHONE
#define IS_PHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#endif


UIKIT_EXTERN NSString *const YOSTouchViewNotification;

#endif /* YOSKeyboardAvoidingConst_h */
