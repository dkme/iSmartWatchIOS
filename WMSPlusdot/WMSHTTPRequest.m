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
///P3
#define URL_P3_SERVERS_ADDRESS          @"http://www.guogee.com/plusdot/"
#define URL_SERVERS_UPDATE_DESCRIBE_FILE_NAME   @"updateDescribe.plist"

#define REQUEST_TIME_INTERVAL   5.0

static inline NSString* UTF8Encoding(NSString *url);

@implementation WMSHTTPRequest

+ (void)registerRequestParameter:(NSString *)parameter
                      completion:(registerRequestCallBack)aCallBack
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",GUOGEE_SERVER_ADDRESS,REGISTER_INTERFACE_PATH];
    NSURLRequest *urlRequest = [self urlRequestWithURL:strURL parameter:parameter];
    if (urlRequest == nil) {
        if (aCallBack) {
            NSError *error = [NSError errorWithDomain:@"NSURLRequestDomain" code:ERROR_CODE_REQUEST_TIMEOUT userInfo:@{NSLocalizedDescriptionKey:@"The request timed out"}];
            aCallBack(0,ERROR_CODE_REQUEST_TIMEOUT,error);
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
        NSDictionary *jsonData = [self firmwareInfo];
        BOOL success = [jsonData[@"success"] boolValue];
        NSDictionary *info = jsonData[@"data"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
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
    NSString *urlString = UTF8Encoding([URL_P3_SERVERS_ADDRESS stringByAppendingString:URL_SERVERS_UPDATE_DESCRIBE_FILE_NAME]);
    
    ///读取.plist文件
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
    return data;
    
//    ///读取.json文件
//    //Json数据
//    NSData *readData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
//    //==JsonObject
//    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:readData
//                                                               options:NSJSONReadingAllowFragments
//                                                                 error:nil];
//    return jsonObject;
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
+ (BOOL)download:(NSString *)strURL saveToPath:(NSString *)path
{
    NSString *urlString = strURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_INTERVAL];
    if (!request) {
        return NO;
    }
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (returnData) {
        return [self savaData:returnData toFilePath:path];
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

static inline NSString* UTF8Encoding(NSString *url)
{
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
