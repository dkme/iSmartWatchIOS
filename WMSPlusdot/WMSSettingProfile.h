//
//  WMSSettingProfile.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSBleControl;

//
typedef NS_ENUM(Byte, GenderType) {
    GenderTypeWoman = 0,
    GenderTypeMan,
    GenderTypeOther,
};

typedef NS_ENUM(Byte, LengthUnitType) {
    LengthUnitTypeMetricSystem = 0,
    LengthUnitTypeBritishSystem,
};

typedef NS_ENUM(NSUInteger, RemindMode) {
    RemindModeNot = 0x00,
    RemindModeShake = 0x01,
    RemindModeBell = 0x02,
    RemindModeBellAndShake = 0x03,
};

//提醒事件类型
typedef NS_ENUM(NSUInteger, RemindEventsType) {
    RemindEventsTypeSMS = 0x01 << 0,
    RemindEventsTypeCall = 0x01 << 1,
    RemindEventsTypeEmail = 0x01 << 2,
    RemindEventsTypeQQ = 0x01 << 3,
    RemindEventsTypeWeixin = 0x01 << 4,
    RemindEventsTypeSinaWeibo = 0x01 << 5,
    RemindEventsTypeFacebook = 0x01 << 6,
    RemindEventsTypeTwitter = 0x01 << 7,
};

//其他提醒事件类型
typedef NS_ENUM(NSUInteger, OtherRemindType) {
    OtherRemindTypeCall = 0x01,
    OtherRemindTypeSearchWatch = 0x10,
    OtherRemindTypeLowBattery = 0x11,
};


//Block
typedef void (^setCurrentDateCallBack)(BOOL success);
typedef void (^setPersonInfoCallBack)(BOOL success);
typedef void (^setAlarmClockCallBack)(BOOL success);
typedef void (^setTargetCallBack)(BOOL success);
typedef void (^setRemindModeCallBack)(BOOL success);
typedef void (^setRemindEventsCallBack)(BOOL success);
typedef void (^setRemindEventsAndModeCallBack)(BOOL success);
typedef void (^setOtherRemindCallBack)(BOOL success);
typedef void (^setStartLowBatteryRemind)(BOOL success);
typedef void (^setStopLowBatteryRemind)(BOOL success);
typedef void (^setSportRemindCallBack)(BOOL success);
typedef void (^setAntiLostCallBack)(BOOL success);
typedef void (^startRemind)(BOOL success);
typedef void (^finishRemind)(BOOL success);

@interface WMSSettingProfile : NSObject

/**
 初始化方法
 */
- (id)initWithBleControl:(WMSBleControl *)bleControl;

/**
 设置当前系统时间
 */
- (void)setCurrentDate:(NSDate *)date
            completion:(setCurrentDateCallBack)aCallBack;

/**
 描述:设置个人信息
 参数:birthday   出生日期字符串
     format     日期的格式
     weight     单位kg
     height     单位cm
     stride     单位cm
 */
- (void)setPersonInfoWithWeight:(UInt16)weight
                     withHeight:(Byte)height
                     withGender:(GenderType)gender
                   withBirthday:(NSString *)birthday
                 withDateFormat:(NSString *)format
                     withStride:(Byte)stride
                     withMetric:(LengthUnitType)metric
                 withCompletion:(setPersonInfoCallBack)aCallBack;

/**
 描述:设置闹钟时间
 参数:no  闹钟编号，取值1-10
     repeat 重复状态
 */
- (void)setAlarmClockWithId:(Byte)no
                   withHour:(Byte)hour
                 withMinute:(Byte)minute
                 withStatus:(BOOL)openOrClose
                  withRepeat:(Byte *)repeat
                 withLength:(NSUInteger)length
           withSnoozeMinute:(Byte)snoozeMinute
             withCompletion:(setAlarmClockCallBack)aCallBack;

/**
 设置目标
 */
- (void)setTargetWithStep:(UInt32)step
          withSleepMinute:(UInt16)minute
           withCompletion:(setTargetCallBack)aCallBack;

/**
 设置提醒方式
 */
- (void)setRemindWithMode:(RemindMode)remindMode
           withCompletion:(setRemindModeCallBack)aCallBack;

/**
 提醒事件
 */
- (void)setRemindEventsType:(RemindEventsType)remindEventsType
                 completion:(setRemindEventsCallBack)aCallBack;

/**
 设置提醒方式和提醒事件
 */
- (void)setRemindEventsType:(RemindEventsType)remindEventsType
                       mode:(RemindMode)remindMode
                 completion:(setRemindEventsAndModeCallBack)aCallBack;

/**
 设置其他提醒
 */
- (void)setOtherRemind:(OtherRemindType)remindType
            completion:(setOtherRemindCallBack)aCallBack;//弃用

/**
 开起低电量提醒
 */
- (void)setStartLowBatteryRemindCompletion:(setStartLowBatteryRemind)aCallBack;//弃用
/**
 停止低电量提醒
 */
- (void)setStopLowBatteryRemindCompletion:(setStopLowBatteryRemind)aCallBack;//弃用

/**
 开始提醒
 */
- (void)startRemind:(OtherRemindType)remindType
         completion:(startRemind)aCallBack;
/**
 结束提醒
 */
- (void)finishRemind:(OtherRemindType)remindType
         completion:(finishRemind)aCallBack;



/**
 久坐运动提醒
 */
- (void)setSportRemindWithStatus:(BOOL)openOrClose
                       startHour:(Byte)startHour
                     startMinute:(Byte)startMinute
                         endHour:(Byte)endHour
                       endMinute:(Byte)endMinute
                  intervalMinute:(UInt16)intervalMinute
                         repeats:(NSArray *)repeats
                      completion:(setSportRemindCallBack)aCallBack;

/**
 防丢提醒
 */
- (void)setAntiLostStatus:(BOOL)openOrClose
                 distance:(NSUInteger)distance
               completion:(setAntiLostCallBack)aCallBack;//弃用
- (void)setAntiLostStatus:(BOOL)openOrClose
                 distance:(NSUInteger)distance
             timeInterval:(NSUInteger)interval
               completion:(setAntiLostCallBack)aCallBack;

@end
