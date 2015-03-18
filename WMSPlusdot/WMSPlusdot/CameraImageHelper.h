//
//  CameraImageHelper.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, CameraFlashMode) {
    CameraFlashModeOff  = AVCaptureFlashModeOff,
    CameraFlashModeOn   = AVCaptureFlashModeOn,
    CameraFlashModeAuto = AVCaptureFlashModeAuto,
};

@protocol AVHelperDelegate;

@interface CameraImageHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	AVCaptureSession *session;
	UIImage *image;
    AVCaptureVideoPreviewLayer *preview;
    AVCaptureStillImageOutput *captureOutput;
    UIImageOrientation g_orientation;
        
    id<AVHelperDelegate>delegate;
}
@property (retain) AVCaptureSession *session;
@property (retain) AVCaptureStillImageOutput *captureOutput;
@property (retain) UIImage *image;
@property (assign) UIImageOrientation g_orientation;
@property (assign) AVCaptureVideoPreviewLayer *preview;
@property (assign) id<AVHelperDelegate>delegate;

- (void) startRunning;
- (void) stopRunning;

-(void)setDelegate:(id<AVHelperDelegate>)_delegate;
-(void)CaptureStillImage;
- (void)embedPreviewInView: (UIView *) aView;
- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;


//- (BOOL)isFrontCamera;
- (CameraFlashMode)currentFlashMode;
/**
 *  切换前后摄像头
 *
 *  @param isFrontCamera YES:前摄像头  NO:后摄像头
 */
- (void)switchCamera:(BOOL)isFrontCamera;

/**
 *  切换闪光灯模式
 *  （切换顺序：最开始是auto，然后是off，最后是on，一直循环）
 *  @param sender: 闪光灯按钮
 */
- (void)switchFlashMode:(CameraFlashMode)flashMode;

@end

@protocol AVHelperDelegate <NSObject>

@optional
-(void)didFinishedCapture:(UIImage*)_img;

-(void)foucusStatus:(BOOL)isadjusting;

@end
