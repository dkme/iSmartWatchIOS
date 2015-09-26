//
//  testing.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "testing.h"
#include "production.h"


int testLED(LEDType led, BLE_UInt8 openOrClose, BLE_UInt8 **package)
{
    BLE_UInt8 value[2] = {0};
    value[0] = led;
    value[1] = openOrClose;
    return setupPackage(CMD_test, TestLED, 2, value, package);
}

int testMotor(BLE_UInt8 **package)
{
    return setupPackage(CMD_test, TestMotor, 0, NULL, package);
}






