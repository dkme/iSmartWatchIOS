//
//  WMSSportModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-11.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSSportModel : NSObject

@property (nonatomic, strong) NSDate *sportDate;
@property (nonatomic, assign) NSUInteger targetSteps;
@property (nonatomic, assign) NSUInteger sportSteps;
@property (nonatomic, assign) NSUInteger sportMinute;
@property (nonatomic, assign) NSUInteger sportDistance;
@property (nonatomic, assign) NSUInteger sportCalorie;//单位大卡
@property (nonatomic, assign) UInt16 *perHourData;
@property (nonatomic, assign) NSUInteger dataLength;

//- (id)initWithSportDate:(NSDate *)sportDate
//            targetSteps:(NSUInteger)targetSteps
//             sportSteps:(NSUInteger)sportSteps
//            sportMinute:(NSUInteger)sportMinute
//          sportDistance:(NSUInteger)sportDistance
//           sportCalorie:(NSUInteger)sportCalorie;

//- (id)initWithSportDate:(NSDate *)sportDate
//             sportSteps:(NSUInteger)sportSteps
//            sportMinute:(NSUInteger)sportMinute
//          sportDistance:(NSUInteger)sportDistance
//           sportCalorie:(NSUInteger)sportCalorie;

- (id)initWithSportDate:(NSDate *)sportDate
       sportTargetSteps:(NSUInteger)targerSteps
             sportSteps:(NSUInteger)sportSteps
            sportMinute:(NSUInteger)sportMinute
          sportDistance:(NSUInteger)sportDistance
           sportCalorie:(NSUInteger)sportCalorie
            perHourData:(UInt16 *)perHourData
             dataLength:(NSUInteger)dataLength;

- (void)setPerHourData:(UInt16 *)perHourData withLength:(int)length;

@end
