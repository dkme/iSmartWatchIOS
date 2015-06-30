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
    FIRM_Unknown = 0xFF,
} DeviceFirms;

//待定
typedef enum {
    MODEL_other = 0x01,
    
    MODEL_Unknown = 0xFF,
} ProductModels;

///////////////返回值///////////////////
#define MAC_ADDRESS_LENGTH      6
typedef struct {
    BLE_UInt8 mac[MAC_ADDRESS_LENGTH];
    
    HANDLE_RESULT error;
} Struct_MacAddress;

typedef struct {
    BatteryType type;
    BatteryStatus status;
    
    HANDLE_RESULT error;
} Struct_BatteryInfo;

typedef struct {
    BLE_UInt16 year;
    BLE_UInt8 month;
    BLE_UInt8 day;
    BLE_UInt8 hour;
    BLE_UInt8 minute;
    BLE_UInt8 second;
    
    HANDLE_RESULT error;
} Struct_Time;


float getDeviceHardwareVersion(BLE_UInt8 *package, BLE_UInt8 len);
float getDeviceFirmwareVersion(BLE_UInt8 *package, BLE_UInt8 len);
float getDeviceSoftwareVersion(BLE_UInt8 *package, BLE_UInt8 len);

/**
 * @return 返回值若为Unknown，则表示错误
 */
DeviceFirms getDeviceFirm(BLE_UInt8 *package, BLE_UInt8 len);
ProductModels getDeviceProductModel(BLE_UInt8 *package, BLE_UInt8 len);


Struct_MacAddress getDeviceMacAddress(BLE_UInt8 *package, BLE_UInt8 len);

Struct_BatteryInfo getDeviceBatteryInfo(BLE_UInt8 *package, BLE_UInt8 len);

Struct_Time getDeviceTime(BLE_UInt8 *package, BLE_UInt8 len);

BLE_UInt8 getDevicePower(BLE_UInt8 *package, BLE_UInt8 len);



#endif /* defined(__WMSPlusdot__reading__) */
