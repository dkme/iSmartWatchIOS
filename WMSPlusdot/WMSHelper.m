//
//  WMSHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-11-14.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSHelper.h"
#import "NSDate+Formatter.h"
#import "WMSFileMacro.h"

#define DEFAULT_TARGET_STEPS    20000

@implementation WMSHelper

+ (NSString *)describeWithDate:(NSDate *)date andFormart:(NSString *)formart
{
    switch ([NSDate compareDate:date]) {
        case NSDateModeToday:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeYesterday:
            return NSLocalizedString(@"Yesterday",nil);
        case NSDateModeTomorrow:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeUnknown:
            return [NSDate stringFromDate:date format:formart];
        default:
            return nil;
    }
    return nil;
}

+ (NSUInteger)readTodayTargetSteps
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_TARGET)];
    NSString *key = [NSDate stringFromDate:[NSDate systemDate] format:@"yyyy-MM-dd"];
    NSNumber *value = [readData objectForKey:key];
    NSUInteger target = 0;
    if (readData==nil || value==nil) {
        target = DEFAULT_TARGET_STEPS;
    } else {
        target = [value unsignedIntegerValue];
    }
    return target;
}

+ (BOOL)savaTodayTargetSteps:(NSUInteger)steps
{
    NSString *key = [NSDate stringFromDate:[NSDate systemDate] format:@"yyyy-MM-dd"];
    NSDictionary *writeData = @{key:@(steps)};
    return [writeData writeToFile:FilePath(FILE_TARGET) atomically:YES];
}

+ (void)clearCache
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *files = @[FILE_TARGET,FILE_SETTINGS,FILE_REMIND,FILE_REMIND_WAY];
        for (NSString *file in files) {
            NSString *path = FilePath(file);
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
    });
}

@end
