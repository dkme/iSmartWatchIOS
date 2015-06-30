//
//  BLEUtils.h
//  WMSPlusdot
//
//  Created by Sir on 15-4-14.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

//timeID
typedef NS_ENUM(int, TimeID) {
    /******new*******/
    TimeIDEnableNotifyForSerialPortReadCharacteristic = 1000,
    TimeIDEnableNotifyForBatteryCharacteristic,
    
    ///Control
    TIME_ID_BIND_DEVICE,
    TIME_ID_UNBIND_DEVICE,
    TIME_ID_SWITCH_MODE,
    
    ///device profile
    TIME_ID_READ_DEVICE_FIRM_NAME,
    TIME_ID_READ_DEVICE_PRODUCT_MODEL,
    TIME_ID_READ_DEVICE_HARDWARE_VERSION,
    TIME_ID_READ_DEVICE_FIRMWARE_VERSION,
    TIME_ID_READ_DEVICE_SOFTWARE_VERSION,
    TIME_ID_READ_DEVICE_MAC_ADDRESS,
    TIME_ID_READ_DEVICE_BATTERY_INFO,
    
    ///setting profile
    TIME_ID_SETTING_ADJUST_DATE,
    TIME_ID_SETTING_SET_USER_INFO,
    TIME_ID_SETTING_SET_SPORT_TARGET,
    TIME_ID_SETTING_SET_LOST,
    TIME_ID_SETTING_SET_SITTING,
    TIME_ID_SETTING_SET_REMIND_WAY,
    TIME_ID_SETTING_SET_START_REMIND,
    TIME_ID_SETTING_SET_STOP_REMIND,
    TIME_ID_SETTING_SET_REMIND_EVENT,
    TIME_ID_SETTING_SET_WEATHER,
    TIME_ID_SETTING_ADJUST_TIME,
    TIME_ID_SETTING_ALARM_CLOCK,
};

//超时设置
static const NSUInteger MAX_TIMEOUT_COUNT                           = 5;
static const NSUInteger SUBSCRIBE_CHARACTERISTICS_INTERVAL          = 2;
static const NSUInteger WRITEVALUE_CHARACTERISTICS_INTERVAL         = 2;
#define KEY_TIMEOUT_USERINFO_CHARACT    @"KEY_TIMEOUT_USERINFO_CHARACT"
#define KEY_TIMEOUT_USERINFO_VALUE      @"KEY_TIMEOUT_USERINFO_VALUE"




