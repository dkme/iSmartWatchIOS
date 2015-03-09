//
//  UITableViewCell+Configure.h
//  WMSPlusdot
//
//  Created by Sir on 15-3-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ExchangeBeanRule, Activity, GiftBag;

@interface UITableViewCell (Configure)

- (void)configureCellWithActivity:(Activity *)activity;

- (void)configureCellWithGiftBag:(GiftBag *)bag;

- (void)configureCellWithExchangeBeanRule:(ExchangeBeanRule *)rule
                                indexPath:(NSIndexPath *)indexPath;

@end
