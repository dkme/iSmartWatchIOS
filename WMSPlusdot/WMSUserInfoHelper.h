//
//  WMSMyAccountHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-11-5.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSPersonModel;

//标识用户信息是否需要同步
#define USER_INFO_IS_NEED_SYNC_KEY                 @"WMSUserInfoHelper.USER_INFO_IS_NEED_SYNC_KEY"

@interface WMSUserInfoHelper : NSObject

+ (void)savaPersonInfo:(WMSPersonModel *)personModel;

+ (WMSPersonModel *)readPersonInfo;

@end
