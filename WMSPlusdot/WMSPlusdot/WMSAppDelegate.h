//
//  WMSAppDelegate.h
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSBluetooth.h"
#import "WMSFileMacro.h"
#import "RESideMenu.h"

extern NSString *const WMSAppDelegateReSyncData;
extern NSString *const WMSAppDelegateNewDay;

@interface WMSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *loginNavigationCtrl;

@property (nonatomic, strong) RESideMenu *reSideMenu;

@property (nonatomic, strong) WMSBleControl *wmsBleControl;


+ (WMSAppDelegate *)appDelegate;

@end
