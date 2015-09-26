//
//  WMSSoundOperation.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-26.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^playFinishCallback)(void);

@interface WMSSoundOperation : NSObject

- (id)init;

//- (void)playAlarmWithDuration:(NSTimeInterval)duration;

//- (void)playVibrateWithTimeInterval:(NSTimeInterval)interval;

- (void)playAlarmWithDuration:(NSTimeInterval)duration
   andVibrateWithTimeInterval:(NSTimeInterval)interval
                   completion:(playFinishCallback)aCallback;


/**
 * 播放报警声
 * @param duration 播放的时长，-1表示一直播放
 */
- (void)playSoundWithFile:(NSString *)filePath
                 duration:(NSTimeInterval)duration;

- (void)stop;

@end
