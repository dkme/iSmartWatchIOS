//
//  setting.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__setting__
#define __WMSPlusdot__setting__

#include <stdio.h>
#include "dataType.h"

typedef enum {
    GenderTypeWoman = 0,
    GenderTypeMan,
    GenderTypeOther,
} GenderType;

typedef enum {
    RemindWayNot = 0,
    RemindWayShake,
    RemindWayBell,
    RemindWayShakeAndBell,
} RemindWay;

typedef enum {
    RemindEventCall = 0x01 << 0,
    RemindEventSMS = 0x01 << 1,
    RemindEventEmail = 0x01 << 2,
    RemindEventQQ = 0x01 << 3,
    RemindEventWeixin = 0x01 << 4,
    RemindEventSina = 0x01 << 5,
    RemindEventFacebook = 0x01 << 6,
    RemindEventTwitter = 0x01 << 7,
    RemindEventWhatsAPP = 0x01 << 8,
    RemindEventSkype = 0x01 << 9,
    RemindEventLowBattery = 0x01 << 10,
} RemindEvents;

typedef enum {
    WeatherTypeClear = 0x01,
    WeatherTypeClouds = 0x02,
    WeatherTypeLightRain,
    WeatherTypeModerateRain,
    WeatherTypeHeavyRain,
    WeatherTypeLightSnow,
    WeatherTypeModerateSnow,
    WeatherTypeHeavySnow,
} WeatherType;

typedef enum {
    TempUnitCentigrade = 0,
    TempUnitFahrenheit,
} TempUnit;

typedef enum {
    DIRECTION_clockwise           = 0,
    DIRECTION_anticlockwise       = 1,
} ROTATE_DIRECTION;



/**说明
 package    为传出参数,包的长度固定为20
 其它参数为将要设置的值
 @return    -1错误，0正确
 */


int setTime(BLE_UInt16 year, BLE_UInt8 month, BLE_UInt8 day, BLE_UInt8 hour, BLE_UInt8 minute, BLE_UInt8 second, BLE_UInt8 weekDay, BLE_UInt8 **package);

int setUserInfo(GenderType sex, BLE_UInt8 age, BLE_UInt16 height, BLE_UInt16 weight, BLE_UInt8 **package);

int setTarget(BLE_UInt32 target, BLE_UInt8 **package);

int setLost(BLE_UInt8 openOrClose, BLE_UInt8 **package);

/**
 openOrClose    0-关闭，1-打开
 duration       久坐的时长
 startHour      开始提醒时间（小时）0~23
 endHour        结束提醒时间（小时）0~23
 dayFlags       由低位到高位，依次代表从周一到周日的重复状态。Bit位为1表示重复，为0表示不重复。所有的bit为都为0时，表示只当天有效
 */
int setSitting(BLE_UInt8 openOrClose, BLE_UInt8 duration, BLE_UInt8 startHour, BLE_UInt8 endHour, BLE_UInt8 dayFlags, BLE_UInt8 **package);

int setRemindWay(RemindWay way, BLE_UInt8 **package);

int setStartRemind(RemindEvents event, BLE_UInt8 **package);
int setStopRemind(RemindEvents event, BLE_UInt8 **package);

//该接口仅供ios使用
int setRemindEvent(RemindEvents event, BLE_UInt8 **package);


int setWeather(WeatherType weather, BLE_SInt8 temp, TempUnit tempUnit, BLE_UInt8 humidity, BLE_SInt8 **package);

//0 顺时针, 1 逆时针
int adjustTime(ROTATE_DIRECTION direction, BLE_UInt8 **package);

/**
 clockID    0~7
 hour       0~23
 minute     0~59
 dayFlags   由低位到高位，依次代表从周一到周日的重复状态。Bit位为1表示重复，为0表示不重复。所有的bit为都为0时，表示只当天有效
 openOrClose    0-关闭，1-打开
 interval       提醒间隔，目前取值有10，20，30
 */
int setAlarmClock(BLE_UInt8 clockID, BLE_UInt8 hour, BLE_UInt8 minute, BLE_UInt8 dayFlags, BLE_UInt8 openOrClose, BLE_UInt8 interval, BLE_UInt8 **package);

///openOrClose，0-关闭，1-打开
int setSearchDevice(BLE_UInt8 openOrClose, BLE_UInt8 **package);

#endif /* defined(__WMSPlusdot__setting__) */
