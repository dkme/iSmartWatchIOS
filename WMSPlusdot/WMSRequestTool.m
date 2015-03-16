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
#import "ExchangeBeanRule.h"
#import "NSDate+Formatter.h"
#import "WMSURLMacro.h"

NSString* const RequestErrorDescriptionNotError
= @"请求成功";
NSString* const RequestErrorDescriptionServerError
= @"服务器错误";
NSString* const RequestErrorDescriptionResultDataFormatError
= @"服务器返回的数据格式错误";

@implementation WMSRequestTool

static inline NSString* UTF8Encoding(NSString *url)
{
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
static inline NSError* ERROR(NSInteger code,NSString *localizedDescription)
{
    return [NSError errorWithDomain:@"com.guogee.plusdot.httpRequest" code:code userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

+ (void)requestActivityList:(requestCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_ACTIVITY_LIST];
    [self JSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                return ;
            }
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                if (json[@"list"] == nil) {//表示没有数据
                    NSArray *arr = [[NSArray alloc] init];
                    aCallback(YES,arr,nil);
                    return ;
                }
                //有数据...
                if (![json[@"list"] isKindOfClass:[NSArray class]]) {
                    aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                    return ;
                }
                NSArray *arr = json[@"list"];
                NSMutableArray *list = [NSMutableArray arrayWithCapacity:arr.count];
                for (int i=0; i<arr.count; i++) {
                    if (![arr[i] isKindOfClass:[NSDictionary class]]) {
                        aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                        return ;
                    }
                    NSDictionary *dicObj = arr[i];
                    Activity *act = [[Activity alloc] init];
                    act.actID = [dicObj[@"actid"] intValue];
                    act.actName = dicObj[@"actname"];
                    act.actMemo = dicObj[@"actmemo"];
                    act.gameName = dicObj[@"actgamename"];
                    act.beginDate = [NSDate dateFromString:dicObj[@"actbegindate"] format:@"yyyy-MM-dd"];
                    act.endDate = [NSDate dateFromString:dicObj[@"actenddate"] format:@"yyyy-MM-dd"];
                    act.consumeBeans = [dicObj[@"actbeanbag"] intValue];
                    
//                    NSString *logoURL = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_ACTIVITY_LOGO];
//                    logoURL = [logoURL stringByAppendingPathComponent:dicObj[@"actlogo"]];
//                    logoURL = [logoURL stringByAppendingString:@".jpg"];
//                    act.logo = logoURL;
                    act.logo = dicObj[@"actlogo"];
                    [list addObject:act];
                }
                aCallback(YES,list,nil);
                
            } else {
                aCallback(NO,nil,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,nil,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
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
            if (![json isKindOfClass:[NSDictionary class]]) {
                aCallback(NO,nil);
                return ;
            }
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                if (![json[@"actruleinfo"] isKindOfClass:[NSArray class]])
                {
                    aCallback(NO,nil);
                    return ;
                }
                NSArray *arrObj = json[@"actruleinfo"];
                NSMutableArray *mutiArr = [NSMutableArray arrayWithCapacity:arrObj.count];
                for (id obj in arrObj) {
                    if (![obj isKindOfClass:[NSDictionary class]]) {
                        aCallback(NO,nil);
                        return ;
                    }
                    NSDictionary *dicObj = obj;
                    ActivityRule *rule = [[ActivityRule alloc] init];
                    rule.ruleID = [dicObj[@"ariid"] intValue];
                    rule.ruleType = [dicObj[@"aritype"] intValue];
                    rule.count = [dicObj[@"aricount"] intValue];
                    if (dicObj[@"aricltype"]) {
                        rule.cycleType = 1;//[dicObj[@"aricltype"] intValue];
                    } else {
                        rule.cycleType = 0;
                    }
                    rule.cycleCount = [dicObj[@"ariclcounts"] intValue];
                    rule.ruleMemo = dicObj[@"arimemo"];
                    rule.activityID = [dicObj[@"ariactid"] intValue];
                    
                    [mutiArr addObject:rule];
                }
                aCallback(YES,mutiArr);
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
                           completion:(requestCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_GIFT_BAG_LIST];
    url = [url stringByAppendingFormat:@"?gbuserkey=%@",key];
    [self JSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                return ;
            }
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                if (![json[@"data"] isKindOfClass:[NSArray class]]) {
                    aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                    return ;
                }
                NSArray *arr = json[@"data"];
                NSMutableArray *list = [NSMutableArray arrayWithCapacity:arr.count];
                for (int i=0; i<arr.count; i++) {
                    if (![arr[i] isKindOfClass:[NSDictionary class]]) {
                        aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                        return ;
                    }
                    NSDictionary *dicObj = arr[i];
                    if ([dicObj[@"giftbag"] isKindOfClass:[NSDictionary class]] &&
                        [dicObj[@"activityinfo"] isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *dicObj0 = dicObj[@"giftbag"];
                        NSDictionary *dicObj1 = dicObj[@"activityinfo"];
                        GiftBag *bag = [[GiftBag alloc] init];
                        bag.gbID = [dicObj0[@"gbactid"] intValue];
                        bag.userKey = dicObj0[@"gbuserkey"];
                        bag.exchangeCode = dicObj0[@"gbcode"];
                        bag.getDate = dicObj0[@"gbdate"];
//                        NSString *logoURL = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_ACTIVITY_LOGO];
//                        logoURL = [logoURL stringByAppendingPathComponent:dicObj1[@"actlogo"]];
//                        logoURL = [logoURL stringByAppendingString:@".jpg"];
//                        bag.logo = logoURL;
                        bag.logo = dicObj1[@"actlogo"];
                        bag.gameName = dicObj1[@"actgamename"];
                        bag.memo = dicObj1[@"actgiftbagmemo"];
                        bag.expiryDate = [NSDate dateFromString:dicObj1[@"actenddate"] format:@"yyyy-MM-dd"];
                        [list addObject:bag];
                    } else {
                        aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                        return ;
                    }
                }
                aCallback(YES,list,nil);
            } else {
                aCallback(NO,nil,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,nil,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
        }else{}
    }];
}

+ (void)requestGetGiftBagWithUserKey:(NSString *)key
                          activityID:(int)actID
                           secretKey:(NSString *)sKey
                          completion:(requestCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_GIFT_BAG_GETBAG];
    url = [url stringByAppendingFormat:@"?gbuserkey=%@&actid=%d&skey=%@",key,actID,sKey];
    [self POSTJSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                return ;
            }
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                if (![json[@"datas"] isKindOfClass:[NSDictionary class]]) {
                    aCallback(NO,nil,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                    return ;
                }
                NSDictionary *dicObj = json[@"datas"];
                NSString *code = dicObj[@"accode"];
                aCallback(YES,code,nil);
            } else {
                aCallback(NO,nil,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,nil,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
        }else{}
    }];
}

+ (void)requestExchangeRuleList:(requestExchangeRuleListCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_GET_BEAN_RULE];
    [self JSONDataWithUrl:UTF8Encoding(url) success:^(id json) {
        if (aCallback) {
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                NSArray *arr = json[@"datas"];
                NSMutableArray *list = [NSMutableArray arrayWithCapacity:arr.count];
                for (int i=0; i<arr.count; i++) {
                    NSDictionary *dicObj = arr[i];
                    ExchangeBeanRule *rule = [[ExchangeBeanRule alloc] init];
                    rule.beanNumber = [dicObj[@"berbeancount"] intValue];
                    rule.eventNumber = [dicObj[@"bereventcount"] intValue];
                    rule.ruleID = [dicObj[@"berid"] intValue];
                    rule.ruleType = [dicObj[@"bertype"] intValue];
                    [list addObject:rule];
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

+ (void)requestGetBeanWithUserKey:(NSString *)key
                       beanNumber:(int)beans
                        secretKey:(NSString *)sKey
                       completion:(requestGetBeanCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_USER_GET_BEAN];
    NSDictionary *parameters = @{@"usbuserkey":key,@"usbbeancount":@(beans),@"skey":sKey};
    [self POSTJSONDataWithUrl:UTF8Encoding(url) parameters:parameters success:^(id json) {
        if (aCallback) {
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                NSDictionary *dicObj = json[@"datas"];
                int beans = [dicObj[@"usbbeancount"] intValue];
                aCallback(YES,beans);
            } else {
                aCallback(NO,0);
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,0);
        }else{}
    }];
}

+ (void)requestUserBeansWithUserKey:(NSString *)key
                         completion:(requestUserBeansCallBack)aCallback
{
    NSString *url = [URL_GIFT_AND_BEANS stringByAppendingPathComponent:API_USER_BEANS];
    NSDictionary *parameters = @{@"usbuserkey":key};
    [self JSONDataWithUrl:UTF8Encoding(url) parameters:parameters success:^(id json) {
        if (aCallback) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                aCallback(NO,0,ERROR(RequestErrorCodeResultDataFormatError, RequestErrorDescriptionResultDataFormatError));
                return ;
            }
            int code = [json[@"code"] intValue];
            if (code == 200) {//成功
                if ([json[@"data"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dicObj = json[@"data"];
                    int beans = [dicObj[@"usbbeancount"] intValue];
                    aCallback(YES,beans,nil);
                } else {//表示没有数据
                    aCallback(YES,0,nil);
                }
            } else {
                aCallback(NO,0,ERROR(RequestErrorCodeServerError, RequestErrorDescriptionServerError));
            }
        }else{}
    } fail:^{
        if (aCallback) {
            aCallback(NO,0,ERROR(RequestErrorCodeServerError,RequestErrorDescriptionServerError));
        }else{}
    }];
}

#pragma mark - Private
+ (void)JSONDataWithUrl:(NSString *)url success:(void(^)(id json))success fail:(void(^)())fail
{
    [self JSONDataWithUrl:url parameters:nil success:success fail:fail];
}
+ (void)POSTJSONDataWithUrl:(NSString *)url success:(void(^)(id json))success fail:(void(^)())fail
{
    [self POSTJSONDataWithUrl:url parameters:nil success:success fail:fail];
}

+ (void)JSONDataWithUrl:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id json))success fail:(void(^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
+ (void)POSTJSONDataWithUrl:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id json))success fail:(void(^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
