//
//  WMSRemindHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-27.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSRemindHelper : NSObject

/*
 描述重复情况
 */
+ (NSString *)descriptionOfRepeats:(NSArray *)repeats;
+ (NSString *)description2OfRepeats:(NSArray *)repeats;

/*
 配置重复情况（当永不重复时，设为当天重复）
 */
+ (NSArray *)repeatsWithArray:(NSArray *)array;

@end
