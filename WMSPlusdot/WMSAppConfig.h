//
//  WMSAppConfig.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-8.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSAppConfig : NSObject

/*
 判断是否已经登录
 */
+ (BOOL)isHaveLogin;

/*
 用户登录信息
 */
+ (NSString *)loginUserName;
+ (NSString *)loginPassword;

/*
 保存用户登录信息
 */
+ (BOOL)savaLoginUserName:(NSString *)userName password:(NSString *)password;

/*
 清除用户登陆信息
 */
+ (BOOL)clearLoginInfo;

@end
