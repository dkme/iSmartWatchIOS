//
//  WMSUpdateVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSUpdateVC.h"
#import "WMSAppDelegate.h"

#import "WMSNavBarView.h"
#import "LDProgressView.h"

#import "WMSFileMacro.h"
#import "WMSUpdateVCHelper.h"

#import "DFUOperations.h"
#import "Utility.h"

@interface WMSUpdateVC ()<DFUOperationsDelegate>
{
    WMSUpdateVCHelper *_updateHelper;
    DFUOperations *_dfuOperations;
}
@property (weak, nonatomic) IBOutlet LDProgressView *progressView;

@end

@implementation WMSUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupNavBarView];
    [self setupTextView];
    [self setupUI];
    [self initProperty];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - setup UI
- (void)setupNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
    self.navBarView.labelTitle.text = self.navBarTitle;
    self.navBarView.labelTitle.font = Font_DINCondensed(20.0);
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setupTextView
{
    NSString *txt = [NSString stringWithFormat:@"%@:\n     %@",NSLocalizedString(@"更新说明",nil),_updateDescribe];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.text = txt;
    self.textView.editable = NO;
}
- (void)setupUI
{
    UIImage *image = [UIImage imageNamed:@"zq_public_green_btn_a.png"];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
    frame.origin.x = (ScreenWidth-frame.size.width)/2.0;
    frame.origin.y = ScreenHeight-frame.size.height-10.0;
    [self.buttonUpdate setFrame:frame];
    [self.buttonUpdate setBackgroundImage:image forState:UIControlStateNormal];
    [self.buttonUpdate setBackgroundImage:[UIImage imageNamed:@"zq_public_green_btn_b.png"] forState:UIControlStateSelected];
    [self.buttonUpdate setTitle:NSLocalizedString(@"立即更新", nil) forState:UIControlStateNormal];
    [self.buttonUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //LDProgressView
    self.progressView.borderRadius = @(0);
    self.progressView.type = LDProgressStripes;
    self.progressView.color = UICOLOR_DEFAULT;
    self.progressView.progress = 0.0;
    self.progressView.hidden = YES;
    
}

- (void)initProperty
{
    _updateHelper = [WMSUpdateVCHelper instance];
}

#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAction:(id)sender {
    WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
    if ([bleControl isConnected] == NO) {
        return;
    }
    
    NSString *peipheralUUID = [bleControl.connectedPeripheral UUIDString];
    [bleControl switchToUpdateModeCompletion:^(BOOL success, NSString *failReason) {
        DEBUGLog(@"切换至升级模式%@",success?@"成功":@"失败");
        //此时会断开连接，发送通知
        [self scanPeipheral:peipheralUUID];
    }];
    
    //peipheralUUID = @"C3817558-B47C-8E51-D801-78921502CB04";
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanPeipheral:) object:peipheralUUID];
    [self performSelector:@selector(scanPeipheral:) withObject:peipheralUUID afterDelay:5.0];
    //[self scanPeipheral:peipheralUUID];
}

#pragma mark - DFU
- (void)scanPeipheral:(NSString *)specifiedUUID
{
    DEBUGLog(@"start scan DFU peipheral");
    __weak WMSUpdateVCHelper *weakHelper = _updateHelper;
    [weakHelper scanPeripheralByInterval:20.0 completion:^(CBPeripheral *peripheral) {
        NSString *uuid = [peripheral.identifier UUIDString];
        DEBUGLog(@"uuid:%@",uuid);
        if ([specifiedUUID isEqualToString:uuid]) {
            [weakHelper stopScan];
            DEBUGLog(@"stop scan ");
            [self doDFUOperationsWithManager:weakHelper.centralManager peripheral:peripheral];
            return ;
        }
    }];
}

- (void)doDFUOperationsWithManager:(CBCentralManager *)manager
                        peripheral:(CBPeripheral *)peripheral
{
    _dfuOperations = nil;
    _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    [_dfuOperations setCentralManager:manager];
    [_dfuOperations connectDevice:peripheral];    
}


#pragma mark - DFUOperationsDelegate

#ifdef DEBUG
    #define NSLog(s,...)  NSLog(@"DFU--->%@[LINE:%d] %@", self,__LINE__,[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
    #define NSLog(s,...)
#endif

-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnected %@",peripheral.name);
    
    NSString *filePath = FileTmpPath(FILE_TMP_FIRMWARE_UPDATE);
    [_dfuOperations performDFUOnFile:filePath firmwareType:APPLICATION];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"device disconnected %@",peripheral.name);
}

-(void)onDFUStarted
{
    NSLog(@"onDFUStarted");
//    self.isTransferring = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
//        uploadButton.enabled = YES;
//        [uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
//        NSString *uploadStatusMessage = [self getUploadStatusMessage];
//        uploadStatus.text = uploadStatusMessage;
        self.progressView.hidden = NO;
    });
}

-(void)onDFUCancelled
{
    NSLog(@"onDFUCancelled");
//    self.isTransferring = NO;
//    self.isTransferCancelled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self enableOtherButtons];
        self.progressView.hidden = YES;
    });
}

-(void)onTransferPercentage:(int)percentage
{
    NSLog(@"onTransferPercentage %d",percentage);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = percentage/100.0;
    });
}

-(void)onSuccessfulFileTranferred
{
    NSLog(@"OnSuccessfulFileTransferred");
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

-(void)onError:(NSString *)errorMessage
{
    NSLog(@"OnError %@",errorMessage);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}


-(void)onSoftDeviceUploadStarted
{
    NSLog(@"onSoftDeviceUploadStarted");
}
-(void)onSoftDeviceUploadCompleted
{
    NSLog(@"onSoftDeviceUploadCompleted");
}
-(void)onBootloaderUploadStarted
{
    NSLog(@"onBootloaderUploadStarted");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        uploadStatus.text = @"uploading bootloader ...";
//    });
}
-(void)onBootloaderUploadCompleted
{
    NSLog(@"onBootloaderUploadCompleted");
}

@end
