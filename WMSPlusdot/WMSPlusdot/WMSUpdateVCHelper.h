//
//  WMSUpdateVCHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^UpdateVCHelper_scanedPeripheral)(CBPeripheral *peripheral);
typedef void (^UpdateVCHelper_scanedTimeout)(void);

@interface WMSUpdateVCHelper : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager;

+ (id)instance;

- (void)scanPeripheralByInterval:(NSTimeInterval)interval
                      completion:(UpdateVCHelper_scanedPeripheral)aCallBack;//被弃用

- (void)scanPeripheralByInterval:(NSTimeInterval)interval
                         results:(UpdateVCHelper_scanedPeripheral)aCallBack
                         timeout:(UpdateVCHelper_scanedTimeout)bCallBack;

- (void)stopScan;

@end
