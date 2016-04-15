//
//  sync.c
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#include "sync.h"
#include "production.h"
#include "parse.h"


int syncSportData(BLE_UInt8 **package)
{
    return setupPackage(CMD_syncData, KEY_syncSportData, 0, NULL, package);
}

int syncSleepData(BLE_UInt8 **package)
{
    return setupPackage(CMD_syncData, KEY_syncSleepData, 0, NULL, package);
}


/////////////////////////////////////

Struct_SportData getSportData(BLE_UInt8 *package, BLE_UInt8 len)
{
    Struct_SportData result = {0};
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_syncData, KEY_syncSportData)) {
        return result;
    }
    if (s_pg.value_len < 13) {
        return result;
    }
    result.year = (s_pg.value[0] << 8) + s_pg.value[1];
    result.month = s_pg.value[2];
    result.day = s_pg.value[3];
    result.steps = (s_pg.value[4] << 8) + s_pg.value[5];
    result.distances = (s_pg.value[6] << 8) + s_pg.value[7];
    result.fireHeats = (s_pg.value[8] << 8) + s_pg.value[9];
    result.durations = (s_pg.value[10] << 8) + s_pg.value[11];
    result.notSyncDays = s_pg.value[12];
    result.error = HANDLE_OK;
    printf("同步日期:%d年%d月%d日",result.year,result.month,result.day);
    return result;
}


Struct_SleepData getSleepData(BLE_UInt8 *package, BLE_UInt8 len){
    Struct_SleepData result = {0};
    result.error = HANDLE_FAIL;
    
    struct_parse_package s_pg = parse(package, len);
    if (CMD_KEY(s_pg.cmd, s_pg.key) != CMD_KEY(CMD_syncData, KEY_syncSleepData)) {
        return result;
    }
    if (s_pg.value_len < 13) {
        return result;
    }
    result.year = ((s_pg.value[1] & 0xf8)>>3)+(s_pg.value[0]<<5);
    result.month = ((s_pg.value[1] & 0x07)<<1)+((s_pg.value[2]&0x80)>>7);
    result.day = ((s_pg.value[2]&0x7f)>>2);
    printf("同步日期:%d年%d月%d日",result.year,result.month,result.day);
    result.deepSleepMinute = s_pg.value[4]*256+s_pg.value[5];
    result.lightSleepMinute = s_pg.value[8]*256+s_pg.value[9];
    return result;
}








