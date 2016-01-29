//
//  update.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__update__
#define __WMSPlusdot__update__

#include <stdio.h>
#include "dataType.h"

typedef enum {
    BatteryTooLow = 0x01,
} RequestUpdateFirmwareErrorCode;


int updateFirmware(BLE_UInt8 **package);

///////////////////////////////////////////
typedef struct {
    BLE_UInt8 isSuccess;
    RequestUpdateFirmwareErrorCode errorCode;
    
    HANDLE_RESULT error;
} Struct_UpdateResult;

Struct_UpdateResult getResult(BLE_UInt8 *package, BLE_UInt8 len);


#endif /* defined(__WMSPlusdot__update__) */