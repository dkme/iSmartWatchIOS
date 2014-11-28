//
//  WMSMyAccountHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-11-5.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSUserInfoHelper.h"
#import "WMSAppDelegate.h"
#import "WMSPersonModel.h"
#import "WMSConstants.h"
#import "NSDate+Formatter.h"
#import "WMSFileMacro.h"

@implementation WMSUserInfoHelper

+ (void)savaPersonInfo:(WMSPersonModel *)personModel
{    
    NSString *fileName = FilePath(FILE_USER_INFO);
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:personModel forKey:@"WMSPersonModel"];
    [archiver finishEncoding];
    [data writeToFile:fileName atomically:YES];
}

+ (WMSPersonModel *)readPersonInfo
{
    NSString *fileName = FilePath(FILE_USER_INFO);
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    WMSPersonModel *model = nil;
    if ([data length] > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        model = [unArchiver decodeObjectForKey:@"WMSPersonModel"];
        [unArchiver finishDecoding];
    }
    //判断用户信息是否存在，不存在，则赋一个初始值(使用登陆时的用户名)
    if (model == nil) {
        NSDictionary *readData =  [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_LOGIN_INFO)];
        NSString *name = [readData objectForKey:@"userName"];
        NSDate *birthday = [NSDate dateFromString:USERINFO_BIRTHDAY format:@"yyyy-MM-dd"];
        model = [[WMSPersonModel alloc] initWithName:name image:nil birthday:birthday gender:USERINFO_GENDER height:USERINFO_HEIGHT currentWeight:USERINFO_CURRENT_WEIGHT targetWeight:USERINFO_TARGET_WEIGHT stride:USERINFO_STRIDE];
    }
    
    return model;
}

@end
