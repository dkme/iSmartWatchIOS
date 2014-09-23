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
#import "WMSBleControl.h"

@interface WMSAppDelegate ()<RESideMenuDelegate>

@end

@implementation WMSAppDelegate

#pragma mark - 获取appDelegate
+ (WMSAppDelegate *)appDelegate
{
    return (WMSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - 启动

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];


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
    
    
//    WMSLoginViewController *loginVC = [[WMSLoginViewController alloc] initWithNibName:@"WMSLoginViewController" bundle:nil];
//    
//    _navigationCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
//    _navigationCtrl.navigationBarHidden = YES;
//    
//    self.window.rootViewController = _navigationCtrl;
    
//    UIViewController *welcomeVC = [[UIViewController alloc] init];
//    welcomeVC.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@""]];
//    [loginVC presentViewController:VC animated:NO completion:nil];
    
    
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
    _wmsBleControl  = [[WMSBleControl alloc] init];
    
    
    
    self.window.rootViewController = sideMenu;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}


#pragma mark - RESideMenuDelegate
- (void)sideMenu:(RESideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    DEBUGLog(@"didRecognizePanGesture: %@", NSStringFromClass([sideMenu.contentViewController class]));
}
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    DEBUGLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
    if ([@"WMSRightViewController" isEqualToString:
         NSStringFromClass([menuViewController class])]
        ) {
        sideMenu.scaleContentView = NO;
    }
    
    //当显示“设置目标”界面时，禁用左划手势
//    if ([UINavigationController class] != [sideMenu.contentViewController class]) {
//        return ;
//    }
//    UINavigationController *nav = (UINavigationController *)sideMenu.contentViewController;
//    NSString *vcClassName = NSStringFromClass([nav.topViewController class]);
//    if ([@"WMSContent2ViewController" isEqualToString:vcClassName]) {
//        if ([@"WMSRightViewController" isEqualToString:
//             NSStringFromClass([menuViewController class])])
//        {
//            sideMenu.panGestureEnabled = NO;
//        }
//    }
}
- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    DEBUGLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
    if ([@"WMSRightViewController" isEqualToString:
         NSStringFromClass([menuViewController class])]
        ) {
        sideMenu.scaleContentView = YES;
    }
}

@end
