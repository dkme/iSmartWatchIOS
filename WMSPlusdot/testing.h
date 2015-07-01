//
//  testing.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__testing__
#define __WMSPlusdot__testing__

#include <stdio.h>
#include "dataType.h"
#include "control.h"

typedef enum {
    LEDPhone = 0x01 << 0,
    LEDSMS = 0x01 << 1,
    LEDAlarmClock = 0x01 << 2,
    LEDLost = 0x01 << 3,
    LEDOther = 0x01 << 4,
} LEDType;

/**
 openOrClose    0-关闭，1-打开
 */
int testLED(LEDType led, BLE_UInt8 openOrClose, BLE_UInt8 **package);

int testMotor(BLE_UInt8 openOrClose, BLE_UInt8 **package);

int testDisplay(BLE_UInt8 openOrClose, BLE_UInt8 **package);


////////////////////////////////

Struct_Control getControl(BLE_UInt8 *package, BLE_UInt8 len);



#endif /* defined(__WMSPlusdot__testing__) */
