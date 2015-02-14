//
//  WMSRequestTool.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSRequestTool.h"
#import "Activity.h"
#import "ActivityRule.h"
#import "GiftBag.h"
#import "NSDate+Formatter.h"
#import "WMSURLMacro.h"

@implementation WMSRequestTool

static inline NSString* UTF8Encoding(NSString *url)
{
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (void)requestActivityList:(requestActivityListCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_ACTIVITY_LIST];
    [self JSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                NSArray *arr = json[@"list"];
                NSMutableArray *list = [NSMutableArray arrayWithCapacity:arr.count];
                for (int i=0; i<arr.count; i++) {
                    NSDictionary *dicObj = arr[i];
                    int actID = [dicObj[@"actid"] intValue];
                    NSString *actName = dicObj[@"actname"];
                    NSString *memo = dicObj[@"actmemo"];
                    NSString *gameName = dicObj[@"actgamename"];
                    NSString *logo = dicObj[@"actlogo"];
                    NSDate *beginDate = [NSDate dateFromString:dicObj[@"actbegindate"] format:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate dateFromString:dicObj[@"actenddate"] format:@"yyyy-MM-dd HH:mm:ss"];
                    Activity *act = [[Activity alloc] initWithID:actID actName:actName beginDate:beginDate endDate:endDate memo:memo gameName:gameName logo:logo];
                    [list addObject:act];
                }
                aCallback(YES,list);
            } else {
                aCallback(NO,nil);
            }
        }else{}
    } fail:^{
        DEBUGLog(@"request fail");
        if (aCallback) {
            aCallback(NO,nil);
        }else{}
    }];
}

+ (void)requestActivityDetailsWithActivityID:(int)actID
                                  completion:(requestActivityDetailsCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_ACTIVITY_RULE];
    url = [url stringByAppendingFormat:@"?actid=%d",actID];
    [self JSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                NSDictionary *dicObj = json[@"data"];
                ActivityRule *rule = [[ActivityRule alloc] init];
                rule.ruleID = [dicObj[@"rlid"] intValue];
                rule.ruleType = [dicObj[@"rltype"] intValue];
                rule.count = [dicObj[@"rlcount"] intValue];
                rule.cycleType = [dicObj[@"rlcycletype"] intValue];
                rule.cycleCount = [dicObj[@"rlcyclecount"] intValue];
                rule.ruleMemo = dicObj[@"rlmemo"];
                rule.activityID = [dicObj[@"rlactid"] intValue];
                aCallback(YES,rule);
            } else {
                aCallback(NO,nil);
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,nil);
        }else{}
    }];
}

+ (void)requestGiftBagListWithUserKey:(NSString *)key
                           completion:(requestGiftBagListCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_GIFT_BAG_LIST];
    url = [url stringByAppendingFormat:@"?gbuserkey=%@",key];
    [self JSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                NSArray *arr = json[@"data"];
                NSMutableArray *list = [NSMutableArray arrayWithCapacity:arr.count];
                for (int i=0; i<arr.count; i++) {
                    NSDictionary *dicObj = arr[i];
                    GiftBag *bag = [[GiftBag alloc] init];
                    bag.gbID = [dicObj[@"gbid"] intValue];
                    bag.userKey = dicObj[@"gbuserkey"];
                    bag.exchangeCode = dicObj[@"gbcode"];
                    bag.getDate = dicObj[@"gbdate"];
                    [list addObject:bag];
                }
                aCallback(YES,list);
            } else {
                aCallback(NO,nil);
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,nil);
        }else{}
    }];
}

+ (void)requestGetGiftBagWithUserKey:(NSString *)key
                          activityID:(int)actID
                           secretKey:(NSString *)sKey
                          completion:(requestGetGiftBagCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_GIFT_BAG_GETBAG];
    url = [url stringByAppendingFormat:@"?gbuserkey=%@&actid=%d&skey=%@",key,actID,sKey];
    [self POSTJSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                NSArray *arr = json[@"data"];
                NSDictionary *dicObj = arr[0];
                GiftBag *bag = [[GiftBag alloc] init];
                bag.gbID = [dicObj[@"gbid"] intValue];
                bag.userKey = dicObj[@"gbuserkey"];
                bag.exchangeCode = dicObj[@"gbcode"];
                bag.getDate = dicObj[@"gbdate"];
                aCallback(YES,bag);
            } else {
                aCallback(NO,nil);
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,nil);
        }else{}
    }];
}

+ (void)JSONDataWithUrl:(NSString *)url success:(void(^)(id json))success fail:(void(^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //NSDictionary *dict = @{@"format": @"json"};
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DEBUGLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}
+ (void)POSTJSONDataWithUrl:(NSString *)url success:(void(^)(id json))success fail:(void(^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DEBUGLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}

@end
