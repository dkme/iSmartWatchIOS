//
//  UIViewController+Update.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-4.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "UIViewController+Update.h"
#import <objc/runtime.h>

static const void *UtilityKey;
static DetectResultValue global_DetectResult = DetectResultUnknown;
static NSString * app_url = nil;

#define URL_APP_INFO     @"http://itunes.apple.com/lookup?id="
const NSTimeInterval REQUEST_TIMEOUT_INTERVAL = 10.f;

@interface UIViewController()<UIAlertViewDelegate>
@property (nonatomic, strong) NSString *strAPPURL;
@end

@implementation UIViewController(Update)

//@dynamic strAPPURL;

#pragma mark - Getter/Setter
- (NSString *)strAPPURL
{
    return app_url;
    //return objc_getAssociatedObject(self, UtilityKey);
}
- (void)setStrAPPURL:(NSString *)str
{
    app_url = str;
    //objc_setAssociatedObject(self, UtilityKey, str, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public
- (DetectResultValue)isDetectedNewVersion
{
    return global_DetectResult;
}

- (void)checkUpdateWithAPPID:(NSString *)appID
                  completion:(isCanUpdate)aCallBack
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        NSDictionary *appInfo = [self appInfo:appID];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.strAPPURL=nil;
            if (appInfo) {
                NSString *newVersion = [appInfo objectForKey:@"version"];
                NSString *appOpenLink = [appInfo objectForKey:@"trackViewUrl"];
                self.strAPPURL = appOpenLink;
                if (aCallBack) {
                    BOOL res = [self isUpdateWithNewVersion:newVersion currentVersion:currentVersion];
                    if (res) {
                        global_DetectResult = DetectResultCanUpdate;
                        aCallBack(DetectResultCanUpdate);
                    } else {
                        global_DetectResult = DetectResultCanNotUpdate;
                        aCallBack(DetectResultCanNotUpdate);
                    }
                }
            } else {
                if (aCallBack) {
                    global_DetectResult = DetectResultUnknown;
                    aCallBack(DetectResultUnknown);
                }
            }
        });
    });
}

- (void)showUpdateAlertViewWithTitle:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelTitle
                       okButtonTitle:(NSString *)okTitle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    [alertView show];
}

#pragma mark - Private
//从iTunes获取最新的app信息
- (NSDictionary *)appInfo:(NSString *)appID
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",URL_APP_INFO,appID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIMEOUT_INTERVAL];
    if (!request) {
        return nil;
    }
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (returnData) {
        NSError *error = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingAllowFragments error:&error];
        if (jsonData && error==nil) {
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                NSArray *result = [jsonData objectForKey:@"results"];
                if (result && [result count]>0) {
                    return result[0];
                }
            }
        }
    } else {
        return nil;
    }
    return nil;
}

- (BOOL)isUpdateWithNewVersion:(NSString *)newVersion currentVersion:(NSString *)curVersion
{
    NSComparisonResult res=[curVersion compare:newVersion options:NSCaseInsensitiveSearch];
    switch (res) {
        case NSOrderedAscending://上升的
            return YES;
        default:
            return NO;
    }
    return NO;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ;
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        if (self.strAPPURL) {
            if ([application canOpenURL:[NSURL URLWithString:self.strAPPURL]]) {
                [application openURL:[NSURL URLWithString:self.strAPPURL]];
            }
        }
    }
}

@end
