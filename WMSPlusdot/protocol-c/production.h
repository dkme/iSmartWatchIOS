//
//  production.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__production__
#define __WMSPlusdot__production__

#include <stdio.h>
#include "dataType.h"

int setupPackage(BLE_UInt8 cmd, BLE_UInt8 key, BLE_UInt8 value_len, BLE_UInt8 *value, BLE_UInt8 **package);

#endif /* defined(__WMSPlusdot__production__) */
