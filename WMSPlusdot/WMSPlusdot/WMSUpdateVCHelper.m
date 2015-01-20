//
//  WMSUpdateVCHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSUpdateVCHelper.h"

@interface WMSUpdateVCHelper()<CBCentralManagerDelegate>
@property (nonatomic,copy) UpdateVCHelper_scanedPeripheral scanedBlock;
@property (nonatomic,copy) UpdateVCHelper_scanedTimeout timeoutBlock;
@end

@implementation WMSUpdateVCHelper

+ (id)instance
{
    WMSUpdateVCHelper *object = [[WMSUpdateVCHelper alloc] init];
    
    return object;
}
- (id)init
{
    if (self = [super init]) {
        dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    }
    return self;
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
    _centralManager = nil;
    [self setScanedBlock:nil];
}

- (void)scanPeripheralByInterval:(NSTimeInterval)interval
                      completion:(UpdateVCHelper_scanedPeripheral)aCallBack
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimeout) object:nil];
    [self performSelector:@selector(scanTimeout) withObject:nil afterDelay:interval];
    
    [self setScanedBlock:aCallBack];
    
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_centralManager scanForPeripheralsWithServices:nil options:options];
    if (_centralManager.delegate != self) {
        _centralManager.delegate = self;
    }
}

- (void)scanPeripheralByInterval:(NSTimeInterval)interval
                         results:(UpdateVCHelper_scanedPeripheral)aCallBack
                         timeout:(UpdateVCHelper_scanedTimeout)bCallBack
{
    [self setTimeoutBlock:bCallBack];
    [self scanPeripheralByInterval:interval completion:aCallBack];
}

- (void)stopScan
{
    [_centralManager stopScan];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)scanTimeout
{
    [_centralManager stopScan];
    [self setScanedBlock:nil];
    if (self.timeoutBlock) {
        self.timeoutBlock();
        [self setTimeoutBlock:nil];
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
//        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
//        [_centralManager scanForPeripheralsWithServices:nil options:options];
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    DEBUGLog(@"discover peripheral");
    if (self.scanedBlock) {
        self.scanedBlock(peripheral);
    }
}

@end
