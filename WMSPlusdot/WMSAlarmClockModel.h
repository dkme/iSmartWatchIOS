//
//  WMSAlarmClockModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSAlarmClockModel : NSObject <NSCoding>

@property (nonatomic, assign) BOOL status;
@property (nonatomic, assign) NSUInteger startHour;
@property (nonatomic, assign) NSUInteger startMinute;
@property (nonatomic, assign) NSUInteger snoozeMinute;
/*
 *表示周一到周日的重复状态，存放NSNumber类型，0表示不重复，非0表示重复
 */
@property (nonatomic, strong) NSArray *repeats;


- (id)initWithStatus:(BOOL)openOrClose
           startHour:(NSUInteger)startHour
         startMinute:(NSUInteger)startMinute
        snoozeMinute:(NSUInteger)snoozeMinute
             repeats:(NSArray *)repeats;

@end
