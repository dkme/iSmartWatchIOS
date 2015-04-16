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

//遥控模式下的数据类型
typedef NS_ENUM(NSUInteger, RemoteDataType) {
    RemoteDataTypeFindPhone = 0x01,
    RemoteDataTypeTakephoto = 0x02,
};

//电池类型
typedef NS_ENUM(NSUInteger, BatteryType) {
    BatteryTypeRechargeable = 0x00,
    BatteryTypeCR2032Button,
    BatteryTypeCR2430Button,
};
//电池状态
typedef NS_ENUM(NSUInteger, BatteryStatus) {
    BatteryStatusNormal = 0x00,
    BatteryStatusCharging,
};


//Block
typedef void(^readDeviceInfoCallBack)(NSUInteger energy,NSUInteger version,NSUInteger todaySteps,NSUInteger todaySportDurations,DeviceWorkStatus workStatus, NSUInteger deviceID,BOOL isPaired);
typedef void(^readDeviceTimeCallBack)(NSString *dateString,BOOL success);

/**
 参数:PerHourData 每个小时的运动数据，从00:00到第二天00:00
    todaySportDurations 单位min
 */
typedef void (^syncDeviceSportDataCallBack)(NSString *sportdate,NSUInteger todaySteps,NSUInteger todaySportDurations,NSUInteger surplusDays,UInt16 *PerHourData,NSUInteger dataLength);
/**
 参数:
    startedMinutes    距离开始的时间
    startedStatus     睡眠状态，参考 SleepStatus
    statusDurations   这个状态持续的时间
    dataLength        数据的长度
 */
typedef void (^syncDeviceSleepDataCallBack)(NSString *sleepDate,NSUInteger sleepEndHour,NSUInteger sleepEndMinute,NSUInteger todaySleepMinute,NSUInteger todayAsleepMinute,NSUInteger awakeCount,NSUInteger deepSleepMinute,NSUInteger lightSleepMinute,UInt16 *startedMinutes,UInt8 * startedStatus,UInt8 *statusDurations,NSUInteger dataLength);

typedef void (^readDeviceRemoteDataCallBack)(RemoteDataType dataType);

typedef void (^readDeviceMacCallBack)(NSString *mac);
typedef void (^readDeviceBatteryInfoCallBack)(BatteryType type,BatteryStatus status,float voltage,float percentage);

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
 读取遥控模式下的数据
 */
- (void)readDeviceRemoteDataWithCompletion:(readDeviceRemoteDataCallBack)aCallBack;

/*
 读取设备的mac地址
 */
- (void)readDeviceMac:(readDeviceMacCallBack)aCallback;

/*
 *  读取设备的电池信息
 */
- (void)readDeviceBatteryInfo:(readDeviceBatteryInfoCallBack)aCallback;

@end
