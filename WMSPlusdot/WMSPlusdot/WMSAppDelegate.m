//
//  WMSAppDelegate.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAppDelegate.h"
#import "RESideMenu.h"
#import "WMSLoginViewController.h"
#import "WMSLeftViewController.h"
#import "WMSRightViewController.h"
#import "WMSContentViewController.h"
#import "WMSBindingAccessoryViewController.h"
#import "WMSMyAccessoryViewController.h"
#import "WMSGuideVC.h"
#import "WMSBleControl.h"

#import "WMSHelper.h"
#import "WMSPostNotificationHelper.h"
#import "WMSAppConfig.h"
#import "WMSConstants.h"

#import <AVFoundation/AVFoundation.h>

@interface WMSAppDelegate ()<RESideMenuDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation WMSAppDelegate

#pragma mark - 获取appDelegate
+ (WMSAppDelegate *)appDelegate
{
    return (WMSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UINavigationController *)loginNavigationCtrl
{
    if (!_loginNavigationCtrl) {
        WMSLoginViewController *loginVC = [[WMSLoginViewController alloc] initWithNibName:@"WMSLoginViewController" bundle:nil];
        _loginNavigationCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
        _loginNavigationCtrl.navigationBarHidden = YES;
    }
    return _loginNavigationCtrl;
}
- (RESideMenu *)reSideMenu
{
    if (!_reSideMenu) {
        RESideMenu *sideMenu = [[RESideMenu alloc] init];
        sideMenu.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
        sideMenu.contentViewShadowColor = [UIColor blackColor];
        sideMenu.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenu.contentViewShadowOpacity = 0.6;
        sideMenu.contentViewShadowRadius = 3;
        sideMenu.contentViewShadowEnabled = NO;
        sideMenu.panGestureEnabled = YES;
        
        WMSContentViewController *contentVC = [[WMSContentViewController alloc] init];
        //WMSBindingAccessoryViewController *contentVC = [[WMSBindingAccessoryViewController alloc] init];
        //WMSMyAccessoryViewController *contentVC = [[WMSMyAccessoryViewController alloc] init];
        WMSLeftViewController *leftVC = [[WMSLeftViewController alloc] init];
        WMSRightViewController *rightVC = [[WMSRightViewController alloc] init];
        
        sideMenu.contentViewController = [[UINavigationController alloc] initWithRootViewController:contentVC];
        sideMenu.leftMenuViewController = leftVC;
        sideMenu.rightMenuViewController = rightVC;
        sideMenu.backgroundImage = [UIImage imageNamed:@"main_bg.png"];
        sideMenu.delegate = self;
        
        _reSideMenu = sideMenu;
    }
    return _reSideMenu;
}

#pragma mark - 启动

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    

    [WMSPostNotificationHelper cancelAllNotification];
    
    _wmsBleControl  = [[WMSBleControl alloc] init];
    
    [self setupApp];
    
    
//    if ([WMSHelper isFirstLaunchApp]) {
//        self.window.rootViewController = [WMSGuideVC guide];
//        [self.window makeKeyAndVisible];
//        return YES;
//    }
    


    if ([WMSAppConfig isHaveLogin]) {//已经登陆过
        self.window.rootViewController = [self reSideMenu];
    } else {
        self.window.rootViewController = [self loginNavigationCtrl];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DEBUGLog(@"%s",__FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DEBUGLog(@"%s",__FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DEBUGLog(@"%s",__FUNCTION__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DEBUGLog(@"%s",__FUNCTION__);
    [WMSPostNotificationHelper resetAllNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification) {
        [WMSPostNotificationHelper resetAllNotification];
    }
}

#pragma mark - Private
- (void)setupApp
{
    //设置导航栏的颜色，标题字体和颜色
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGBAlpha(0x00D5E1, 1)];
    //[[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = UIColorFromRGBAlpha(0x000000, 0.8);
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName
                                                          , nil]];//[UIFont fontWithName:@"DIN Condensed" size:35.f],NSFontAttributeName
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
