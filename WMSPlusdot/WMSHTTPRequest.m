//
//  WMSHTTPRequest.m
//  WMSPlusdot
//
//  Created by Sir on 14-10-14.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSHTTPRequest.h"
#import "WMSFileMacro.h"

#define GUOGEE_SERVER_ADDRESS   @"http://regsrv1.guogee.com:86/"
#define REGISTER_INTERFACE_PATH @"api/user/AddUser"
#define LOGIN_INTERFACE_PATH    @"api/user/CheckLogin"

#define URL_REQUEST_FIRMWARE_VERSION    @"http://www.youduoyun.com/api/firmwares/version?device_id=180"

#define REQUEST_TIME_INTERVAL   5.0

@implementation WMSHTTPRequest

+ (void)registerRequestParameter:(NSString *)parameter
                      completion:(registerRequestCallBack)aCallBack
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",GUOGEE_SERVER_ADDRESS,REGISTER_INTERFACE_PATH];
    NSURLRequest *urlRequest = [self urlRequestWithURL:strURL parameter:parameter];
    if (urlRequest == nil) {
        if (aCallBack) {
            NSError *error = [NSError errorWithDomain:@"NSURLRequestDomain" code:ERROR_CODE_REQUEST_TIMEOUT userInfo:@{NSLocalizedDescriptionKey:@"The request timed out"}];
            aCallBack(0,0,error);
        }
    }
    
    //异步发送请求
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         DEBUGLog(@"error:%@",[error localizedDescription]);
         DEBUGLog(@"data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         if (data.length>0 && error==nil) {
             NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             DEBUGLog(@"result:%@",res);
             
             NSError *err=nil;
             id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&err];
             if (jsonObject != nil && error == nil){
                 if ([jsonObject isKindOfClass:[NSDictionary class]]){
                     BOOL success = [[jsonObject objectForKey:@"result"] boolValue];
                     int errNO = [[jsonObject objectForKey:@"errno"] intValue];
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         if (aCallBack) {
                             aCallBack(success,errNO,nil);
                         }
                     });
                 }
             }
         } else if (data.length==0 && error==nil) {
         } else if (error!=nil) {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 if (aCallBack) {
                     aCallBack(0,0,error);
                 }
             });
         }
     }];
}

+ (void)loginRequestParameter:(NSString *)parameter
                   completion:(loginRequestCallBack)aCallBack
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",GUOGEE_SERVER_ADDRESS,LOGIN_INTERFACE_PATH];
    NSURLRequest *urlRequest = [self urlRequestWithURL:strURL parameter:parameter];
    if (urlRequest == nil) {
        if (aCallBack) {
            NSError *error = [NSError errorWithDomain:@"NSURLRequestDomain" code:ERROR_CODE_REQUEST_TIMEOUT userInfo:@{NSLocalizedDescriptionKey:@"The request timed out"}];
            aCallBack(0,nil,error);
        }
    }
    
    //异步发送请求
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (data.length>0 && error==nil) {
             NSError *err=nil;
             id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&err];
             if (jsonObject != nil && error == nil){
                 if ([jsonObject isKindOfClass:[NSDictionary class]]){
                     BOOL success = [[jsonObject objectForKey:@"result"] boolValue];
                     NSDictionary *value = [jsonObject objectForKey:@"value"];
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         if (aCallBack) {
                             aCallBack(success,value,nil);
                         }
                     });
                 }
             }
         } else if (data.length==0 && error==nil) {
         } else if (error!=nil) {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 if (aCallBack) {
                     aCallBack(0,nil,error);
                 }
             });
         }
     }];
}

+ (NSURLRequest *)urlRequestFromInterfacePath:(NSString *)path bodyStr:(NSString *)bodyStr
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",GUOGEE_SERVER_ADDRESS,path];
    NSURL *url=[NSURL URLWithString:strURL];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_INTERVAL];
    urlRequest.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPMethod = @"GET";
    DEBUGLog(@"URL:%@",urlRequest.URL);
    return urlRequest;
}
+ (NSURLRequest *)urlRequestWithURL:(NSString *)strURL parameter:(NSString *)parameter
{
    NSString *str = [NSString stringWithFormat:@"%@?%@",strURL,parameter];
    NSURL *url=[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_INTERVAL];
    urlRequest.HTTPMethod = @"GET";
    DEBUGLog(@"URL:%@",urlRequest.URL);
    return urlRequest;
}

//请求固件版本
+ (void)detectionFirmwareUpdate:(detectionUpdateCallBack)aCallBack
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        NSDictionary *info = [self firmwareInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (info) {
                if (aCallBack) {
                    double version = [info[@"version"] doubleValue];
                    NSString *desc = info[@"desc"];
                    NSString *strURL = info[@"url"];
                    aCallBack(version,desc,strURL);
                }
            } else {
                if (aCallBack) {
                    aCallBack(0.0,nil,nil);
                }
            }
        });
    });
    
}
+ (NSDictionary *)firmwareInfo
{
    NSString *urlString = URL_REQUEST_FIRMWARE_VERSION;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_INTERVAL];
    if (!request) {
        return nil;
    }
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (returnData) {
        NSError *error = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingAllowFragments error:&error];
        if (jsonData && error==nil) {
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                return jsonData[@"data"];
            }
        } else {
            DEBUGLog(@"%s error:not data or error",__FILE__);
        }
    } else {
        return nil;
    }
    return nil;
}

+ (void)downloadFirmwareUpdateFileStrURL:(NSString *)strURL
                              completion:(downloadFileCallBack)aCallBack
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        BOOL success = [self download:strURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (aCallBack) {
                aCallBack(success);
            }
        });
    });
}
+ (BOOL)download:(NSString *)strURL
{
//    if ([self isExistFilePath:FileTmpPath(FILE_TMP_FIRMWARE_UPDATE)]) {
//        return YES;
//    }
    NSString *urlString = strURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_INTERVAL];
    if (!request) {
        return NO;
    }
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (returnData) {
        return [self savaData:returnData toFilePath:FileTmpPath(FILE_TMP_FIRMWARE_UPDATE)];
    } else {
        return NO;
    }
    return NO;
}

#pragma mark - --sava data to local
+ (BOOL)savaData:(NSData *)data toFilePath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!fileManager) {
        NSLog(@"error: NSFileManager fail...");
        return NO;
    }
    return [fileManager createFileAtPath:path contents:data attributes:nil];
}

+ (BOOL)isExistFilePath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

@end
