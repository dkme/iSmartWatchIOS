//
//  HealthManager.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/26.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

typedef NS_ENUM(NSUInteger, SexTypes) {
    SexNotSet = 0,
    SexFemale,
    SexMale,
};

typedef NS_ENUM(NSUInteger, SleepValueType) {
    SleepValueInBed,
    SleepValueTypeASleep,
};

typedef void(^operationCompletedCallback)(BOOL success, NSError *error);
typedef void(^readProfileCallback)(NSDate *birthday, SexTypes sex, double height, double weight, NSError *error);

@interface HealthManager : NSObject

@property (nonatomic, strong, readonly) HKHealthStore *healthKitStore;

+ (instancetype)defaultHealthManager;

- (void)authorizeHealthKit:(operationCompletedCallback)aCallback;

/**
 * @param aCallback 之中的height，weight单位同下
 */
- (void)readProfile:(readProfileCallback)aCallback;

/**
 * @param height 单位为 m
 * @param weight 单位为 kg
 */
- (void)saveUserHeight:(double)height
                weight:(double)weight
                  date:(NSDate *)date
            completion:(operationCompletedCallback)aCallback;

/**
 * @param distance 单位为 km
 * @param calories 单位为 kcal
 */
- (void)saveRunningWorkoutForStartDate:(NSDate *)startDate
                               endDate:(NSDate *)endDate
                                 steps:(NSUInteger)steps
                              distance:(double)distance
                          kiloCalories:(double)calories
                            completion:(operationCompletedCallback)aCallback;

- (void)saveSleepInfoForStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate
                        valueType:(SleepValueType)value
                       completion:(operationCompletedCallback)aCallback;

@end
