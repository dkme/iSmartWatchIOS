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

static const NSTimeInterval SCAN_TIME_INTERVAL      = 2.f;
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
- (void)bindingPeripheral
{
    NSArray *array = [WMSFilter descendingOrderPeripheralsWithSignal:self.listData];
    [self setListData:array];
    
    if (!self.listData || self.listData.count==0) {
        return ;
    }
    LGPeripheral *peripheral = self.listData[0];
    if (!peripheral) {
        return ;
    }
    NSInteger RSSI = peripheral.RSSI;
    if (RSSI >= MAX_RSSI) {
        if ([self.bleControl isScanning]) {
            [self.bleControl stopScanForPeripherals];
        }
        [self.bleControl connect:peripheral];
        [self stopRefresh];
        self.bindView.textView.text = NSLocalizedString(@"请稍等，正在绑定配件...", nil);
    }
}
- (void)continueBinding
{
    [self scanPeripheral];
    [self.bindView.textView setText:NSLocalizedString(@"请将手表靠近手机", nil)];
}
- (void)sendBindingCMD
{
    //    WeakObj(self, weakSelf);
    //    [self.bleControl bindDevice:^(BOOL isSuccess) {
    //        if (isSuccess) {
    //            StrongObj(weakSelf, strongSelf);
    //            if (strongSelf) {
    NSString *identify = self.bleControl.connectedPeripheral.UUIDString;
    if (identify) {
        NSString *mac = [WMSDeviceModel deviceModel].mac;
        if (!mac) {
            mac = @"";
        }
        [WMSMyAccessory bindAccessoryWith:identify generation:_generation];
        [WMSMyAccessory setBindAccessoryMac:mac];
        [self closeVC:YES];
    }
    //            }
    //        }
    //    }];
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
    WeakObj(self, weakSelf);
    [self.bleControl scanForPeripheralsByInterval:SCAN_TIME_INTERVAL completion:^(NSArray *peripherals)
     {
         StrongObj(weakSelf, strongSelf);
         NSArray *array = [WMSFilter filterForPeripherals:peripherals withType:strongSelf.generation];
         if (array && array.count>0) {
             [strongSelf setListData:array];
             [strongSelf bindingPeripheral];
         } else {
             [strongSelf continueBinding];
         }
     }];
    //    [self startRefresh];
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindingTimeout) object:nil];
    [self performSelector:@selector(bindingTimeout) withObject:nil afterDelay:BINDING_TIME_INTERVAL];
    [self sendBindingCMD];
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
//    DEBUGLog(@"扫描结束 %@,connecting:%d,connected:%d",NSStringFromClass([self class]),[self.bleControl isConnecting], [self.bleControl isConnected]);
//    
//    if (self.bleControl.isConnecting || self.bleControl.isConnected) {
//        [self stopRefresh];
//        DEBUGLog(@"[LINE:%d] stop refresh",__LINE__);
//    } else {
//        [self continueBinding];
//    }
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
