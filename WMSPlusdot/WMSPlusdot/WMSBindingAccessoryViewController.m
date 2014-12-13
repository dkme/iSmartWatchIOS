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

#import "WMSMyAccessory.h"

#define SECTION_NUMBER  1
#define CELL_HIGHT      60
#define HEADER_HEIGHT   30
#define TableFrame ( CGRectMake(0, 80, ScreenWidth, ScreenHeight-80) )
#define buttonBottomFrame   ( CGRectMake((ScreenWidth-150)/2, ScreenHeight-35-20, 150, 35) )
#define ButtonScanTitle     NSLocalizedString(@"重新扫描", nil)
#define ButtonBindTitle     NSLocalizedString(@"绑定配件", nil)

#define TAG_BOTTOM_VIEW     100
#define BIND_TIME_INTERVAL  10

@interface WMSBindingAccessoryViewController ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelTip;
}
@property (strong, nonatomic) UIButton *buttonBottom;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *listData;
@property (strong, nonatomic) WMSBleControl *bleControl;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation WMSBindingAccessoryViewController
{
    int _countdown;
    NSTimer *_timer;
}

#pragma mark - Getter
- (UIButton *)buttonBottom
{
    if (!_buttonBottom) {
        UIView *centerView = self.labelBLEStatus.superview;
        CGRect viewFrame = centerView.frame;
        
        _buttonBottom = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonBottom.frame = buttonBottomFrame;
        CGRect buttonFrame = CGRectZero;
        CGSize buttonSize = CGSizeMake(150, 40);
        buttonFrame.origin = CGPointMake((viewFrame.size.width-buttonSize.width)/2.0, viewFrame.size.height - 60);
        buttonFrame.size = buttonSize;
        _buttonBottom.frame = buttonFrame;
        
//        if (!iPhone5) {
//            CGRect frame = buttonBottomFrame;
//            frame.origin.y = frame.origin.y-10;
//            _buttonBottom.frame = frame;
//        }
        [_buttonBottom setBackgroundColor:[UIColor lightGrayColor]];
        [_buttonBottom setBackgroundImage:[UIImage imageNamed:@"bind_btn_a.png"] forState:UIControlStateNormal];
        [_buttonBottom setBackgroundImage:[UIImage imageNamed:@"bind_btn_b.png"] forState:UIControlStateHighlighted];
        [_buttonBottom setTitle:ButtonScanTitle forState:UIControlStateNormal];
        [_buttonBottom addTarget:self action:@selector(buttonBottomAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonBottom;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight-64);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
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
    
    UIView *centerView = self.labelBLEStatus.superview;
    [centerView addSubview:self.buttonBottom];
    [self.view addSubview:self.tableView];
    [self.tableView setHidden:YES];
    
    [self updateUI];
    [self setupControl];
    [self localizableView];
    [self adaptiveIphone4];

    //
    [self bleOperation];
    
    [self showScanning:YES];
    [self scanBle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
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
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonRight setTitle:@"" forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_b.png"] forState:UIControlStateHighlighted];
}

//本地化
- (void)localizableView
{
    _labelTitle.text = NSLocalizedString(@"智能手表搜索",nil);
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

- (void)showScanning:(BOOL)yesOrNo
{
    if (yesOrNo) {
        self.labelBLEStatus.text = NSLocalizedString(@"正在搜索蓝牙设备......", nil);
        self.labelBLEStatus.numberOfLines = 1;
        [self.labelBLEStatus sizeToFit];
        CGRect frame = CGRectZero;
        CGPoint center = CGPointMake(self.view.center.x, self.labelBLEStatus.center.y);
        self.labelBLEStatus.center = center;
        frame = self.labelBLEStatus.frame;
        
        CGRect activityViewFrame = self.activityView.frame;
        activityViewFrame.origin.x = frame.origin.x - 20;
        activityViewFrame.origin.y = frame.origin.y+((frame.size.height-activityViewFrame.size.height)/2.0);
        self.activityView.frame = activityViewFrame;
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
        
        frame.origin.x += 10;
        self.labelBLEStatus.frame = frame;
        activityViewFrame = self.activityView.frame;
        activityViewFrame.origin.x += 10;
        self.activityView.frame = activityViewFrame;
        
        ///
        _labelTip.text = NSLocalizedString(@"请确认智能手表已经开启并在手机附近", nil);
        _labelTip.textAlignment = NSTextAlignmentCenter;
        _labelTip.numberOfLines = 2;
        [_labelTip sizeToFit];
        frame = _labelTip.frame;
        center = CGPointMake(self.view.center.x, _labelTip.center.y);
        _labelTip.center = center;
        
        self.buttonBottom.hidden = YES;
    } else {
        self.activityView.hidden = YES;
        self.buttonBottom.hidden = NO;
        
        self.labelBLEStatus.text = NSLocalizedString(@"没有找到蓝牙设备", nil);
        self.labelBLEStatus.numberOfLines = 1;
        [self.labelBLEStatus sizeToFit];
        CGRect frame = self.labelBLEStatus.frame;
        CGPoint center = CGPointMake(self.view.center.x, self.labelBLEStatus.center.y);
        self.labelBLEStatus.center = center;
        
        _labelTip.text = NSLocalizedString(@"请确认手机蓝牙已开启\n请确认智能手表在附近", nil);
        _labelTip.numberOfLines = 2;
        [_labelTip sizeToFit];
        frame = _labelTip.frame;
        center = CGPointMake(self.view.center.x, _labelTip.center.y);
        _labelTip.center = center;
    }
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

- (void)updateHUDSchedule:(NSTimeInterval)timeInterval
{
    NSString *format = NSLocalizedString(@"(剩余%.0f秒)",nil);
    NSString *str = [NSString stringWithFormat:format,timeInterval];
    self.hud.labelText = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"正在绑定配件，请按手表上的确认键...",nil),@""];
    self.hud.detailsLabelText = str;
}

- (void)closeVC:(BOOL)successOrFail
{
    [self.hud hide:YES];
    [self setHud:nil];
    [self setBleControl:nil];
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:self];
    [self.navigationController popViewControllerAnimated:YES];
    UIViewController *vc = self.navigationController.topViewController;
    if ([vc class] == [WMSMyAccessoryViewController class]) {
        WMSMyAccessoryViewController *topVC = (WMSMyAccessoryViewController *)vc;
        [topVC showBindingTip:successOrFail];
    }
    
}

#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.bleControl stopScanForPeripherals];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showRightViewAction:(id)sender {
    //[self.sideMenuViewController presentRightMenuViewController];
}

- (void)buttonBottomAction:(id)sender
{
    [self showScanning:YES];
    [self scanBle];
}

#pragma mark - NSTimer
- (void)fireTimer
{
    _countdown = BIND_TIME_INTERVAL;
//    NSString *format = NSLocalizedString(@"(剩余%d秒)",nil);
//    NSString *str = [NSString stringWithFormat:format,_countdown];
//    self.hud.labelText = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"正在绑定配件，请按手表上的确认键...",nil),str];
    [self updateHUDSchedule:_countdown];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
}
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)countdown:(NSTimer *)timer
{
    _countdown -= 1;
    if (_countdown == 0) {
        [self.bleControl disconnect];
        [self invalidateTimer];
        [self closeVC:NO];
        return;
    }
//    NSString *format = NSLocalizedString(@"(剩余%d秒)",nil);
//    NSString *str = [NSString stringWithFormat:format,_countdown];
//    self.hud.labelText = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"正在绑定配件，请按手表上的确认键...",nil),@""];
//    self.hud.detailsLabelText = str;
//    self.hud.detailsLabelFont = self.hud.labelFont;
    [self updateHUDSchedule:_countdown];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedConnectPeripheral:) name:WMSBleControlPeripheralConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
}
- (void)scanBle
{
    [self.bleControl scanForPeripheralsByInterval:SCAN_PERIPHERAL_INTERVAL completion:^(NSArray *peripherals)
     {
         self.listData = peripherals;
     }];
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));
//    [self updateImage:[UIImage imageNamed:@"link_connect_success_icon.png"]];
//    [self.buttonBottom setTitle:ButtonBindTitle forState:UIControlStateNormal];

    [self fireTimer];
    __weak __typeof(&*self) weakSelf = self;
    [self.bleControl bindSettingCMD:bindSettingCMDBind completion:^(BOOL success)
    {
        __strong __typeof(&*self) strongSelf = weakSelf;
        DEBUGLog(@"weakSelf:%@",weakSelf);
        if (!strongSelf) {
            return ;
        }
        
        [strongSelf invalidateTimer];
        if (success) {
            NSString *identify = strongSelf.bleControl.connectedPeripheral.UUIDString;
            if (identify) {
                [WMSMyAccessory bindAccessory:identify];
                [strongSelf closeVC:YES];
            } else {
                [strongSelf closeVC:NO];
            }
        } else {
            [strongSelf closeVC:NO];
        }
    }];
    
    //测试
//    NSString *identify = self.bleControl.connectedPeripheral.UUIDString;
//    [WMSMyAccessory bindAccessory:identify];
//    [self closeVC:YES];
}
- (void)handleDisConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接断开 %@",NSStringFromClass([self class]));
//    [self updateImage:[UIImage imageNamed:@"link_connect_failure_icon.png"]];
//    [self.buttonBottom setTitle:ButtonScanTitle forState:UIControlStateNormal];
    [self invalidateTimer];
    [self closeVC:NO];
}
- (void)handleFailedConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接失败 %@",NSStringFromClass([self class]));
//    [self updateImage:[UIImage imageNamed:@"link_connect_failure_icon.png"]];
//    [self.buttonBottom setTitle:ButtonScanTitle forState:UIControlStateNormal];
    [self invalidateTimer];
    [self closeVC:NO];
}

- (void)handleScanPeripheralFinish:(NSNotification *)notification
{
    DEBUGLog(@"扫描结束 %@,connecting:%d,connected:%d",NSStringFromClass([self class]),[self.bleControl isConnecting], [self.bleControl isConnected]);
    
//    if ([self.bleControl isConnecting] || [self.bleControl isConnected]) {
//        return ;
//    }
    
    if (self.listData && [self.listData count]>0) {
        NSMutableArray *array = [NSMutableArray array];
        for (LGPeripheral *pObject in self.listData) {
            NSString *name = pObject.cbPeripheral.name;
            if ([name isEqualToString:WATCH_NAME]) {
                [array addObject:pObject];
            }
        }
        self.listData = array;
    }
    if (self.listData && [self.listData count] > 0) {
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    } else {
        [self showScanning:NO];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    LGPeripheral *peripheral = self.listData[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@                           %@",peripheral.cbPeripheral.name,NSLocalizedString(@"点击绑定", nil)];
    cell.textLabel.font = Font_System(20.0);//Font_DINCondensed(20.0);
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",peripheral.UUIDString];
    cell.detailTextLabel.font = Font_System(12.0);//Font_DINCondensed(12.0);
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    CGRect frame = cell.textLabel.frame;
    frame.size.height += 10;
    cell.textLabel.frame = frame;
    
    //cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aa"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LGPeripheral *peripheral = self.listData[indexPath.row];
    [self.bleControl connect:peripheral];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = NSLocalizedString(@"正在连接手表...", nil);
    [self.view addSubview:_hud];
    [_hud show:YES];
}

@end
