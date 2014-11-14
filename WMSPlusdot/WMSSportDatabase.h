//
//  WMSSportDatabase.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSSportModel;

@interface WMSSportDatabase : NSObject

+ (WMSSportDatabase *)sportDatabase;

- (BOOL)insertSportData:(WMSSportModel *)model;

- (NSArray *)queryAllSportData;

- (NSArray *)querySportData:(NSDate *)sportDate;

- (NSArray *)querySportDataWithYear:(NSUInteger)year month:(NSUInteger)month;

- (NSDate *)queryEarliestDate;

- (BOOL)updateSportData:(WMSSportModel *)model;

- (BOOL)deleteAllSportData;

- (BOOL)deleteSportData:(WMSSportModel *)model;

@end
