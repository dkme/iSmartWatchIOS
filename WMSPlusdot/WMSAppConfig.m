//
//  WMSAppConfig.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-8.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAppConfig.h"
#import "WMSFileMacro.h"

@implementation WMSAppConfig

+ (BOOL)isHaveLogin
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_LOGIN_INFO)];
    if (readData && ![[readData objectForKey:@"userName"] isEqualToString:@""]) {//已经登陆过
        return YES;
    } else {
        return NO;
    }
    return NO;
}

+ (NSString *)loginUserName
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_LOGIN_INFO)];
    return [readData objectForKey:@"userName"];
}
+ (NSString *)loginPassword
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_LOGIN_INFO)];
    return [readData objectForKey:@"password"];
}

+ (BOOL)savaLoginUserName:(NSString *)userName password:(NSString *)password
{
    NSDictionary *writeData = @{@"userName":userName,@"password":password};
    BOOL res = [writeData writeToFile:FilePath(FILE_LOGIN_INFO) atomically:YES];
    return res;
}

+ (BOOL)clearLoginInfo
{
    NSDictionary *writeData = @{@"userName":@"",@"password":@""};
    BOOL res = [writeData writeToFile:FilePath(FILE_LOGIN_INFO) atomically:YES];
    return res;
}

@end
