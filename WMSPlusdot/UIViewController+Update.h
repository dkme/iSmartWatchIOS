//
//  UIViewController+Update.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-4.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^isCanUpdate)(BOOL isCanUpdate);

@interface UIViewController(Update)

- (void)checkUpdateWithAPPID:(NSString *)appID
                  completion:(isCanUpdate)aCallBack;

- (void)showUpdateAlertViewWithTitle:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelTitle
                       okButtonTitle:(NSString *)okTitle;

@end
