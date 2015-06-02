//
//  WMSLocationManager.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^completionCallback)(BOOL isSuccess, float lat, float lon);

@interface WMSLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong, readonly) CLLocation *currentLocation;

@property (nonatomic, strong, readonly) NSString *currentCityName;

+ (instancetype)sharedManager;

- (void)findCurrentLocation:(completionCallback)aCallback;

@end
