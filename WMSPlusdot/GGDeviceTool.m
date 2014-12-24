//
//  GGDeviceTool.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "GGDeviceTool.h"

#define TIME_INTERVAL       0.5

@implementation GGDeviceTool
{
    NSTimer *_onTimer;
    NSTimer *_offTimer;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    //_audioPlayer = nil;
}

+ (id)sharedInstance;
{
    static dispatch_once_t onceToken = 0;
    __strong static GGDeviceTool *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[GGDeviceTool alloc] init];
    });
    return sharedObject;
}

- (void)startWebcamFlicker
{
    [self offToOn];
}

- (void)stopWebcamFlicker
{
    [self turnOffLed];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onToOff) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(offToOn) object:nil];
}

#pragma mark - Timer
- (void)offToOn
{
    DEBUGLog(@"on...");
    [self turnOnLed];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onToOff) object:nil];
    [self performSelector:@selector(onToOff) withObject:nil afterDelay:TIME_INTERVAL];
}
- (void)onToOff
{
    DEBUGLog(@"off...");
    [self turnOffLed];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(offToOn) object:nil];
    [self performSelector:@selector(offToOn) withObject:nil afterDelay:TIME_INTERVAL];
}

#pragma mark - Private
- (void)turnOnLed
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
}

- (void)turnOffLed
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

@end
