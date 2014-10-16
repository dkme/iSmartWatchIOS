//
//  WMSActivityModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSActivityModel : NSObject<NSCoding>

@property (nonatomic) BOOL status;
@property (nonatomic) NSUInteger startHour;
@property (nonatomic) NSUInteger startMinute;
@property (nonatomic) NSUInteger endHour;
@property (nonatomic) NSUInteger endMinute;
@property (nonatomic) NSUInteger intervalMinute;
/*
 *表示周一到周日的重复状态，存放NSNumber类型，0表示不重复，非0表示重复
 */
@property (nonatomic, strong) NSArray *repeats;

- (id)initWithStatus:(BOOL)status
           startHour:(NSUInteger)startHour
         startMinute:(NSUInteger)startMinute
             endHour:(NSUInteger)endHour
           endMinute:(NSUInteger)endMinute
      intervalMinute:(NSUInteger)intervalMinute
             repeats:(NSArray *)repeats;

@end
