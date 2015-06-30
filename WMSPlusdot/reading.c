//
//  reading.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "reading.h"
#include "production.h"
#include "parse.h"
#include <string.h>

int readDeviceHardwareVersion(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceHardwareVersion, 0, NULL, package);
}

int readDeviceFirmwareVersion(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceFirmwareVersion, 0, NULL, package);
}

int readDeviceSoftwareVersion(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceSoftwareVersion, 0, NULL, package);
}

int readDeviceFirm(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceFirmName, 0, NULL, package);
}

int readDeviceProductModel(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceProductModel, 0, NULL, package);
}


int readDeviceMacAddress(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceMacAddress, 0, NULL, package);
}

int readDeviceBatteryInfo(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceBatteryInfo, 0, NULL, package);
}

int readDeviceTime(BLE_UInt8 **package)
{
    return setupPackage(CMD_readDeviceInfo, ReadDeviceTime, 0, NULL, package);
}


/////////////////////////////////////////////////

float getDeviceHardwareVersion(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceHardwareVersion)) {
        return 0;
    }
    if (s_pg.value_len < 2) {
        return 0;
    }
    float version = s_pg.value[0] + s_pg.value[1] * 0.01;
    return version;
}

float getDeviceFirmwareVersion(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceFirmwareVersion)) {
        return 0;
    }
    if (s_pg.value_len < 2) {
        return 0;
    }
    float version = s_pg.value[0] + s_pg.value[1] * 0.01;
    return version;
}

float getDeviceSoftwareVersion(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceSoftwareVersion)) {
        return 0;
    }
    if (s_pg.value_len < 2) {
        return 0;
    }
    float version = s_pg.value[0] + s_pg.value[1] * 0.01;
    return version;
}

DeviceFirms getDeviceFirm(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceFirmName)) {
        return FIRM_Unknown;
    }
    if (s_pg.value_len < 2) {
        return FIRM_Unknown;
    }
    DeviceFirms firm = s_pg.value[0];
    return firm;
}

ProductModels getDeviceProductModel(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceProductModel)) {
        return MODEL_Unknown;
    }
    if (s_pg.value_len < 2) {
        return MODEL_Unknown;
    }
    ProductModels model = s_pg.value[0];
    return model;
}

Struct_MacAddress getDeviceMacAddress(BLE_UInt8 *package, BLE_UInt8 len)
{
    Struct_MacAddress result = {0};
    memset(result.mac, 0, MAC_ADDRESS_LENGTH);
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceMacAddress)) {
        return result;
    }
    if (s_pg.value_len < MAC_ADDRESS_LENGTH) {
        return result;
    }
    for (int i=0; i<MAC_ADDRESS_LENGTH; i++) {
        result.mac[i] = s_pg.value[i];
    }
    result.error = HANDLE_OK;
    return result;
}

Struct_BatteryInfo getDeviceBatteryInfo(BLE_UInt8 *package, BLE_UInt8 len)
{
    Struct_BatteryInfo result = {0};
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceBatteryInfo)) {
        return result;
    }
    if (s_pg.value_len < 2) {
        return result;
    }
    result.type = s_pg.value[0];
    result.status = s_pg.value[1];
    result.error = HANDLE_OK;
    return result;
}

Struct_Time getDeviceTime(BLE_UInt8 *package, BLE_UInt8 len)
{
    Struct_Time result = {0};
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceTime)) {
        return result;
    }
    if (s_pg.value_len < 7) {
        return result;
    }
    result.year = (s_pg.value[0] << 8) + s_pg.value[1];
    result.month = s_pg.value[2];
    result.day = s_pg.value[3];
    result.hour = s_pg.value[4];
    result.minute = s_pg.value[5];
    result.second = s_pg.value[6];
    result.error = HANDLE_OK;
    return result;
}

BLE_UInt8 getDevicePower(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDevicePower)) {
        return 0;
    }
    if (s_pg.value_len < 1) {
        return 0;
    }
    BLE_UInt8 power = s_pg.value[0];
    return power;
}





