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

typedef enum {
    LEDPhone = 0x01,
    LEDSMS,
    LEDAlarmClock,
    LEDLost,
} LEDType;

/**
 openOrClose    0-关闭，1-打开
 */
int testLED(LEDType led, BLE_UInt8 openOrClose, BLE_UInt8 **package);

int testMotor(BLE_UInt8 **package);




#endif /* defined(__WMSPlusdot__testing__) */
