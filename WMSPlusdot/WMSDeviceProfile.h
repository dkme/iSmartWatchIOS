//
//  WMSDeviceProfile.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSBleControl;

typedef NS_ENUM(NSUInteger, DeviceWorkStatus) {
    DeviceWorkStatusNormal = 1,
    DeviceWorkStatusMonitorSleepQuality = 2,
};

typedef NS_ENUM(NSUInteger, SleepStatus) {
    SleepStatusDeep = 0x01,
    SleepStatusLight = 0x02,
    SleepStatusWakeup = 0x03,
};

//Block
typedef void(^readDeviceInfoCallBack)(NSUInteger batteryEnergy,NSUInteger version,NSUInteger todaySteps,NSUInteger todaySportDurations,NSUInteger endSleepMinute,NSUInteger endSleepHour,NSUInteger sleepDurations,DeviceWorkStatus workStatus,BOOL success);
typedef void(^readDeviceTimeCallBack)(NSString *dateString,BOOL success);

/**
 参数:PerHourData 每个小时的运动数据，从00:00到第二天00:00
 */
typedef void (^syncDeviceSportDataCallBack)(NSString *sportdate,NSUInteger todaySteps,NSUInteger todaySportDurations,NSUInteger surplusDays,UInt16 *PerHourData,NSUInteger dataLength);
/**
 参数:startedMinutes  距离开始的时间
    startedStatus     睡眠状态，参考 SleepStatus
    statusDurations   这个状态持续的时间
    dataLength        数据的长度
 */
typedef void (^syncDeviceSleepDataCallBack)(NSString *sleepDate,NSUInteger sleepEndHour,NSUInteger sleepEndMinute,NSUInteger todaySleepMinute,NSUInteger todayAsleepMinute,NSUInteger awakeCount,NSUInteger deepSleepMinute,NSUInteger lightSleepMinute,UInt16 *startedMinutes,UInt8 * startedStatus,UInt8 *statusDurations,NSUInteger dataLength);

@interface WMSDeviceProfile : NSObject

/**
 初始化方法
 */
- (id)initWithBleControl:(WMSBleControl *)bleControl;

/**
 获取设配信息
 */
- (void)readDeviceInfoWithCompletion:(readDeviceInfoCallBack)aCallBack;

/**
 获取设备时间
 */
- (void)readDeviceTimeWithCompletion:(readDeviceTimeCallBack)aCallBack;

/**
 同步运动数据
 */
- (void)syncDeviceSportDataWithCompletion:(syncDeviceSportDataCallBack)aCallBack;

/**
 同步睡眠数据
 */
- (void)syncDeviceSleepDataWithCompletion:(syncDeviceSleepDataCallBack)aCallBack;

/**
 寻找手机
 */
//- (void)aa;

@end
