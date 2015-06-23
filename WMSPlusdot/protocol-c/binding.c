//
//  binding.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "binding.h"
#include "production.h"
#include "parse.h"



int bindWatch(BLE_UInt8 **package)
{
    return setupPackage(CMD_binding, Binding, 0, NULL, package);
}

int unbindWatch(BLE_UInt8 **package)
{
    return setupPackage(CMD_binding, unBinding, 0, NULL, package);
}



/////////////////////////////////////////////////////

BLE_UInt8 getBindingResult(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_binding, Binding)) {
        return OPERATION_FAIL;
    }
    if (s_pg.value_len < 1) {
        return OPERATION_FAIL;
    }
    BLE_UInt8 result = s_pg.value[0];
    return result;
}

BLE_UInt8 getUnbindingResult(BLE_UInt8 *package, BLE_UInt8 len)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_binding, unBinding)) {
        return OPERATION_FAIL;
    }
    if (s_pg.value_len < 1) {
        return OPERATION_FAIL;
    }
    BLE_UInt8 result = s_pg.value[0];
    return result;
}






