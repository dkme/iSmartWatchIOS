//
//  WMSRequestTool.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheClass.h"
@class ActivityRule;
@class GiftBag;

#define SECRET_KEY                          @"guogee_shoubiao"

/***********error code*****************/
//enum {
//    //RequestResultCode_NOTRESULT = 10000001,//没有返回数据
//    RequestResultCode_FAILED = 10000002,//有返回数据，但没成功/没有返回数据（服务器错误）
//    RequestResultCode_SUCCESS = 10000003,//有返回数据，解析成功
//    RequestResultCode_NODATA = 10000004,//解析成功，但是没有数据
//} RequestResultCode;
typedef NS_ENUM(NSInteger, RequestErrorCode) {
    RequestErrorCodeNotError        = 50001,
    RequestErrorCodeServerError     = 50002,
    RequestErrorCodeResultDataFormatError = 50003,
};
extern NSString* const RequestErrorDescriptionNotError;
extern NSString* const RequestErrorDescriptionServerError;
extern NSString* const RequestErrorDescriptionResultDataFormatError;


//Block
typedef void (^requestActivityListCallBack)(BOOL result,NSArray *list);
typedef void (^requestActivityDetailsCallBack)(BOOL result,NSArray *rultList);
typedef void (^requestGiftBagListCallBack)(BOOL result,NSArray *list);
typedef void (^requestGetGiftBagCallBack)(BOOL result,NSString *exchangeCode);
typedef void (^requestExchangeRuleListCallBack)(BOOL result,NSArray *list);
typedef void (^requestGetBeanCallBack)(BOOL result,int beans);
typedef void (^requestUserBeansCallBack)(BOOL result,int beans,NSError *error);

typedef void (^requestCallBack)(BOOL result,id data,NSError *error);

@interface WMSRequestTool : NSObject

/**
 *  返回所有的活动，list中是Activity对象
 */
+ (void)requestActivityList:(requestCallBack)aCallback;

/**
 *  根据活动ID，请求活动的具体详情
 */
+ (void)requestActivityDetailsWithActivityID:(int)actID
                                  completion:(requestActivityDetailsCallBack)aCallback;

/**
 *  userKey 用户唯一标识，此处传入手表的mac地址即可
 *  返回有效的礼包
 */
+ (void)requestGiftBagListWithUserKey:(NSString *)key
                           completion:(requestCallBack)aCallback;

/**
 *  领取礼包
 *  @param sKey    提交到服务器的秘钥，初步定义为:guogee_shoubiao
 *  @param aCallback    当result为YES,data不为nil时，表示兑换礼包成功；当result为YES,data为nil时，表示当天已经兑换过1次礼包
 */
+ (void)requestGetGiftBagWithUserKey:(NSString *)key
                          activityID:(int)actID
                           secretKey:(NSString *)sKey
                          completion:(requestCallBack)aCallback;

/**
 *  获取兑换能量豆的规则列表
 */
+ (void)requestExchangeRuleList:(requestExchangeRuleListCallBack)aCallback;

/**
 *  领取能量豆
 */
+ (void)requestGetBeanWithUserKey:(NSString *)key
                       beanNumber:(int)beans
                        secretKey:(NSString *)sKey
                       completion:(requestGetBeanCallBack)aCallback;

/**
 *  获取用户的能量豆数量
 */
+ (void)requestUserBeansWithUserKey:(NSString *)key
                         completion:(requestUserBeansCallBack)aCallback;



@end
