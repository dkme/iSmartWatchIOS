//
//  UIViewController+Update.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-4.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_ID          @""//@"930839162"

typedef NS_ENUM(NSInteger, DetectResultValue) {
    DetectResultUnknown = 0x00,
    DetectResultCanUpdate = 0x01,
    DetectResultCanNotUpdate = 0x02,
};

typedef void (^isCanUpdate)(DetectResultValue isCanUpdate);

@interface UIViewController(Update)

- (DetectResultValue)isDetectedNewVersion;

- (void)checkUpdateWithAPPID:(NSString *)appID
                  completion:(isCanUpdate)aCallBack;

- (void)showUpdateAlertViewWithTitle:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelTitle
                       okButtonTitle:(NSString *)okTitle;

@end
