//
//  reading.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.

#ifndef __WMSPlusdot__reading__
#define __WMSPlusdot__reading__
#include <stdio.h>
#include "dataType.h"


int readDeviceHardwareVersion(BLE_UInt8 **package);
int readDeviceFirmwareVersion(BLE_UInt8 **package);
int readDeviceSoftwareVersion(BLE_UInt8 **package);

int readDeviceFirm(BLE_UInt8 **package);
int readDeviceProductModel(BLE_UInt8 **package);


int readDeviceMacAddress(BLE_UInt8 **package);

int readDeviceBatteryInfo(BLE_UInt8 **package);

int readDeviceTime(BLE_UInt8 **package);


//////////////////////////////////////////////////////////

typedef enum {
    BatteryTypeChargeable = 0x01,
    BatteryTypeCR2032,
    BatteryTypeCR2430,
} BatteryType;

typedef enum {
    BatteryStatusNormal = 0x01,
    BatteryStatusCharge,
} BatteryStatus;

typedef enum {
    FIRM_Nordic = 0x01,
    //...
} DeviceFirms;


int getDeviceHardwareVersion(BLE_UInt8 *package, BLE_UInt8 len, float *version);
int getDeviceFirmwareVersion(BLE_UInt8 *package, BLE_UInt8 len, float *version);
int getDeviceSoftwareVersion(BLE_UInt8 *package, BLE_UInt8 len, float *version);

int getDeviceFirm(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *firm);
int getDeviceProductModel(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *model);

/**
 mac    根据协议，长度固定为6
 */
int getDeviceMacAddress(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 **mac);

int getDeviceBatteryInfo(BLE_UInt8 *package, BLE_UInt8 len, BatteryType *type, BatteryStatus *status);

int getDeviceTime(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt16 *year, BLE_UInt8 *month, BLE_UInt8 *day, BLE_UInt8 *hour, BLE_UInt8 *minute, BLE_UInt8 *second);

int getDevicePower(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *power);



#endif /* defined(__WMSPlusdot__reading__) */
