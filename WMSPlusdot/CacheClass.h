//
//  CacheClass.h
//  WMSPlusdot
//
//  Created by Sir on 15-3-7.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheClass : NSObject

+ (void)cacheMyBeans:(int)beans mac:(NSString *)mac;
+ (int)cachedBeansForMac:(NSString *)mac;

+ (void)cacheMyExchangedSteps:(int)steps date:(NSDate *)date mac:(NSString *)mac;
+ (NSDictionary *)cachedExchangedStepsAndDateForMac:(NSString *)mac;//@"date"表示日期,@"steps"表示步数

+ (void)cleanCacheData;

@end
