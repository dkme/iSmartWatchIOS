//
//  testing.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "testing.h"
#include "production.h"
#include "parse.h"


int testLED(LEDType led, BLE_UInt8 openOrClose, BLE_UInt8 **package)
{
    BLE_UInt8 value[2] = {0};
    value[0] = led;
    value[1] = openOrClose;
    return setupPackage(CMD_test, TestLED, 2, value, package);
}

int testMotor(BLE_UInt8 openOrClose, BLE_UInt8 **package)
{
    BLE_UInt8 value[1] = {0};
    value[0] = openOrClose;
    return setupPackage(CMD_test, TestMotor, 1, value, package);
}

int testDisplay(BLE_UInt8 openOrClose, BLE_UInt8 **package)
{
    BLE_UInt8 value[1] = {0};
    value[0] = openOrClose;
    return setupPackage(CMD_test, TestDisplay, 1, value, package);
}

int testMovementGear(GEAR_TURN_DIRECTION direction, BLE_UInt8 **package)
{
    BLE_UInt8 value[1] = {0};
    value[0] = direction;
    return setupPackage(CMD_test, TestMovementGear, 1, value, package);
}

////////////////////////////////

Struct_Control getControl(BLE_UInt8 *package, BLE_UInt8 len)
{
    Struct_Control result = {0};
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (s_pg.cmd != CMD_control) {
        return result;
    }
    if (s_pg.key != ControlClick        &&
        s_pg.key != ControlDoubleClick  &&
        s_pg.key != ControlLongPress)
    {
        return result;
    }
    if (s_pg.value_len < 1) {
        return result;
    }
    result.control = s_pg.cmd;
    result.button = s_pg.value[0];
    result.error = HANDLE_OK;
    return result;
}

int getSensorValue(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_test, TestSensor)) {
        return 0;
    }
    if (s_pg.value_len < 2) {
        return 0;
    }
    return (s_pg.value[0] << 8) + s_pg.value[1];
}

