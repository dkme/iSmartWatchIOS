//
//  control.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#ifndef __WMSPlusdot__control__
#define __WMSPlusdot__control__

#include <stdio.h>
#include "dataType.h"


typedef enum {
    ButtonTopRightCorner = 0x01,
    ButtonLowerRightCorner,
    ButtonTopLeftCorner,
    ButtonLowerLeftCorner,
} ButtonType;

typedef struct {
    ControlKey control;
    ButtonType button;
    
    HANDLE_RESULT error;
} Struct_Control;

Struct_Control getControlCommand(BLE_UInt8 *package, BLE_UInt8 len);


#endif /* defined(__WMSPlusdot__control__) */
