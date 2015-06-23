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


struct_parse_package parse(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = {0};
    if (len < PACKAGE_LENGTH) {
        return s_pg;
    }
    
    BLE_UInt8 cmd = package[0];
    BLE_UInt8 version = (package[1] & 0xF0) >> 4;
    
    BLE_UInt8 key = package[2];
    
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


