//
//  WMSRequestTool.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActivityRule;
@class GiftBag;

//Block
typedef void (^requestActivityListCallBack)(BOOL result,NSArray *list);
typedef void (^requestActivityDetailsCallBack)(BOOL result,ActivityRule *rult);
typedef void (^requestGiftBagListCallBack)(BOOL result,NSArray *list);
typedef void (^requestGetGiftBagCallBack)(BOOL result,GiftBag *bag);

@interface WMSRequestTool : NSObject

/**
 *  返回所有的活动，list中是Activity对象
 */
+ (void)requestActivityList:(requestActivityListCallBack)aCallback;

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
                           completion:(requestGiftBagListCallBack)aCallback;

/**
 *  领取礼包
 *  sKey    提交到服务器的秘钥，初步定义为:guogee_shoubiao
 */
+ (void)requestGetGiftBagWithUserKey:(NSString *)key
                          activityID:(int)actID
                           secretKey:(NSString *)sKey
                          completion:(requestGetGiftBagCallBack)aCallback;

@end
