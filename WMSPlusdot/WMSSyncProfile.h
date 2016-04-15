//
//  WMSSyncProfile.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/9.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSBleControl;

typedef void(^syncSportDataCallback)(NSDate *date, NSUInteger steps, NSUInteger distance, NSUInteger calories, NSUInteger durations, NSUInteger notSyncDays);
typedef void (^syncSleepDataCallBack)(NSDate *date,NSInteger year,NSInteger month,NSInteger day,NSInteger deepSleepMinute,NSInteger lightSleepMinute,NSInteger noSyncDay);

@interface WMSSyncProfile : NSObject


- (id)initWithBleControl:(WMSBleControl *)bleControl;

///同步运动数据
- (void)syncSportData:(syncSportDataCallback)aCallback;
///同步睡眠数据
- (void)syncSleepData:(syncSleepDataCallBack)aCallback;
@end
