//
//  UITableViewCell+Activity.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-12.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Activity, GiftBag;

@interface UITableViewCell (Activity)

- (void)configureCellWithActivity:(Activity *)activity;

- (void)configureCellWithGiftBag:(GiftBag *)bag;

@end
