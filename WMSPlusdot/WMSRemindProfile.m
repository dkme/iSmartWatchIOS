//
//  WMSRemindProfile.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRemindProfile.h"
#import "WMSBleControl.h"
#import "DataPackage.h"

@interface WMSRemindProfile ()
{
    
}

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *rwCharact;
@property (nonatomic, strong) LGCharacteristic *notifyCharact;


//Stack

@end

@implementation WMSRemindProfile

#pragma mark - Init
- (id)initWithBleControl:(WMSBleControl *)bleControl
{
    if (self = [super init]) {
        self.bleControl = bleControl;
        self.rwCharact = self.bleControl.readWriteCharacteristic;
        self.notifyCharact = self.bleControl.notifyCharacteristic;
        
        [self setup];
    }
    return self;
}
- (void)setup
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
}
- (void)dealloc
{
    self.bleControl = nil;
    self.rwCharact = nil;
    self.notifyCharact = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
