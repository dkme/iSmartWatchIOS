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
#import "WMSMyAccessory.h"
#import "WMSContentViewController.h"

#define TableFrame ( CGRectMake(0, 80, ScreenWidth, ScreenHeight-80) )
#define buttonBottomFrame   ( CGRectMake((ScreenWidth-150)/2, ScreenHeight-35-20, 150, 35) )
#define ButtonScanTitle     NSLocalizedString(@"重新扫描", nil)
#define ButtonBindTitle     NSLocalizedString(@"绑定配件", nil)

#define TAG_BOTTOM_VIEW     100

@interface WMSBindingAccessoryViewController ()
{
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelTip;
}
@property (strong, nonatomic) UIButton *buttonBottom;
@property (strong, nonatomic) WMSBleControl *bleControl;
@end

@implementation WMSBindingAccessoryViewController

#pragma mark - Getter
- (UIButton *)buttonBottom
{
    if (!_buttonBottom) {
        _buttonBottom = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonBottom.frame = buttonBottomFrame;
        if (!iPhone5) {
            CGRect frame = buttonBottomFrame;
            frame.origin.y = frame.origin.y-10;
            _buttonBottom.frame = frame;
        }
        [_buttonBottom setBackgroundColor:[UIColor clearColor]];
        [_buttonBottom setBackgroundImage:[UIImage imageNamed:@"bind_btn_a.png"] forState:UIControlStateNormal];
        [_buttonBottom setBackgroundImage:[UIImage imageNamed:@"bind_btn_b.png"] forState:UIControlStateHighlighted];
        [_buttonBottom setTitle:ButtonScanTitle forState:UIControlStateNormal];
        [_buttonBottom addTarget:self action:@selector(buttonBottomAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonBottom;
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

    self.isSavaUserInfo = NO;
    
    [self.view addSubview:self.buttonBottom];
    
    [self updateUI];
    [self setupControl];
    [self localizableView];
    [self adaptiveIphone4];
    
    //
    [self bleOperation];
//    UINavigationController *nav = (UINavigationController *)((RESideMenu *)self.presentingViewController).contentViewController;
//    WMSContentViewController *contentVC = (WMSContentViewController *)nav.topViewController;
//    [contentVC scanAndConnectPeripheral];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

//    if ([WMSMyAccessory isBindAccessory]) {
//        [self.sideMenuViewController setPanGestureEnabled:YES];
//        [self dismissViewControllerAnimated:NO completion:nil];
//    } else {
//        [self.sideMenuViewController setPanGestureEnabled:NO];
//    }
    DEBUGLog(@"%@ viewDidAppear",NSStringFromClass([self class]));
    if (self.isSavaUserInfo) {
        [self.sideMenuViewController setPanGestureEnabled:YES];
        //[self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self.sideMenuViewController setPanGestureEnabled:NO];
    }
}

- (void)dealloc
{
    DEBUGLog(@"WMSBindingAccessoryViewController dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    self.labelBLEStatus.text = NSLocalizedString(@"Searching Plusdot watches",nil);
}

- (void)setupControl
{
    [self.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonRight setTitle:@"" forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_b.png"] forState:UIControlStateHighlighted];
}

//本地化
- (void)localizableView
{
    _labelTitle.text = NSLocalizedString(@"绑定配件",nil);
    _labelTip.text = NSLocalizedString(@"Please make sure the watch power is on and near the phone",nil);
    
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    UIView *bottomView = [self.view viewWithTag:TAG_BOTTOM_VIEW];
    CGRect frame = bottomView.frame;
    frame.origin.y -= 30;
    bottomView.frame = frame;
}

- (void)dismissVC
{
    DEBUGLog(@"dismiss Bind VC");
    
    UINavigationController *nav = (UINavigationController *)((RESideMenu *)self.presentingViewController).contentViewController;
    WMSContentViewController *contentVC = (WMSContentViewController *)nav.topViewController;
    contentVC.isShowBindVC = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Private
//更新Image
- (void)updateImage:(UIImage *)image
{
    self.imageViewBLEStatus.image = image;
}


#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (void)buttonBottomAction:(id)sender
{
//    if ([self.bleControl isConnected] == NO) {
//        return ;
//    }
    
    UIButton *button = (UIButton *)sender;
    NSString *buttonTitle = [button titleForState:UIControlStateNormal];
    if ([buttonTitle isEqualToString:ButtonScanTitle]) {
        //扫描
        UINavigationController *nav = (UINavigationController *)((RESideMenu *)self.presentingViewController).contentViewController;
        WMSContentViewController *contentVC = (WMSContentViewController *)nav.topViewController;
        [contentVC scanAndConnectPeripheral];
        
    } else {
        //绑定
        NSString *identifier = self.bleControl.connectedPeripheral.UUIDString;
        if (identifier == nil) {
            identifier = @"";
        }
        [WMSMyAccessory bindAccessory:identifier];
        
        WMSMyAccountViewController *VC = [[WMSMyAccountViewController alloc] init];
        VC.isModifyAccount = NO;
        
        [self presentViewController:VC animated:YES completion:nil];
    }
}


#pragma mark - 蓝牙操作
- (void)bleOperation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedConnectPeripheral:) name:WMSBleControlPeripheralConnectFailed object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
    
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功.");
    
    [self updateImage:[UIImage imageNamed:@"link_connect_success_icon.png"]];
    [self.buttonBottom setTitle:ButtonBindTitle forState:UIControlStateNormal];
    
//    NSDate *date = [NSDate date];
    
//    [self.bleControl.settingProfile setCurrentDate:date completion:^(BOOL success) {
//        DEBUGLog(@"设置系统时间%@",success?@"成功":@"失败");
//    }];
}
- (void)handleDisConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接断开 %@",NSStringFromClass([self class]));
    
    [self updateImage:[UIImage imageNamed:@"link_connect_failure_icon.png"]];
    [self.buttonBottom setTitle:ButtonScanTitle forState:UIControlStateNormal];
}
- (void)handleFailedConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接失败 %@",NSStringFromClass([self class]));
    
    [self updateImage:[UIImage imageNamed:@"link_connect_failure_icon.png"]];
    [self.buttonBottom setTitle:ButtonScanTitle forState:UIControlStateNormal];
}

//- (void)handleScanPeripheralFinish:(NSNotification *)notification
//{
//    DEBUGLog(@"扫描结束,connecting:%d,connected:%d",[self.bleControl isConnecting], [self.bleControl isConnected]);
//    if ([self.bleControl isConnecting] || [self.bleControl isConnected]) {
//        return ;
//    }
//    //[self scanAndConnectPeripheral];
//}

@end
