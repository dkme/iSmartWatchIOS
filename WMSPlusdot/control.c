//
//  control.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "control.h"
#include "parse.h"


int getControlCommand(BLE_UInt8 *package, BLE_UInt8 len, ControlKey *control, ButtonType *button)
{
    struct_parse_package s_pg = parse(package, len);
    if (s_pg.cmd != CMD_control) {
        return HANDLE_FAIL;
    }
    if (s_pg.key != ControlClick        &&
        s_pg.key != ControlDoubleClick  &&
        s_pg.key != ControlLongPress)
    {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 1) {
        return HANDLE_FAIL;
    }
    *control = s_pg.cmd;
    *button = s_pg.value[0];
    return HANDLE_OK;
}