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


////////////////////////////////////////////////

int getDeviceHardwareVersion(BLE_UInt8 *package, BLE_UInt8 len, float *version)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceHardwareVersion)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    *version = *version = s_pg.value[0] + s_pg.value[1] * 0.01;
    return HANDLE_OK;
}

int getDeviceFirmwareVersion(BLE_UInt8 *package, BLE_UInt8 len, float *version)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceFirmwareVersion)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    *version = s_pg.value[0] + s_pg.value[1] * 0.01;
    return HANDLE_OK;
}

int getDeviceSoftwareVersion(BLE_UInt8 *package, BLE_UInt8 len, float *version)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceSoftwareVersion)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    *version = s_pg.value[0] + s_pg.value[1] * 0.01;
    return HANDLE_OK;
}

int getDeviceFirm(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *firm)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceFirmName)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    *firm = s_pg.value[0];
    return HANDLE_OK;
}
int getDeviceProductModel(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *model)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceProductModel)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    *model = s_pg.value[0];
    return HANDLE_OK;
}


int getDeviceMacAddress(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 **mac)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceMacAddress)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 6) {
        return HANDLE_FAIL;
    }
    for (int i=0; i<6; i++) {
        *(*mac + i) = s_pg.value[i];
    }
    return HANDLE_OK;
}

int getDeviceBatteryInfo(BLE_UInt8 *package, BLE_UInt8 len, BatteryType *type, BatteryStatus *status)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceBatteryInfo)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    *type = s_pg.value[0];
    *status = s_pg.value[1];
    return HANDLE_OK;
}

int getDeviceTime(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt16 *year, BLE_UInt8 *month, BLE_UInt8 *day, BLE_UInt8 *hour, BLE_UInt8 *minute, BLE_UInt8 *second)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDeviceTime)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 7) {
        return HANDLE_FAIL;
    }
    *year = (s_pg.value[0] << 8) + s_pg.value[1];
    *month = s_pg.value[2];
    *day = s_pg.value[3];
    *hour = s_pg.value[4];
    *minute = s_pg.value[5];
    *second = s_pg.value[6];
    return HANDLE_OK;
}


int getDevicePower(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *power)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_readDeviceInfo, ReadDevicePower)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 1) {
        return HANDLE_FAIL;
    }
    *power = s_pg.value[0];
    return HANDLE_OK;
}







