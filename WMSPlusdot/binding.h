//
//  binding.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__binding__
#define __WMSPlusdot__binding__

#include <stdio.h>
#include "dataType.h"



int bindWatch(BLE_UInt8 **package);

int unbindWatch(BLE_UInt8 **package);


/////////////////////////////////////////////////////

#define OPERATION_OK                0x00
#define OPERATION_FAIL              0x01

/**
 * @return 为OPERATION_OK表示成功，OPERATION_FAIL表示失败
 */
BLE_UInt8 getBindingResult(BLE_UInt8 *package, BLE_UInt8 len);

BLE_UInt8 getUnbindingResult(BLE_UInt8 *package, BLE_UInt8 len);




#endif /* defined(__WMSPlusdot__binding__) */
