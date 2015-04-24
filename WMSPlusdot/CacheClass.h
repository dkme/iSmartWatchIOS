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

+ (void)cacheFirstSyncDataResult:(BOOL)hasData;//第一次同步是否有数据
+ (BOOL)cacheIsHasData;

+ (void)cleanCacheData;

@end
