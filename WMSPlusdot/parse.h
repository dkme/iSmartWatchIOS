//
//  parse.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__parse__
#define __WMSPlusdot__parse__

#include <stdio.h>
#include "dataType.h"

#define CMD_KEY(cmd, key)         ( ((cmd << 8) + key) )

static const int VALUE_LENGTH                               = 15;


typedef struct {
    //Header
    BLE_UInt8 cmd;
    BLE_UInt8 protocol_version;
    
    //payload
    BLE_UInt8 key;
    BLE_UInt8 value_len;//有效的长度
    BLE_UInt8 value[VALUE_LENGTH];
    
} struct_parse_package;


struct_parse_package parse(BLE_UInt8 *package, BLE_UInt8 len);


#endif /* defined(__WMSPlusdot__parse__) */
