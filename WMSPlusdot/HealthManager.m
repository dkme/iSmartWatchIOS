//
//  HealthManager.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/29.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "HealthManager.h"

@implementation HealthManager


+ (instancetype)defaultHealthManager
{
    static HealthManager *_obj = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _obj = [[self alloc] init];
    });
    return _obj;
}
- (instancetype)init
{
    if (self = [super init]) {
        _healthKitStore = [[HKHealthStore alloc] init];
    }
    return self;
}

- (void)authorizeHealthKit:(operationCompletedCallback)aCallback
{
    NSSet *healthKitTypesToWrite = [NSSet setWithArray:@[
                                                         [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],//步数
                                                         [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                                                         [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                                                         [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                                                         [HKObjectType workoutType],
                                                         ]];
    NSSet *healthKitTypesToRead = [NSSet setWithArray:@[
                                                        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                                        ]];
    
    if (![HKHealthStore isHealthDataAvailable]) {
        NSError *error = [NSError errorWithDomain:@"com.guogee.HealthManager" code:100 userInfo:@{
                                                                                                  NSLocalizedDescriptionKey:@"HealthKit is not available in this Device",
                                                                                                  }];
        if (aCallback) {
            aCallback(NO, error);
        }
        return ;
    }
    
    [self.healthKitStore requestAuthorizationToShareTypes:healthKitTypesToWrite readTypes:healthKitTypesToRead completion:^(BOOL success, NSError *error) {
        if (aCallback) {
            aCallback(success, error);
        }
    }];
}

- (void)saveRunningWorkoutForStartDate:(NSDate *)startDate
                               endDate:(NSDate *)endDate
                                 steps:(NSUInteger)steps
                              distance:(double)distance
                          kiloCalories:(double)calories
                            completion:(operationCompletedCallback)aCallback
{
    HKQuantity *stepsQuantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:steps];
    HKQuantitySample *stepsSample = [HKQuantitySample quantitySampleWithType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount] quantity:stepsQuantity startDate:startDate endDate:endDate];
    
    //
    HKQuantity *distanceQuantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance*1000];
    HKQuantity *caloriesQuantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:calories];
    NSTimeInterval duration = fabs([startDate timeIntervalSinceDate:endDate]);
    HKWorkout *workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning startDate:startDate endDate:endDate duration:duration totalEnergyBurned:caloriesQuantity totalDistance:distanceQuantity metadata:nil];
    
    WeakObj(self, weakSelf);
    [self.healthKitStore saveObjects:@[stepsSample,workout] withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            if (aCallback) {
                aCallback(NO, error);
            }
            return ;
        }
        
        StrongObj(weakSelf, strongSelf);
        if (!strongSelf) {
            return ;
        }
        HKQuantitySample *distanceSample = [HKQuantitySample quantitySampleWithType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning] quantity:distanceQuantity startDate:startDate endDate:endDate];
        HKQuantitySample *caloriesSample = [HKQuantitySample quantitySampleWithType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned] quantity:caloriesQuantity startDate:startDate endDate:endDate];
        [strongSelf.healthKitStore addSamples:@[distanceSample, caloriesSample] toWorkout:workout completion:^(BOOL success, NSError *error) {
            if (aCallback) {
                aCallback(success, error);
            }
        }];
    }];
}

- (void)saveSleepInfoForStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate
                        valueType:(SleepValueType)value
                       completion:(operationCompletedCallback)aCallback
{
    HKCategoryType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKCategorySample *sleepSample = [HKCategorySample categorySampleWithType:sleepType value:value startDate:startDate endDate:endDate];
    
    [self.healthKitStore saveObject:sleepSample withCompletion:^(BOOL success, NSError *error) {
        if (aCallback) {
            aCallback(success, error);
        }
    }];
}



- (void)readSteps
{
    NSDate *startDate = [NSDate dateFromString:@"2015-07-01" format:@"yyyy-MM-dd"];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate dateWithTimeInterval:1*24*60*60 sinceDate:startDate] options:HKQueryOptionNone];
    NSPredicate *workoutPredicate = [HKQuery predicateForWorkoutsWithWorkoutActivityType:HKWorkoutActivityTypeRunning];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];///按照开始日期的降序排列，所以第一条数据是最新的
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount] predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        DEBUGLog(@"error:%@, results:%@", error, results);
        DEBUGLog(@"result type:%@", [results[0] class]);
        
        HKQuantitySample *sample = results[0];
        int steps = [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
        NSDate *date1 = [sample startDate];
        NSDate *date2 = [sample endDate];
        DEBUGLog(@"steps:%d, date1:%@, date2:%@", steps, date1, date2);
        ///results会列出指定时间段内的所有数据点，根据以上方法，可以获取相应的步数，已经起止时间
        ///在使用中，我们通常回去获取某一天的全部步数，所以需要将当天的所有数据点，累加起来
        ///可以建立一个model
    }];
    [self.healthKitStore executeQuery:sampleQuery];
    
    ///
    HKSampleQuery *workoutSampleQuery = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType workoutType] predicate:workoutPredicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        HKWorkout *workout = results[0];
        double distance = [workout.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
        double calories = [workout.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
    }];
    [self.healthKitStore executeQuery:workoutSampleQuery];
}


@end
