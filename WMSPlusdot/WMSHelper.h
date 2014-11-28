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
 @parm
    distance 单位为cm
    返回值 单位为m/km
 */
+ (NSUInteger)distance:(NSUInteger)distance;

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

@end
