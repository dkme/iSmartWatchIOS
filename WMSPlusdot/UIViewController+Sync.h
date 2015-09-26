//
//  UIViewController+Sync.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/7/20.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Sync)

@property (nonatomic, assign, getter=isNeedBackWhenAfterSync) BOOL needBackWhenAfterSync;

@end
