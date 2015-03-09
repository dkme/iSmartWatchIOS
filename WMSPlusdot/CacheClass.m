//
//  CacheClass.m
//  WMSPlusdot
//
//  Created by Sir on 15-3-7.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "CacheClass.h"

enum {
    CacheKeyID1 = 100,
    CacheKeyID2,
};

@implementation CacheClass

static inline void cacheData(int keyID,id data)
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"com.guogee.plusdot.cache.ID%d",keyID];
    [defs setObject:data forKey:key];
}
static inline id getCachedData(int keyID)
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"com.guogee.plusdot.cache.ID%d",keyID];
    return [defs objectForKey:key];
}

+ (void)cacheMyBeans:(int)beans mac:(NSString *)mac
{
    cacheData(CacheKeyID1, @{mac:@(beans)});
}
+ (int)cachedBeansForMac:(NSString *)mac
{
    NSDictionary *data = getCachedData(CacheKeyID1);
    return [[data objectForKey:mac] intValue];
}

+ (void)cacheMyExchangedSteps:(int)steps date:(NSDate *)date mac:(NSString *)mac
{
    cacheData(CacheKeyID2, @{mac:@{@"date":date,@"steps":@(steps)}});
}
+ (NSDictionary *)cachedExchangedStepsAndDateForMac:(NSString *)mac
{
    NSDictionary *data = getCachedData(CacheKeyID2);
    return [data objectForKey:mac];
}

+ (void)cleanCacheData
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    for (int i=CacheKeyID1; i<=CacheKeyID2; i++) {
        NSString *key = [NSString stringWithFormat:@"com.guogee.plusdot.cache.ID%d",i];
        [defs removeObjectForKey:key];
    }
}

@end
