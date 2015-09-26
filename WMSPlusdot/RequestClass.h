//
//  RequestClass.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/1.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^requestCompletionCallback)(BOOL isSuccess, id data, NSError *error);

@interface RequestClass : NSObject

/**
 请求对应城市的天气信息
 */
+ (void)requestWeatherOfCityName:(NSString *)cityName completion:(requestCompletionCallback)aCallback;

/**
 请求当前位置的天气信息
 */
+ (void)requestWeatherOfLatitude:(CGFloat)lat longitude:(CGFloat)lon completion:(requestCompletionCallback)aCallback;


@end
