//
//  WMSRegularExpressions.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-15.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSRegularExpressions : NSObject

+ (BOOL)validateEmail:(NSString *)email;

+ (BOOL)validateUserName:(NSString *)name;

@end
