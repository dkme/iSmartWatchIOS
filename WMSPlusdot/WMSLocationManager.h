//
//  WMSLocationManager.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol WMSLocationManagerDelegate;

typedef void(^completionCallback)(BOOL isSuccess, float lat, float lon, NSError *error);

@interface WMSLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong, readonly) CLLocation *currentLocation;

@property (nonatomic, strong, readonly) NSString *currentCityName;

@property (nonatomic, weak) id<WMSLocationManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)findCurrentLocation:(completionCallback)aCallback;

- (void)stopFindLocation;

- (void)showAlertView;

@end


@protocol WMSLocationManagerDelegate <NSObject>

@optional
- (void)locationManagerdidCanPosition:(WMSLocationManager *)manager;


@end
