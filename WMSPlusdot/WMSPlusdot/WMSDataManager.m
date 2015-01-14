//
//  WMSDataManager.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-13.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDataManager.h"
//#import "WMSAlarmClockModel.h"
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
//+ (WMSAlarmClockModel *)loadAlarmClock
//{
//    NSString *fileName = FilePath(FILE_ALRAM_CLOCK);
//    NSData *data = [NSData dataWithContentsOfFile:fileName];
//    if ([data length] > 0) {
//        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
//        WMSAlarmClockModel *model= [unArchiver decodeObjectForKey:@"alarmClock"];
//        [unArchiver finishDecoding];
//        
//        return model;
//    }
//    return nil;
//}
//+ (void)savaAlarmClock:(WMSAlarmClockModel *)clock
//{
//    //coding
//    NSString *fileName = FilePath(FILE_ALRAM_CLOCK);
//    NSMutableData *data = [NSMutableData data];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
//    [archiver encodeObject:clock forKey:@"alarmClock"];
//    [archiver finishEncoding];
//    [data writeToFile:fileName atomically:YES];
//}

@end
