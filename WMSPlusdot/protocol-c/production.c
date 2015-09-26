//
//  production.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "production.h"
#include <string.h>
#include <stdlib.h>


int setupPackage(BLE_UInt8 cmd, BLE_UInt8 key, BLE_UInt8 value_len, BLE_UInt8 *value, BLE_UInt8 **package)
{
    memset(*package, 0, PACKAGE_LENGTH);
    *(*package+0) = cmd;
    *(*package+1) = ((BLE_UInt8)PROTOCOL_VERSION & 0x0F);
    *(*package+2) = key;
    *(*package+3) = 0;
    *(*package+4) = value_len;
    
    if (value_len == 0) {
        return HANDLE_FAIL;
    }
    
    for (int j=0; j<value_len; j++) {
        *(*package+(j+5)) = value[j];
    }
    return HANDLE_OK;
}





