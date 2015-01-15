//
//  WMSFilter.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-15.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSFilter : NSObject

+ (NSArray *)filterForPeripherals:(NSArray *)peripherals withType:(int)type;
+ (NSArray *)descendingOrderPeripheralsWithSignal:(NSArray *)peripherals;

@end
