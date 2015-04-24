//
//  WMSBindingAccessoryViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-23.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSBindingAccessoryViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSAppDelegate.h"
#import "WMSMyAccountViewController.h"
#import "WMSContentViewController.h"
#import "WMSMyAccessoryViewController.h"

#import "WMSBindingView.h"
#import "WMSDeviceModel+Configure.h"
#import "WMSMyAccessory.h"
#import "WMSFilter.h"
#import "WMSConstants.h"

static const NSTimeInterval SCAN_TIME_INTERVAL      = 60.f;
static const NSTimeInterval BINDING_TIME_INTERVAL   = 60.f;
static const int            MAX_RSSI                = -75;

@interface WMSBindingAccessoryViewController ()<WMSBindingViewDelegate>
{
}
@property (strong, nonatomic) NSArray *listData;
@property (strong, nonatomic) WMSBleControl *bleControl;
@property (strong, nonatomic) WMSBindingView *bindView;
@end

@implementation WMSBindingAccessoryViewController
{
    int _countdown;
    NSTimer *_timer;
    NSTimer *_refreshTimer;
}

#pragma mark - Getter
- (WMSBindingView *)bindView
{
    if (!_bindView) {
        _bindView = [WMSBindingView instanceBindingView];
        _bindView.delegate = self;
    }
    return _bindView;
}

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self bleOperation];
    
    [self.bindView.textView setText:NSLocalizedString(@"请将手表靠近手机", nil)];
    [self.bindView show:YES forView:self.view];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Methods
- (void)continueBinding
{
    [self scanPeripheral];
    [self.bindView.textView setText:NSLocalizedString(@"请将手表靠近手机", nil)];
}
- (void)sendBindingCMD
{
    __weak __typeof(self) weakSelf = self;
    double version = [WMSDeviceModel deviceModel].version;
    BindSettingCMD bindCMD = bindSettingCMDBind;
    if (version >= FIRMWARE_TARGET_VERSION) {
        bindCMD = BindSettingCMDMandatoryBind;
    }
    [self.bleControl bindSettingCMD:bindCMD completion:^(BindingResult result)
     {
         __strong __typeof(weakSelf) strongSelf = weakSelf;
         if (!strongSelf) {
             return ;
         }
         
         if (result == BindingResultSuccess) {
             NSString *identify = strongSelf.bleControl.connectedPeripheral.UUIDString;
             if (identify) {
                 NSString *mac = [WMSDeviceModel deviceModel].mac;
                 if (!mac) {
                     mac = @"";
                 }else{}
                 [WMSMyAccessory bindAccessoryWith:identify generation:_generation];
                 [WMSMyAccessory setBindAccessoryMac:mac];
                 [strongSelf closeVC:YES];
             } else {}
         } else {
             [strongSelf closeVC:NO];
         }
     }];
}

- (void)closeVC:(BOOL)successOrFail
{
    [self setBleControl:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindingTimeout) object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    UIViewController *vc = self.navigationController.topViewController;
    if ([vc class] == [WMSMyAccessoryViewController class]) {
        WMSMyAccessoryViewController *topVC = (WMSMyAccessoryViewController *)vc;
        [topVC showBindingTip:successOrFail];
    }
}

#pragma mark - NSTimer
- (void)bindingTimeout
{
    [self.bleControl disconnect];
    
    self.bindView.textView.text = NSLocalizedString(@"超时，绑定失败", nil);
}

//刷新外设的信号量
- (void)startRefresh
{
    //开一个1s的定时器，去更新外设的信号量
    [self stopRefresh];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshPeripheralSignal:) userInfo:nil repeats:YES];
}
- (void)stopRefresh
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}
- (void)refreshPeripheralSignal:(NSTimer *)timer
{
    DEBUGLog(@"refresh signal");
    NSArray *array = [WMSFilter descendingOrderPeripheralsWithSignal:self.listData];
    [self setListData:array];

    if (!self.listData || self.listData.count==0) {
        return ;
    }
    LGPeripheral *peripheral = self.listData[0];
    if (!peripheral) {
        return ;
    }
    NSInteger RSSI = peripheral.RSSI;DEBUGLog(@"signal %d",RSSI);
    if (RSSI >= MAX_RSSI) {
        if ([self.bleControl isScanning]) {
            [self.bleControl stopScanForPeripherals];
        }
        [self.bleControl connect:peripheral];
        [self stopRefresh];
        DEBUGLog(@"[LINE:%d] stop refresh",__LINE__);
        self.bindView.textView.text = NSLocalizedString(@"请稍等，正在绑定配件...", nil);
    }
}

#pragma mark - 蓝牙操作
- (void)bleOperation
{
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    if ([self.bleControl isScanning]) {
        [self.bleControl stopScanForPeripherals];//先停止扫描
    }
    if ([self.bleControl isConnecting]) {
        [self.bleControl disconnect];
    }
    
    [self scanPeripheral];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedConnectPeripheral:) name:WMSBleControlPeripheralConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
}
- (void)scanPeripheral
{
    if (self.bleControl.isScanning || self.bleControl.isConnecting) {
        return ;
    }
    [self.bleControl scanForPeripheralsByInterval:SCAN_TIME_INTERVAL completion:^(NSArray *peripherals)
     {
         NSArray *array = [WMSFilter filterForPeripherals:peripherals withType:_generation];
         [self setListData:array];
     }];
    [self startRefresh];
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));

    [WMSDeviceModel setDeviceDate:self.bleControl completion:^{
        
        [WMSDeviceModel readDeviceInfo:self.bleControl completion:^(NSUInteger batteryEnergy, NSUInteger version) {
            DEBUGLog(@"read version:%d",version);
            
            if (version >= FIRMWARE_CAN_READ_MAC) {
                [WMSDeviceModel readDeviceMac:self.bleControl completion:^(NSString *mac) {
                    if (version < FIRMWARE_TARGET_VERSION) {
                        self.bindView.textView.text = NSLocalizedString(@"请在手表灯亮起时,\n按下右上角按键,完成设备的匹配", nil);
                    }
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindingTimeout) object:nil];
                    [self performSelector:@selector(bindingTimeout) withObject:nil afterDelay:BINDING_TIME_INTERVAL];
                    [self sendBindingCMD];
                }];
            } else {
                if (version < FIRMWARE_TARGET_VERSION) {
                    self.bindView.textView.text = NSLocalizedString(@"请在手表灯亮起时,\n按下右上角按键,完成设备的匹配", nil);
                }
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindingTimeout) object:nil];
                [self performSelector:@selector(bindingTimeout) withObject:nil afterDelay:BINDING_TIME_INTERVAL];
                [self sendBindingCMD];
            }
            
        }];
        
    }];
}
- (void)handleDisConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接断开 %@",NSStringFromClass([self class]));
    
    [self continueBinding];
}
- (void)handleFailedConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接失败 %@",NSStringFromClass([self class]));
    
    [self continueBinding];
}

- (void)handleScanPeripheralFinish:(NSNotification *)notification
{
    DEBUGLog(@"扫描结束 %@,connecting:%d,connected:%d",NSStringFromClass([self class]),[self.bleControl isConnecting], [self.bleControl isConnected]);
    
    [self stopRefresh];
    DEBUGLog(@"[LINE:%d] stop refresh",__LINE__);
}

#pragma mark - WMSBindingViewDelegate
- (void)bindingView:(WMSBindingView *)bindingView didClickBottomButton:(UIButton *)button
{
    [self stopRefresh];
    if ([self.bleControl isScanning]) {
        [self.bleControl stopScanForPeripherals];
    }
    if (self.bleControl.isConnecting || self.bleControl.isConnected) {
        [self.bleControl disconnect];
        DEBUGLog(@"disconnect....");
    }
    [self closeVC:NO];
}

@end
