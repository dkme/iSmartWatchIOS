//
//  WMSMyAccountHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-11-5.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSPersonModel;

@interface WMSUserInfoHelper : NSObject

+ (void)savaPersonInfo:(WMSPersonModel *)personModel;

+ (WMSPersonModel *)readPersonInfo;

@end
