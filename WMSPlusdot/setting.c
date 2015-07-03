//
//  setting.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "setting.h"
#include "production.h"
#include <string.h>

int mySetupPackage(BLE_UInt8 cmd, BLE_UInt8 key, BLE_UInt8 value_len, BLE_SInt8 *value, BLE_SInt8 **package);



int setTime(BLE_UInt16 year, BLE_UInt8 month, BLE_UInt8 day, BLE_UInt8 hour, BLE_UInt8 minute, BLE_UInt8 second, BLE_UInt8 weekDay, BLE_UInt8 **package)
{
    BLE_UInt8 value[8] = {0};
    value[0] = (year & 0xFF00) >> 8;
    value[1] = year & 0xFF;
    value[2] = month;
    value[3] = day;
    value[4] = hour;
    value[5] = minute;
    value[6] = second;
    value[7] = weekDay;
    return setupPackage(CMD_setting, SetTime, 8, value, package);
}



int setUserInfo(GenderType sex, BLE_UInt8 age, BLE_UInt16 height, BLE_UInt16 weight, BLE_UInt8 **package)
{
    BLE_UInt8 value[7] = {0};
    value[0] = sex;
    value[1] = age;
    value[2] = (height & 0xFF00) >> 8;
    value[3] = height & 0xFF;
    value[4] = (weight & 0xFF00) >> 8;
    value[5] = weight & 0xFF;
    return setupPackage(CMD_setting, SetUserInfo, 7, value, package);
}

int setTarget(BLE_UInt32 target, BLE_UInt8 **package)
{
    BLE_UInt8 value[4] = {0};
    value[0] = (target & 0xFF000000) >> 24;
    value[1] = (target & 0xFF0000) >> 16;
    value[2] = (target & 0xFF00) >> 8;
    value[3] = target & 0xFF;
    return setupPackage(CMD_setting, SetTarget, 4, value, package);
}

int setLost(BLE_UInt8 openOrClose, BLE_UInt8 interval, BLE_UInt8 **package)
{
    BLE_UInt8 value[2] = {0};
    value[0] = interval;
    value[1] = openOrClose;
    return setupPackage(CMD_setting, SetLost, 2, value, package);
}

int setSitting(BLE_UInt8 openOrClose, BLE_UInt8 duration, BLE_UInt8 startHour, BLE_UInt8 endHour, BLE_UInt8 dayFlags, BLE_UInt8 **package)
{
    BLE_UInt8 value[6] = {0};
    value[1] = openOrClose;
    value[2] = duration;
    value[3] = startHour;
    value[4] = endHour;
    value[5] = dayFlags;
    return setupPackage(CMD_setting, SetSitting, 6, value, package);
}

int setRemindWay(RemindWay way, BLE_UInt8 **package)
{
    BLE_UInt8 value[2] = {0};
    value[1] = way;
    return setupPackage(CMD_setting, SetRemindWay, 2, value, package);
}

int setStartRemind(RemindEvents event, BLE_UInt8 **package)
{
    BLE_UInt8 value[3] = {0};
    value[1] = (event & 0xFF00) >> 8;
    value[2] = event & 0xFF;
    return setupPackage(CMD_setting, SetStartRemind, 3, value, package);
}

int setStopRemind(RemindEvents event, BLE_UInt8 **package)
{
    BLE_UInt8 value[3] = {0};
    value[1] = (event & 0xFF00) >> 8;
    value[2] = event & 0xFF;
    return setupPackage(CMD_setting, SetStopRemind, 3, value, package);
}

int setRemindEvent(RemindEvents event, BLE_UInt8 **package)
{
    BLE_UInt8 value[3] = {0};
    value[1] = (event & 0xFF00) >> 8;
    value[2] = event & 0xFF;
    return setupPackage(CMD_setting, SetRemindEvent, 3, value, package);
}

int setWeather(WeatherType weather, BLE_SInt8 temp, TempUnit tempUnit, BLE_UInt8 humidity, BLE_SInt8 **package)
{
    BLE_SInt8 value[5] = {0};
    value[0] = weather;
    value[1] = temp;
    value[2] = tempUnit;
    value[3] = humidity;
    return mySetupPackage(CMD_setting, SetWeather, 5, value, package);
}

int adjustTime(ROTATE_DIRECTION direction, BLE_UInt8 **package)
{
    BLE_UInt8 value[1] = {0};
    value[0] = direction;
    return setupPackage(CMD_setting, SetAdjustTime, 1, value, package);
}

int setAlarmClock(BLE_UInt8 clockID, BLE_UInt8 hour, BLE_UInt8 minute, BLE_UInt8 dayFlags, BLE_UInt8 openOrClose, BLE_UInt8 interval, BLE_UInt8 **package)
{
    BLE_UInt8 value[7] = {0};
    value[0] = clockID;
    value[1] = hour;
    value[2] = minute;
    value[3] = dayFlags;
    value[4] = openOrClose;
    value[5] = interval;
    return setupPackage(CMD_setting, SetAlarmClock, 7, value, package);
}

int setSearchDevice(BLE_UInt8 openOrClose, BLE_UInt8 **package)
{
    BLE_UInt8 value[1] = {0};
    value[0] = openOrClose;
    return setupPackage(CMD_setting, SetSearchDevice, 1, value, package);
}



///private
int mySetupPackage(BLE_UInt8 cmd, BLE_UInt8 key, BLE_UInt8 value_len, BLE_SInt8 *value, BLE_SInt8 **package)
{
    memset(*package, 0, PACKAGE_LENGTH);
    *(*package+0) = cmd;
    *(*package+1) = (PROTOCOL_VERSION & 0x0F);
    *(*package+2) = key;
    *(*package+3) = 0;
    *(*package+4) = value_len;
    
    for (int j=0; j<value_len; j++) {
        *(*package+(j+5)) = value[j];
    }
    return HANDLE_OK;
}

