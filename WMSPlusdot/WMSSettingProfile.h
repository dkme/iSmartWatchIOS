//
//  WMSSettingProfile.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "setting.h"
@class WMSBleControl;

typedef void(^settingCallback)(BOOL isSuccess);

@interface WMSSettingProfile : NSObject

/**
 初始化方法
 */
- (id)initWithBleControl:(WMSBleControl *)bleControl;


///校准时间
- (void)adjustDate:(NSDate *)date
        completion:(settingCallback)aCallback;

///设置用户信息
- (void)setUserInfoWithGender:(GenderType)gender
                          age:(NSUInteger)age
                       height:(NSUInteger)height
                       weight:(NSUInteger)weight
                   completion:(settingCallback)aCallback;

///设置运动目标
- (void)setSportTarget:(NSUInteger)steps
            completion:(settingCallback)aCallback;

///设置防丢
- (void)setLost:(BOOL)openOrClose
     completion:(settingCallback)aCallback;

///设置久坐提醒
///@param repeats length为7，分别对应周一到周日，
///里面元素为BOOL类型，YES-重复，NO-不重复
- (void)setSitting:(BOOL)openOrClose
         startHour:(NSUInteger)startHour
           endHour:(NSUInteger)endHour
          duration:(NSUInteger)duration
           repeats:(NSArray *)repeats
        completion:(settingCallback)aCallback;

///设置提醒方式
- (void)setRemindWay:(RemindWay)way
          completion:(settingCallback)aCallback;

///设置提醒开始/结束
- (void)setRemind:(BOOL)startOrEnd
            event:(RemindEvents)event
       completion:(settingCallback)aCallback;

///设置提醒事件
///如：电话、短信、邮件提醒
- (void)setRemindEvent:(RemindEvents)event
            completion:(settingCallback)aCallback;

///设置天气
- (void)setWeatherType:(WeatherType)type
                  temp:(NSInteger)temp
              tempUnit:(TempUnit)unit
              humidity:(NSUInteger)humidity
            completion:(settingCallback)aCallback;

///调整手表时间
- (void)adjustTimeDirection:(ROTATE_DIRECTION)direction
                 completion:(settingCallback)aCallback;

/**
 * 设置闹钟,目前最多设置8个闹钟
 * @param no  闹钟编号，取值0-7
 * @param repeats length为7，分别对应周一到周日，
 * 里面元素为BOOL类型，YES-重复，NO-不重复
 */
- (void)setAlarmClock:(BOOL)openOrClose
                   ID:(NSUInteger)no
                 hour:(NSUInteger)hour
               minute:(NSUInteger)minute
             interval:(NSUInteger)interval
              repeats:(NSArray *)repeats
           completion:(settingCallback)aCallback;

///设置寻找手表
///不用回调
- (void)setSearchDevice:(BOOL)openOrClose;

@end
