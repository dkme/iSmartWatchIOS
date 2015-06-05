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





/**
 package    数据包
 len        包的长度,目前固定长度为20
 
 其他参数都为传出参数
 
 @return    0表示正确，-1表示错误
 */

//int parsePackage(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 **result);



int parseUpdateFirmware(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *status, BLE_UInt8 *errorCode);




#endif /* defined(__WMSPlusdot__parse__) */
