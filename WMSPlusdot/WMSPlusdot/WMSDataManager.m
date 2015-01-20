//
//  WMSDataManager.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-13.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDataManager.h"
#import "WMSFileMacro.h"

@implementation WMSDataManager

+ (NSArray *)loadAlarmClocks
{
    NSString *fileName = FilePath(FILE_ALRAM_CLOCK);
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    if ([data length] > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        NSArray *array = [unArchiver decodeObjectForKey:@"alarmClocks"];
        [unArchiver finishDecoding];
        return array;
    }
    return [NSArray array];
}
+ (BOOL)savaAlarmClocks:(NSArray *)clocks
{
    NSString *fileName = FilePath(FILE_ALRAM_CLOCK);
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:clocks forKey:@"alarmClocks"];
    [archiver finishEncoding];
    return [data writeToFile:fileName atomically:YES];
}

+ (NSArray *)loadActivityRemind
{
    NSString *fileName = FilePath(FILE_ACTIVITY);
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    if ([data length] > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        NSArray *array = [unArchiver decodeObjectForKey:@"ActivityModels"];
        [unArchiver finishDecoding];
        return array;
    }
    return [NSArray array];
}
+ (BOOL)savaActivityRemind:(NSArray *)activities
{
    NSString *fileName = FilePath(FILE_ACTIVITY);
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:activities forKey:@"ActivityModels"];
    [archiver finishEncoding];
    return [data writeToFile:fileName atomically:YES];
}

@end
