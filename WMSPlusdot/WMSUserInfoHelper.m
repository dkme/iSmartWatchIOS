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

@implementation WMSUserInfoHelper

+ (void)savaPersonInfo:(WMSPersonModel *)personModel
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:personModel.name forKey:@"name"];
    [userDefaults setObject:UIImagePNGRepresentation(personModel.image) forKey:@"image"];
    [userDefaults setObject:personModel.birthday forKey:@"birthday"];
    [userDefaults setInteger:personModel.gender forKey:@"gender"];
    [userDefaults setInteger:personModel.height forKey:@"height"];
    [userDefaults setInteger:personModel.currentWeight forKey:@"currentWeight"];
    [userDefaults setInteger:personModel.targetWeight forKey:@"targetWeight"];
    [userDefaults setInteger:personModel.stride forKey:@"stride"];
}

+ (WMSPersonModel *)readPersonInfo
{
    WMSPersonModel *model = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefaults stringForKey:@"name"];
    //表示用户信息不存在，则赋一个初始值(使用登陆时的用户名)
    if (!name || [name isEqualToString:@""]) {
        NSDictionary *readData =  [NSDictionary dictionaryWithContentsOfFile:FilePath(UserInfoFile)];
        name = [readData objectForKey:@"userName"];
        NSDate *birthday = [NSDate dateFromString:USERINFO_BIRTHDAY format:@"yyyy-MM-dd"];
        model = [[WMSPersonModel alloc] initWithName:name image:nil birthday:birthday gender:USERINFO_GENDER height:USERINFO_HEIGHT currentWeight:USERINFO_CURRENT_WEIGHT targetWeight:USERINFO_TARGET_WEIGHT stride:USERINFO_STRIDE];
    } else {
        model = [[WMSPersonModel alloc] init];
        model.name = name;
        model.image = [UIImage imageWithData:[userDefaults dataForKey:@"image"]];
        model.birthday = [userDefaults valueForKey:@"birthday"];
        model.gender = [userDefaults integerForKey:@"gender"];
        model.height = [userDefaults integerForKey:@"height"];
        model.currentWeight = [userDefaults integerForKey:@"currentWeight"];
        model.targetWeight = [userDefaults integerForKey:@"targetWeight"];
        model.stride = [userDefaults integerForKey:@"stride"];
    }
    return model;
}

@end
