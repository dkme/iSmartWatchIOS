//
//  WMSDataManager.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-13.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSDataManager : NSObject

+ (NSArray *)loadAlarmClocks;
+ (BOOL)savaAlarmClocks:(NSArray *)clocks;

//运动提醒
+ (NSArray *)loadActivityRemind;
+ (BOOL)savaActivityRemind:(NSArray *)activities;

@end
