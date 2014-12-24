//
//  GGAudioTool.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "GGAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@interface GGAudioTool()<AVAudioPlayerDelegate>

@end

@implementation GGAudioTool
{
    AVAudioPlayer *_audioPlayer;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    _audioPlayer = nil;
}

+ (id)sharedInstance;
{
    static dispatch_once_t onceToken = 0;
    __strong static GGAudioTool *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[GGAudioTool alloc] init];
    });
    return sharedObject;
}

- (void)playSilentSound
{
    if (_audioPlayer && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Audio" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 0.0;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];//这样后台播放就不会影响到别的程序播放音乐了
    [_audioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _audioPlayer = nil;
}

@end
