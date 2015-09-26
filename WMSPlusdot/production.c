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
    
    for (int j=0; j<value_len; j++) {
        *(*package+(j+5)) = value[j];
    }
    
#ifdef DEBUG
    printf("package:0x");
    for (int i=0; i<PACKAGE_SIZE; i++) {
        printf("%02X ", *(*package+i));
    }
    printf("\n");
#endif
    
    return HANDLE_OK;
}





