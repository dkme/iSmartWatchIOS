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

@end
