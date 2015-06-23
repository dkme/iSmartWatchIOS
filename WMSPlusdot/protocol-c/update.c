//
//  update.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "update.h"
#include "production.h"
#include "parse.h"


int updateFirmware(BLE_UInt8 **package)
{
    return setupPackage(CMD_updateFirmware, UpdateFirmware, 0, NULL, package);
}

///////////////////////////////////////////

Struct_UpdateResult getResult(BLE_UInt8 *package, BLE_UInt8 len)
{
    Struct_UpdateResult result = {0};
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_updateFirmware, UpdateFirmware)) {
        return result;
    }
    if (s_pg.value_len < 2) {
        return result;
    }
    if (s_pg.value[0] == 0x00) {
        result.isSuccess = 1;
        result.errorCode = 0;
        result.error = HANDLE_OK;
    } else if (s_pg.value[0] == 0x01) {
        result.isSuccess = 0;
        result.errorCode = s_pg.value[1];
        result.error = HANDLE_OK;
    } else {
        result.error = HANDLE_FAIL;
    }
    return result;
}


