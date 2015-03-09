//
//  GiftBag.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "GiftBag.h"

@implementation GiftBag

- (NSString *)description
{
    return [NSString stringWithFormat:@"[gbID=%d,userKey=%@,exchangeCode=%@,getDate=%@,logo=%@,gameName=%@,memo=%@]",_gbID,_userKey,_exchangeCode,_getDate,_logo,_gameName,_memo];
}

@end
