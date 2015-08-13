//
//  NSTimeZone+TimeDifference.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/8/11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimeZone (TimeDifference)

- (NSInteger)timeDifferenceSinceTimeZone:(NSTimeZone *)timeZone;

@end
