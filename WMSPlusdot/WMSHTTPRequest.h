//
//  WMSHTTPRequest.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-14.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

//Block
typedef void (^registerRequestCallBack)(BOOL result,int errorNO,NSError *error);
typedef void (^loginRequestCallBack)(BOOL result,NSDictionary *info,NSError *error);
typedef void (^detectionUpdateCallBack)(double newVersion,NSString *describe,NSString *strURL);
typedef void (^downloadFileCallBack)(BOOL success);

//Error Code
const static int ERROR_CODE_REQUEST_TIMEOUT             = 1000;
const static int ERROR_CODE_USERNAME_EXIST              = 100001;
const static int ERROR_CODE_EMAIL_EXIST                 = 100002;
const static int ERROR_CODE_PHONENUMBER_EXIST           = 100005;
const static int ERROR_CODE_PARAMETER_LOSE              = 100003;

@interface WMSHTTPRequest : NSObject

/*
 注册
 */
+ (void)registerRequestParameter:(NSString *)parameter
                      completion:(registerRequestCallBack)aCallBack;

/*
 登陆
 */
+ (void)loginRequestParameter:(NSString *)parameter
                   completion:(loginRequestCallBack)aCallBack;

/*
 请求固件版本
 */
+ (void)detectionFirmwareUpdate:(detectionUpdateCallBack)aCallBack;

/*
 下载固件升级文件
 */
+ (void)downloadFirmwareUpdateFileStrURL:(NSString *)strURL
                              completion:(downloadFileCallBack)aCallBack;

@end
