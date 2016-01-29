//
//  sync.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__sync__
#define __WMSPlusdot__sync__

#include <stdio.h>
#include "dataType.h"

int syncSportData(BLE_UInt8 **package);

int syncSleepData(BLE_UInt8 **package);


/////////////////////////////////////////

typedef struct {
    BLE_UInt16 year;
    BLE_UInt8 month;
    BLE_UInt8 day;
    
    BLE_UInt16 steps;
    BLE_UInt16 distances;
    BLE_UInt16 fireHeats;
    BLE_UInt16 durations;
    
    BLE_UInt8 notSyncDays;
    
    HANDLE_RESULT error;
} Struct_SportData;

Struct_SportData getSportData(BLE_UInt8 *package, BLE_UInt8 len);


#endif /* defined(__WMSPlusdot__sync__) */