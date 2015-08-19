//
//  WMSUpdateVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSUpdateVC.h"
#import "WMSAppDelegate.h"
#import "UIViewController+Tip.h"

#import "WMSNavBarView.h"
#import "LDProgressView.h"

#import "WMSFileMacro.h"
#import "WMSUpdateVCHelper.h"

#import "DFUOperations.h"
#import "Utility.h"
#import "DFUHelper.h"
#import "WMSDeviceModel.h"

NSString * const WMSUpdateVCStartDFU =
                    @"com.guogee.ios.WMSUpdateVCStartDFU";
NSString *const WMSUpdateVCEndDFU =
                    @"com.guogee.ios.WMSUpdateVCEndDFU";
static const NSTimeInterval scanTimeInterval    = 120.f;
static const NSTimeInterval DFU_DELAY           = 2.f;

@interface WMSUpdateVC ()<DFUOperationsDelegate,UIAlertViewDelegate>
{
    WMSUpdateVCHelper *_updateHelper;
    DFUOperations *_dfuOperations;
    
    BOOL _isWillUpdate;//是否将要更新
    BOOL _isUpdating;//是否正在更新
    int  _connectSuccessCount;
    NSString *_peripheralIdentify;
}

@property (nonatomic, strong) DFUHelper *dfuHelper;

@end

@implementation WMSUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupNavBarView];
    [self setupTextView];
    [self setupUI];
    [self initProperty];
    [self adaptiveIphone4];
    
//    WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
//    [bleControl switchToUpdateMode:^(BOOL isSuccess, RequestUpdateFirmwareErrorCode errCode) {}];
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
    UIBarButtonItem *backItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backItem;
}
- (void)setupTextView
{
    NSString *txt = [NSString stringWithFormat:@"%@(v%.02f):\n%@",NSLocalizedString(@"更新说明",nil),self.updateVersion,self.updateDescribe];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.text = txt;
    self.textView.editable = NO;
    self.textView.userInteractionEnabled = NO;
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
    [self.buttonUpdate.layer setCornerRadius:10.0];
    [self.buttonUpdate setTitle:NSLocalizedString(@"立即更新", nil) forState:UIControlStateNormal];
    [self.buttonUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //LDProgressView
    self.progressView.borderRadius = @(0);
    self.progressView.type = LDProgressStripes;
    self.progressView.color = UICOLOR_DEFAULT;
    self.progressView.progress = 0.0;
    self.progressView.hidden = YES;
    
    //textViewState
    self.textViewState.backgroundColor = [UIColor whiteColor];
    self.textViewState.text = @"";
    self.textViewState.editable = NO;
    self.textViewState.userInteractionEnabled = NO;
    
}

- (void)initProperty
{
    _updateHelper = [WMSUpdateVCHelper instance];
    
    _updateSuccess = NO;
    _connectSuccessCount = 0;
    
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.textView.frame;
    frame.origin.y -= 20.0;
    self.textView.frame = frame;
    
    frame = self.progressView.frame;
    frame.origin.y -= (568.0-480.0-20);
    self.progressView.frame = frame;
    
    frame = self.textViewState.frame;
    frame.origin.y -= (568.0-480.0-20);
    self.textViewState.frame = frame;
    
}

#pragma mark - Update UI
- (void)updateState:(NSString *)state
{
    [self.textViewState setText:state];
}

#pragma mark - Post Notification
- (void)postNotificationForName:(NSString *)name
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:nil];
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    NSString *title = NSLocalizedString(@"提示", nil);
    NSString *message = @"";
    NSString *cancel = NSLocalizedString(@"NO", nil);
    NSString *confirm = NSLocalizedString(@"YES", nil);
    if (_isWillUpdate) {
        message = NSLocalizedString(@"正在准备更新固件，退出会取消更新，是否继续退出？", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
        [alert show];
        return ;
    }
    if (_isUpdating) {
        message = NSLocalizedString(@"正在更新固件，退出会停止更新，是否继续退出？", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
        [alert show];
        return ;
    }
    [_updateHelper stopScan];
    _updateHelper = nil;
    _dfuOperations = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAction:(id)sender {
    WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
    if ([bleControl isConnected] == NO) {
        [self showTip:NSLocalizedString(@"您的连接已断开", nil)];
        return;
    }
    
//    NSString *peipheralUUID = [bleControl.connectedPeripheral UUIDString];
//    _peripheralIdentify = peipheralUUID;
    
//    [self updateState:NSLocalizedString(@"正在切换至升级模式...", nil)];
//    [bleControl switchToUpdateModeCompletion:^(SwitchToUpdateResult result, NSString *failReason)
//    {
//        switch (result)
//        {
//            case SwitchToUpdateResultSuccess:
//            {
//                [self updateState:NSLocalizedString(@"切换模式成功...", nil)];
//                DEBUGLog(@"success");
//                break;
//            }
//            case SwitchToUpdateResultLowBattery:
//            {
//                [self showTip:NSLocalizedString(@"您的手表电量过低，不能升级", nil)];
//                DEBUGLog(@"low battery");
//                return ;
//            }
//            case SwitchToUpdateResultUnsupported:
//            {
//                [self showTip:NSLocalizedString(@"您的手表不支持升级", nil)];
//                DEBUGLog(@"Unsupported");
//                return ;
//            }
//            default:
//                return ;
//        }
//        self.navBarView.buttonLeft.enabled = NO;
//        self.buttonUpdate.enabled = NO;
//        self.buttonUpdate.alpha = 0.7;
//        _isUpdating = YES;
//        [self updateState:NSLocalizedString(@"正在准备升级...", nil)];
//        //发送通知
//        [self postNotificationForName:WMSUpdateVCStartDFU];
//        //4s后，会断开连接，此时再去扫描
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanPeipheral:) object:nil];
//        [self performSelector:@selector(scanPeipheral:) withObject:nil afterDelay:6.0];
//    }];
    
    [bleControl switchToUpdateMode:^(BOOL isSuccess, RequestUpdateFirmwareErrorCode errCode) {}];
    
    self.navBarView.buttonLeft.enabled = NO;
    self.buttonUpdate.enabled = NO;
    self.buttonUpdate.alpha = 0.7;
    _isWillUpdate = YES;
    [self updateState:NSLocalizedString(@"正在准备升级...", nil)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //发送通知
        [self postNotificationForName:WMSUpdateVCStartDFU];
        //6s后，会断开连接，此时再去扫描
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanPeipheral:) object:nil];
        [self performSelector:@selector(scanPeipheral:) withObject:nil afterDelay:6.0];
    });
}

#pragma mark - DFU
- (void)scanPeipheral:(NSString *)specifiedUUID
{
    DEBUGLog(@"start scan DFU peipheral");
    self.navBarView.buttonLeft.enabled = YES;
    __weak WMSUpdateVCHelper *weakHelper = _updateHelper;
    [weakHelper scanPeripheralByInterval:scanTimeInterval results:^(CBPeripheral *peripheral)
    {
        if (![WATCH_NAME_DFU isEqualToString:peripheral.name]) {
            return ;
        }
        DEBUGLog(@"scanning");
        NSString *uuid = [peripheral.identifier UUIDString];
//        if ([specifiedUUID isEqualToString:uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHUDAtViewCenter];
            });
            [weakHelper stopScan];
            DEBUGLog(@"stop scan");
            [self doDFUOperationsWithManager:weakHelper.centralManager peripheral:peripheral];
            return ;
//        }
    } timeout:^{
        DEBUGLog(@"scan timeout");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHUDAtViewCenter];
        });
    }];
}

- (void)doDFUOperationsWithManager:(CBCentralManager *)manager
                        peripheral:(CBPeripheral *)peripheral
{
    _dfuOperations = nil;
    _dfuHelper = nil;
    _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    _dfuHelper = [[DFUHelper alloc] initWithData:_dfuOperations];
    
    NSString *path = FileTmpPath(FILE_TMP_FIRMWARE_UPDATE);
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self onFileSelected:fileURL];///准备好升级文件
    [self onTypeSelected:FIRMWARE_TYPE_APPLICATION];///准备好文件的type
    
    [_dfuOperations setCentralManager:manager];
    [_dfuOperations connectDevice:peripheral];///连接设备，成功后立即开始升级
}

- (void)performDFU
{
//    NSString *path = FileTmpPath(FILE_TMP_FIRMWARE_UPDATE);
//    path = [[NSBundle mainBundle] pathForResource:@"nrf1" ofType:@"zip"];
//    NSLog(@"path: %@", path);
//    NSURL *fileURL = [NSURL fileURLWithPath:path];
//    if (fileURL) {
//        [_dfuOperations performDFUOnFile:fileURL firmwareType:APPLICATION];
//    } else {
//        DEBUGLog(@"升级文件错误");
//    }
    DEBUGLog(@"dfu");
    [self.dfuHelper checkAndPerformDFU];
}

-(void)onFileSelected:(NSURL *)url
{
    NSLog(@"onFileSelected");
    self.dfuHelper.selectedFileURL = url;
    if (self.dfuHelper.selectedFileURL) {
        NSLog(@"selectedFile URL %@",self.dfuHelper.selectedFileURL);
        NSString *selectedFileName = [[url path]lastPathComponent];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        self.dfuHelper.selectedFileSize = fileData.length;
        NSLog(@"fileSelected %@",selectedFileName);
        
        //get last three characters for file extension
        NSString *extension = [selectedFileName substringFromIndex: [selectedFileName length] - 3];
        NSLog(@"selected file extension is %@",extension);
        if ([extension isEqualToString:@"zip"]) {
            NSLog(@"this is zip file");
            self.dfuHelper.isSelectedFileZipped = YES;
            self.dfuHelper.isManifestExist = NO;
            [self.dfuHelper unzipFiles:self.dfuHelper.selectedFileURL];
        }
        else {
            self.dfuHelper.isSelectedFileZipped = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            fileName.text = selectedFileName;
//            fileSize.text = [NSString stringWithFormat:@"%lu bytes", (unsigned long)self.dfuHelper.selectedFileSize];
//            [self enableUploadButton];
        });
    }
    else {
        [Utility showAlert:@"Selected file not exist!"];
    }
}

- (void)onTypeSelected:(NSString *)selectedFileType
{
    [self.dfuHelper setFirmwareType:selectedFileType];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //DEBUGLog(@"index:%d",buttonIndex);
    if (buttonIndex == 0) {
        ;
    } else if (buttonIndex == 1) {
        [_dfuOperations cancelDFU];
        [_updateHelper stopScan];
        [self hideHUDAtViewCenter];
        _updateHelper = nil;
        _dfuOperations = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.navigationController popViewControllerAnimated:YES];
    } else {}
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
    self.dfuHelper.isDfuVersionExist = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUDAtViewCenter];
        [self updateState:NSLocalizedString(@"连接成功...", nil)];
        
        _connectSuccessCount ++;
        if (_connectSuccessCount >= 2) {
            [_dfuOperations cancelDFU];
            return ;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performDFU) object:nil];
        [self performSelector:@selector(performDFU) withObject:nil afterDelay:DFU_DELAY];
    });
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
    self.dfuHelper.isDfuVersionExist = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUDAtViewCenter];
        [self updateState:NSLocalizedString(@"连接成功...", nil)];
        
        _connectSuccessCount ++;
        if (_connectSuccessCount >= 2) {
            [_dfuOperations cancelDFU];
            return ;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performDFU) object:nil];
        [self performSelector:@selector(performDFU) withObject:nil afterDelay:DFU_DELAY];
    });
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"device disconnected %@",peripheral.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        _isUpdating = NO;
        self.progressView.hidden = YES;
        [self hideHUDAtViewCenter];
        
        if (!_updateSuccess && _connectSuccessCount <= 1) {
            [self scanPeipheral:_peripheralIdentify];
            [self updateState:NSLocalizedString(@"连接断开，升级中断...", nil)];
        } else {
            [self postNotificationForName:WMSUpdateVCEndDFU];
        }
    });
}

-(void)onReadDFUVersion:(int)version
{
    NSLog(@"onReadDFUVersion %d",version);
    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    if (self.dfuHelper.dfuVersion == 1) {
        [_dfuOperations setAppToBootloaderMode];
    }
}

-(void)onDFUStarted
{
    NSLog(@"onDFUStarted");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = NO;
        _isWillUpdate = NO;
        _isUpdating = YES;
        [self updateState:NSLocalizedString(@"正在进行升级...", nil)];
    });
}

-(void)onDFUCancelled
{
    NSLog(@"onDFUCancelled");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = YES;
        _isUpdating = NO;
        [self postNotificationForName:WMSUpdateVCEndDFU];
    });
}

-(void)onTransferPercentage:(int)percentage
{
    NSLog(@"onTransferPercentage %d",percentage);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = percentage/100.0+0.01;
    });
}

-(void)onSuccessfulFileTranferred
{
    NSLog(@"OnSuccessfulFileTransferred");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = YES;
        _isUpdating = NO;
        _updateSuccess = YES;
        [self updateState:NSLocalizedString(@"升级成功...", nil)];
        [self postNotificationForName:WMSUpdateVCEndDFU];
    });
}

-(void)onError:(NSString *)errorMessage
{
    NSLog(@"OnError %@",errorMessage);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = YES;
        _isUpdating = NO;
        [self updateState:NSLocalizedString(@"升级失败...", nil)];
        [self postNotificationForName:WMSUpdateVCEndDFU];
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
}
-(void)onBootloaderUploadCompleted
{
    NSLog(@"onBootloaderUploadCompleted");
}

@end
