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

//Error Code
const static int ERROR_CODE_REQUEST_TIMEOUT = 1000;

@interface WMSHTTPRequest : NSObject

+ (void)registerRequestParameter:(NSString *)parameter
                      completion:(registerRequestCallBack)aCallBack;

+ (void)loginRequestParameter:(NSString *)parameter
                   completion:(loginRequestCallBack)aCallBack;

@end
