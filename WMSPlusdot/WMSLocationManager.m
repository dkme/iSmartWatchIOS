//
//  WMSLocationManager.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSLocationManager.h"

@interface WMSLocationManager () <UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL isFirstUpdate;

@property (nonatomic, copy) completionCallback findCallback;

@property (nonatomic, assign) int handleCount;
@property (nonatomic, assign) BOOL isEnterSetting;

@end

@implementation WMSLocationManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        if (IS_IOS8) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    return self;
}

- (void)dealloc
{
    DEBUGLog(@"%s", __FUNCTION__);
}

- (void)findCurrentLocation:(completionCallback)aCallback {
    self.handleCount = 0;
    if (aCallback) {
        self.isFirstUpdate = YES;
        self.findCallback = aCallback;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopFindLocation
{
    self.findCallback = nil;
    [self.locationManager stopUpdatingLocation];
}

- (void)showAlertView
{
    UIAlertView *alertView = nil;
    if (IS_IOS8) {
        alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"定位服务未开启", nil) message:NSLocalizedString(@"请在系统设置中开启定位服务", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"好",nil) otherButtonTitles:NSLocalizedString(@"设置",nil), nil];
    } else {
        alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"定位服务未开启", nil) message:NSLocalizedString(@"请在系统“设置-隐私-定位服务”中开启定位服务",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"好",nil) otherButtonTitles:nil];
    }
    [alertView show];
}

#pragma mark - CLLocationManagerDelegate
//该方法可能会执行很多次，最后一次返回的结果是最准确的，不过我们只需知道城市名，取第一次的结果即可
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.isFirstUpdate) {//抛弃第一次的返回结果
        self.isFirstUpdate = NO;
        return;
    }
    if (self.handleCount >= 1) {//取第一次的结果即可
        return ;
    }
    self.handleCount ++;
    
    CLLocation *location = [locations lastObject];
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            //将获得的所有信息显示到label上
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            _currentCityName = city;
            DEBUGLog(@"city:%@", city);
            if (location.horizontalAccuracy > 0) {
                _currentLocation = location;
                [manager stopUpdatingLocation];
                if (self.findCallback) {
                    self.findCallback(YES, location.coordinate.latitude, location.coordinate.longitude, nil);
                    self.findCallback = nil;
                }
            }
            return ;
        }
        else if (error == nil && [array count] == 0)
        {
            DEBUGLog(@"No results were returned.");
            [manager stopUpdatingLocation];
            if (self.findCallback) {
                self.findCallback(NO, 0, 0, nil);
                self.findCallback = nil;
            }
        }
        else if (error != nil)
        {
            DEBUGLog(@"An error occurred = %@", error);
            [manager stopUpdatingLocation];
            if (self.findCallback) {
                self.findCallback(NO, 0, 0, error);
                self.findCallback = nil;
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    if (self.findCallback) {
        self.findCallback(NO, 0, 0, error);
        self.findCallback = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status >= kCLAuthorizationStatusAuthorizedAlways && self.isEnterSetting) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(locationManagerdidCanPosition:)]) {
            [self.delegate locationManagerdidCanPosition:self];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            self.isEnterSetting = YES;
        }
    }
}


@end
