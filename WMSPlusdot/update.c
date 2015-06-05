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

int getResult(BLE_UInt8 *package, BLE_UInt8 len, BLE_UInt8 *isSuccess, RequestUpdateFirmwareErrorCode *errorCode)
{
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_updateFirmware, UpdateFirmware)) {
        return HANDLE_FAIL;
    }
    if (s_pg.value_len < 2) {
        return HANDLE_FAIL;
    }
    if (s_pg.value[0] == 0x00) {
        *isSuccess = 1;
        *errorCode = 0;
    } else if (s_pg.value[0] == 0x01) {
        *isSuccess = 0;
        *errorCode = s_pg.value[1];
    } else {}
    return HANDLE_OK;
}


