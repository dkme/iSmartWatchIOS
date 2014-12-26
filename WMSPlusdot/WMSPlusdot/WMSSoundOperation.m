//
//  WMSSoundOperation.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-26.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSoundOperation.h"
#import <AudioToolbox/AudioToolbox.h>

void vibrateDidStop(SystemSoundID ssID,void *clientData);
void soundDidStop(SystemSoundID ssID,void *clientData);

__weak WMSSoundOperation *SSelf = nil;

@interface WMSSoundOperation ()
@property (nonatomic, copy) playFinishCallback playFinishBlock;
@end

@implementation WMSSoundOperation
{
    SystemSoundID soundID;
    BOOL isPlaying;
}

- (id)init
{
    if (self = [super init]) {
        SSelf = self;
    }
    return self;
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
    [self clearup];
    SSelf = nil;
}

- (void)setup
{
    NSURL *tapSound = [[NSBundle mainBundle] URLForResource:@"sound_alarm"
                                              withExtension:@"m4r"];
    // Store the URL as a CFURLRef instance
    CFURLRef soundFileURLRef = (__bridge CFURLRef)tapSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID(soundFileURLRef,&soundID);
    
    isPlaying = YES;
}
- (void)clearup
{
    soundID = 0;
    isPlaying = NO;
}

#pragma mark - Public
- (void)playAlarmWithDuration:(NSTimeInterval)duration
   andVibrateWithTimeInterval:(NSTimeInterval)interval
                   completion:(playFinishCallback)aCallback
{
    if (isPlaying) {
        [self stopPlay];
    }
    
    [self setPlayFinishBlock:aCallback];
    [self playAlarmWithDuration:duration];
    [self playVibrateWithTimeInterval:interval];
}

#pragma mark - Private
- (void)playAlarmWithDuration:(NSTimeInterval)duration
{
    [self setup];
    
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundDidStop, NULL);
    AudioServicesPlaySystemSound(soundID);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopPlay) object:nil];
    [self performSelector:@selector(stopPlay) withObject:nil afterDelay:duration];
    
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(continuePlaySound) object:nil];
    //    [self performSelector:@selector(continuePlaySound) withObject:nil afterDelay:player.duration];
}

- (void)playVibrateWithTimeInterval:(NSTimeInterval)interval
{
    //DEBUGLog(@"input interval:%f",interval);
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, vibrateDidStop, &interval);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - Call back
void soundDidStop(SystemSoundID ssID,void *clientData)
{
    AudioServicesPlaySystemSound(ssID);
}
void vibrateDidStop(SystemSoundID ssID,void *clientData)
{
    
    NSTimeInterval interval = *(NSTimeInterval *)clientData;
    //DEBUGLog(@"INTERVAL:%f",interval);
    interval = 1.0;
    [NSObject cancelPreviousPerformRequestsWithTarget:SSelf selector:@selector(continueVibrate) object:nil];
    [SSelf performSelector:@selector(continueVibrate) withObject:nil afterDelay:interval];

}

#pragma mark - Timer
- (void)continueVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//- (void)continuePlaySound
//{
//    AudioServicesPlaySystemSound(soundID);
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(continuePlaySound) object:nil];
//    [self performSelector:@selector(continuePlaySound) withObject:nil afterDelay:1];
//}

- (void)stopPlay
{
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(continuePlaySound) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(continueVibrate) object:nil];
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    if (self.playFinishBlock) {
        self.playFinishBlock();
        [self setPlayFinishBlock:nil];
    }
    [self clearup];
}

@end
