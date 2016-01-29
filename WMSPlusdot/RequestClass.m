//
//  RequestClass.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/1.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "RequestClass.h"
#import "WMSURLMacro.h"
#import "Condition.h"

typedef enum : NSUInteger {
    ErrorCodeDataFormat = 0,
    ErrorCodeResultError,
    ErrorCodeRequestFail,
    ErrorCodeAdapterError,
} ErrorCode;


@implementation RequestClass

+ (void)requestWeatherOfCityName:(NSString *)cityName completion:(requestCompletionCallback)aCallback
{
    NSDictionary *param = @{@"q":cityName, @"appid":WEATHER_APPID};
    [self JSONDataWithUrl:UTF8Encoding(URL_WEATHER_API) parameters:param success:^(id json) {
        [self parseJsonData:json callback:aCallback];
    } fail:^{
        aCallback(NO, nil, ERROR(ErrorCodeRequestFail, nil));
    }];
}

+ (void)requestWeatherOfLatitude:(CGFloat)lat longitude:(CGFloat)lon completion:(requestCompletionCallback)aCallback
{
    NSDictionary *param = @{@"lat":@(lat), @"lon":@(lon), @"appid":WEATHER_APPID};
    [self JSONDataWithUrl:UTF8Encoding(URL_WEATHER_API) parameters:param success:^(id json) {
        [self parseJsonData:json callback:aCallback];
    } fail:^{
        aCallback(NO, nil, ERROR(ErrorCodeRequestFail, nil));
    }];
}



#pragma mark - Private

static inline NSString* UTF8Encoding(NSString *url)
{
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

static inline NSError* ERROR(NSInteger code,NSString *localizedDescription)
{
    if (!localizedDescription) {
        localizedDescription = @"";
    }
    return [NSError errorWithDomain:@"com.guogee.plusdot.httpRequest" code:code userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

+ (void)parseJsonData:(id)json callback:(requestCompletionCallback)aCallback
{
    if (aCallback) {
        if (![json isKindOfClass:NSDictionary.class]) {
            aCallback(NO, nil, ERROR(ErrorCodeDataFormat, nil));
            return ;
        }
        int code = [json[@"cod"] intValue];
        if (code != 200) {
            aCallback(NO, nil, ERROR(ErrorCodeResultError, nil));
            return ;
        }
        DEBUGLog(@"json:%@", json);
        NSError *error = nil;
        Condition *model = [MTLJSONAdapter modelOfClass:Condition.class fromJSONDictionary:json error:&error];
        if (error) {
            DEBUGLog(@"Adapter Error:%@", error.localizedDescription);
            aCallback(NO, nil, ERROR(ErrorCodeAdapterError, nil));
            return ;
        }
        aCallback(YES, model, nil);
    }
}

+ (void)JSONDataWithUrl:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id json))success fail:(void(^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            DEBUGLog(@"request error:%@", error.localizedDescription);
            fail();
        }
    }];
}
+ (void)POSTJSONDataWithUrl:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id json))success fail:(void(^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            DEBUGLog(@"request error:%@", error.localizedDescription);
            fail();
        }
    }];
}

@end
