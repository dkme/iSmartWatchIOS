//
//  WMSUpdateVCHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^UpdateVCHelper_scanedPeripheral)(NSArray *peripherals);

@interface WMSUpdateVCHelper : NSObject

- (void)scanPeripheralByInterval:(NSTimeInterval)interval
                     completion:(UpdateVCHelper_scanedPeripheral)aCallBack;

//- (void)connectPeripheral:(CBPeripheral *)peripheral;

@end
