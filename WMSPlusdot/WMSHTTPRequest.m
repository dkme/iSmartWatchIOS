//
//  WMSHTTPRequest.m
//  WMSPlusdot
//
//  Created by Sir on 14-10-14.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSHTTPRequest.h"

#define GUOGEE_SERVER_ADDRESS   @"http://regsrv1.guogee.com:86/"
#define REGISTER_INTERFACE_PATH @"api/user/AddUser"
#define LOGIN_INTERFACE_PATH    @"api/user/CheckLogin"

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

@end
