//
//  WMSHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-11-14.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSHelper.h"
#import "NSDate+Formatter.h"
#import "WMSFileMacro.h"
#import "WMSConstants.h"
#import "WMSURLMacro.h"
#import "WMSDeviceModel.h"
#import "WMSHTTPRequest.h"

@implementation WMSHelper

+ (NSString *)describeWithDate:(NSDate *)date andFormart:(NSString *)formart
{
    switch ([NSDate compareDate:date]) {
        case NSDateModeToday:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeYesterday:
            return NSLocalizedString(@"Yesterday",nil);
        case NSDateModeTomorrow:
            return NSLocalizedString(@"Tomorrow",nil);
        case NSDateModeUnknown:
            return [NSDate stringFromDate:date format:formart];
        default:
            return nil;
    }
    return nil;
}

+ (NSUInteger)readTodayTargetSteps
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_TARGET)];
    //NSString *key = [NSDate stringFromDate:[NSDate systemDate] format:@"yyyy-MM-dd"];
    NSString *key = @"TargetSteps";
    NSNumber *value = [readData objectForKey:key];
    NSUInteger target = 0;
    if (readData==nil || value==nil) {
        target = DEFAULT_TARGET_STEPS;
    } else {
        target = [value unsignedIntegerValue];
    }
    return target;
}

+ (BOOL)savaTodayTargetSteps:(NSUInteger)steps
{
    //NSString *key = [NSDate stringFromDate:[NSDate systemDate] format:@"yyyy-MM-dd"];
    NSString *key = @"TargetSteps";
    NSDictionary *writeData = @{key:@(steps)};
    return [writeData writeToFile:FilePath(FILE_TARGET) atomically:YES];
}

+ (void)clearCache
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *files = @[FILE_TARGET,FILE_SETTINGS,FILE_REMIND,FILE_REMIND_WAY];
        for (NSString *file in files) {
            NSString *path = FilePath(file);
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
    });
}

+ (BOOL)isFirstLaunchApp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return ![userDefaults boolForKey:@"isFirst"];
}
+ (void)finishFirstLaunchApp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"isFirst"];
}

+ (void)checkUpdate:(void(^)(BOOL isCanUpdate,NSString *strURL))aCallBack
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    double curVersion = [currentVersion doubleValue];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        NSDictionary *appInfo = [self appInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (appInfo) {
                double newVersion = [[appInfo objectForKey:@"version"] doubleValue];
                NSString *appOpenLink = [appInfo objectForKey:@"trackViewUrl"];
                if (aCallBack) {
                    if (newVersion > curVersion) {
                        aCallBack(YES,appOpenLink);
                    } else {
                        aCallBack(NO,appOpenLink);
                    }
                }
            } else {
                if (aCallBack) {
                    aCallBack(NO,nil);
                }
            }
        });
    });
}
//从iTunes获取最新的app信息
+ (NSDictionary *)appInfo
{
    NSString *urlString = URL_APP_INFO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:URL_REQUEST_TIMEOUT_INTERVAL];
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
        } else {
            DEBUGLog(@"not data or error");
        }
    } else {
        return nil;
    }
    return nil;
}

+ (BOOL)isUpdateFirmware
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"isUpdateFirmware"];
}
+ (NSString *)firmwareUpdateDesc
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *desc = [userDefaults stringForKey:@"UpdateFirmwareDesc"];
    if (desc) {
        return desc;
    } else {
        return nil;
    }
}
+ (NSString *)firmwareUpdateURL
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *URL = [userDefaults stringForKey:@"UpdateFirmwareRUL"];
    if (URL) {
        return URL;
    } else {
        return nil;
    }
}
+ (void)checkFirmwareUpdate:(void(^)(BOOL isCanUpdate))aCallBack
{
    [WMSHTTPRequest detectionFirmwareUpdate:^(double newVersion, NSString *describe, NSString *strURL)
     {
         if (aCallBack) {
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             if ([WMSDeviceModel deviceModel].version < newVersion) {
                 [userDefaults setBool:YES forKey:@"isUpdateFirmware"];
                 aCallBack(YES);
             } else {
                 [userDefaults setBool:NO forKey:@"isUpdateFirmware"];
                 aCallBack(NO);
             }
         }
     }];
}

@end
