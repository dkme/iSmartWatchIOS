//
//  dataType.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef WMSPlusdot_dataType_h
#define WMSPlusdot_dataType_h


typedef unsigned char               BLE_UInt8;
typedef signed char                 BLE_SInt8;
typedef unsigned short              BLE_UInt16;
typedef unsigned int                BLE_UInt32;
//typedef unsigned char               BLE_BOOL;///0-no，1-yes


//command列表
typedef enum {
    CMD_updateFirmware          = 0x01,
    CMD_setting,
    CMD_binding,
    CMD_remind,
    CMD_syncData,
    CMD_readDeviceInfo,
    CMD_control,
    CMD_test,
} CMD;

typedef enum {
    UpdateFirmware = 0x01,
} UpdateFirmwareKey;

typedef enum {
    SetTime = 0x01,
    SetUserInfo,
    SetTarget,
    SetLost,
    SetSitting,
    SetRemindWay,
    SetStartRemind,
    SetStopRemind,
    SetRemindEvent,
    SetWeather,
    SetAdjustTime,
    SetAlarmClock1,
    SetAlarmClock2,
    SetAlarmClock3,
    SetAlarmClock4,
    SetAlarmClock5,
    SetAlarmClock6,
    SetAlarmClock7,
    SetAlarmClock8,
    SetSearchDevice,
} SettingKey;

typedef enum {
    Binding = 0x01,
    unBinding,
} BindingKey;

typedef enum {
    ReadDeviceFirmwareVersion = 0x01,
    ReadDeviceMacAddress,
    ReadDeviceBatteryInfo,
    ReadDeviceTime,
    ReadDeviceFirmName,
    ReadDeviceProductModel,
    ReadDeviceHardwareVersion,
    ReadDeviceSoftwareVersion,
    ReadDevicePower,
} ReadDeviceInfoKey;

typedef enum {
    ControlClick = 0x01,
    ControlDoubleClick,
    ControlLongPress,
} ControlKey;

typedef enum {
    TestLED = 0x01,
    TestMotor = 0x03,
} TestKey;




#define PROTOCOL_VERSION            2//协议版本号
#define PACKAGE_LENGTH              20
#define PACKAGE_SIZE                20

typedef enum {
    HANDLE_OK = 0,
    HANDLE_FAIL,
} HANDLE_RESULT;
//#define HANDLE_OK                   0
//#define HANDLE_FAIL                 (-1)



#endif