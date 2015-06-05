//
//  parse.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "parse.h"
#include <string.h>
#include <stdlib.h>

static const int PACKAGE_MIN_LENGTH                         = 5;
static const int VALUE_MAX_LENGTH                           = 20-5;



//int parseUpdateFirmware(BLE_UInt8 *value, BLE_UInt8 value_len, BLE_UInt8 **result);

struct_parse_package parse(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = {0};
    if (len < PACKAGE_LENGTH) {
        return s_pg;
    }
    
    BLE_UInt8 cmd = package[0];
    BLE_UInt8 version = package[1] & 0x0F;
    
    BLE_UInt8 key = package[2];
    
    //BLE_UInt16 key_header = (package[3]<<8) + package[4];
    BLE_UInt8 value_len = package[4];
    if (value_len > len - PACKAGE_MIN_LENGTH) {
        return s_pg;
    }
    
    BLE_UInt8 *value = package + PACKAGE_MIN_LENGTH;//偏移到指定位置
    
    
    s_pg.cmd = cmd;
    s_pg.protocol_version = version;
    s_pg.key = key;
    s_pg.value_len = value_len;
    for (int i=0; i<VALUE_LENGTH; i++) {
        s_pg.value[i] = value[i];
    }
    
    return s_pg;
}

//int parsePackage(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 **result)
//{
//    if (len < PACKAGE_MIN_LENGTH) {
//        return -1;
//    }
//    BLE_UInt8 cmd = package[0];
//    BLE_UInt8 version = package[1] & 0x0F;
//    
//    BLE_UInt8 key = package[2];
//    
//    BLE_UInt16 key_header = (package[3]<<8) + package[4];
//    BLE_UInt16 value_len = package[4];
//    
//    if (value_len > len - PACKAGE_MIN_LENGTH) {
//        return -1;
//    }
//    
//    BLE_UInt8 *value = package + PACKAGE_MIN_LENGTH;//偏移到指定位置
//    
////    result = &value;//不能这样做，因为改方法返回后，value释放了，result指向为NULL
//    
//    for (int i=0; i<len-PACKAGE_MIN_LENGTH; i++) {
//        *(*result+i) = value[i];
//    }

    
//    switch (CMD_KEY(cmd, key)) {
//        case CMD_KEY(CMD_updateFirmware, UpdateFirmware):
////            return parseUpdateFirmware(value, value_len, result);
//            break;
//        case CMD_KEY(CMD_setting, SetTime):
//            
//            break;
//        case CMD_KEY(CMD_setting, SetUserInfo):
//            
//            break;
//            
//            
//        default:
//            break;
//    }
//    
//    
//    
//    return 0;
//}



//int parseUpdateFirmware(BLE_UInt8 *value, BLE_UInt8 value_len, BLE_UInt32 **result)
//{
//    if (value_len < 2) {
//        return -1;
//    }
//    
//    for (int i = 0; i<value_len; i++) {
//        *(*result+i) = value[i];
//    }
//    
//    return 0;
//}

int parseUpdateFirmware(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *status, BLE_UInt8 *errorCode)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_updateFirmware, UpdateFirmware)) {
        return HANDLE_FAIL;
    }
//    printf("cmd:%d, version:%d, key:%d, value_len:%d\n", s_pg.cmd, s_pg.protocol_version, s_pg.key, s_pg.value_len);
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    
    *status = s_pg.value[0];
    *errorCode = s_pg.value[1];
    
    return HANDLE_OK;
}



