//
//  WMSDeviceModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSDeviceModel : NSObject

@property (nonatomic, assign) int batteryEnergy;
@property (nonatomic, assign) double version;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) double voltage;

+ (WMSDeviceModel *)deviceModel;

- (void)resetDevice;

@end
