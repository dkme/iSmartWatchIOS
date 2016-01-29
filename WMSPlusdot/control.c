//
//  control.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "control.h"
#include "production.h"
#include "parse.h"


int switchControlMode(ControlMode mode, BLE_UInt8 **package)
{
    BLE_UInt8 keys[2] = {ControlKey_NormalMode,ControlKey_RemoteMode};
    return setupPackage(CMD_control, keys[mode], 0, NULL, package);
}

/////////////////////////////////////////////

Struct_Control getControlCommand(BLE_UInt8 *package, BLE_UInt8 len)
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
    result.control = s_pg.key;
    result.button = s_pg.value[0];
    result.error = HANDLE_OK;
    return result;
}