//
//  WMSFilter.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-15.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSFilter.h"
#import "WMSBluetooth.h"
#import "WMSMyAccessory.h"

static const int MIN_RSSI       = -90;

@implementation WMSFilter

+ (NSArray *)filterForPeripherals:(NSArray *)peripherals withType:(int)type;
{
    if ([peripherals count] > 0)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (LGPeripheral *pObject in peripherals)
        {
            if (!pObject || pObject.RSSI < MIN_RSSI) {
                break ;
            }
            NSString *name = pObject.cbPeripheral.name;
            BOOL flag = NO;
            if (type == AccessoryGenerationONE) {
                flag = [name isEqualToString:WATCH_NAME] ||
                [name isEqualToString:WATCH_NAME2];
            } else if (type == AccessoryGenerationTWO) {
                flag = [name isEqualToString:WATCH_NAME_G2];
            } else {
                flag = NO;
            }
            if (flag)
            {
                [array addObject:pObject];
            }
        }
        return array;
    }
    return nil;
}
+ (NSArray *)descendingOrderPeripheralsWithSignal:(NSArray *)peripherals
{
    if ([peripherals count] > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:peripherals];
        LGPeripheral *tempObj = nil;
        for (int i=0; i<[array count]; i++) {
            for (int j=0; j<[array count]-i-1; j++) {
                LGPeripheral *pObj1 = array[j];
                LGPeripheral *pObj2 = array[j+1];
                if (pObj2.RSSI > pObj1.RSSI) {
                    tempObj = array[j];
                    array[j] = array[j+1];
                    array[j+1] = tempObj;
                }
            }
        }
        return array;
    }
    return nil;
}

@end
