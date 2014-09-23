//
//  WMSAlarmClock.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSAlarmClock : NSObject

@property (nonatomic, assign, readonly) Byte clockID;

@property (nonatomic, assign) Byte hour;

@property (nonatomic, assign) Byte minute;

@property (nonatomic, assign) Byte repetitions;


- (id)initWithHour:(Byte)hour
        withMinute:(Byte)minute
   withRepetitions:(Byte)repeat;

/**
 
 */


@end
