//
//  WMSHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-11-14.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSHelper : NSObject

+ (NSString *)describeWithDate:(NSDate *)date andFormart:(NSString *)formart;

/*
 读取当天的目标步数
 */
+ (NSUInteger)readTodayTargetSteps;

/*
 保存当天的目标步数
 */
+ (BOOL)savaTodayTargetSteps:(NSUInteger)steps;

/*
 清除缓存
 */
+ (void)clearCache;

/*
 判断是否第一次启动app
 */
+ (BOOL)isFirstLaunchApp;
+ (void)finishFirstLaunchApp;

/*
 监测是否可以更新
 */
+ (void)checkUpdate:(void(^)(BOOL isCanUpdate,NSString *strURL))aCallBack;

@end
