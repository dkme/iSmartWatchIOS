//
//  GiftBag.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftBag : NSObject

@property (nonatomic) int gbID;
@property (nonatomic, strong) NSString *userKey;/*用户唯一标识，目前填手表的mac地址即可*/
@property (nonatomic, strong) NSString *exchangeCode;
@property (nonatomic, strong) NSDate *getDate;
@property (nonatomic, strong) NSString *logo;

@end
