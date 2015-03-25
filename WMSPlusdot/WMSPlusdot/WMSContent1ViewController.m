//
//  WMSContent1ViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-22.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSContent1ViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSAppDelegate.h"
#import "WMSSmartClockViewController.h"
#import "WMSSleepHistoryViewController.h"
#import "WMSClockListVC.h"

#import "WMSSyncDataView.h"
#import "MBProgressHUD.h"
#import "GGIAnnulusView.h"

#import "WMSSleepModel.h"
#import "WMSDeviceModel.h"
#import "WMSDeviceModel+Configure.h"
#import "WMSMyAccessory.h"
#import "WMSSleepDatabase.h"
#import "NSDate+Formatter.h"

#import "WMSHelper.h"
#import "WMSAdaptiveMacro.h"
#import "WMSConstants.h"

@interface WMSContent1ViewController ()<WMSSyncDataViewDelegate>
@property (strong, nonatomic) WMSSyncDataView *syncDataView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIView *tipView;

@property (strong, nonatomic) NSDate *showDate;

@property (assign, nonatomic) BOOL isVisible;//是否可见（当前显示的是否是该控制器）
@property (assign, nonatomic) BOOL isNeedUpdate;//是否需要更新界面

@property (strong, nonatomic) WMSBleControl *bleControl;
@end

@implementation WMSContent1ViewController

#pragma mark - Getter
- (WMSSyncDataView *)syncDataView
{
    if (!_syncDataView) {
        _syncDataView = [WMSSyncDataView defaultSyncDataView];
        _syncDataView.delegate = self;
    }
    return _syncDataView;
}
- (UIView *)tipView
{
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:TipViewFrame];
        _tipView.backgroundColor = [UIColor clearColor];
        
        UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(_tipView.bounds.size.width/2-100, (_tipView.bounds.size.height-30)/2, 150, 30)];
        labelTip.text = NSLocalizedString(@"正在连接您的手表", nil);
        labelTip.textAlignment = NSTextAlignmentRight;
        labelTip.textColor = [UIColor whiteColor];
        labelTip.font = Font_DINCondensed(17.0);
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(labelTip.frame.origin.x+labelTip.frame.size.width+15, (_tipView.bounds.size.height-37)/2, 37, 37)];
        [indicatorView startAnimating];
        
        [_tipView addSubview:labelTip];
        [_tipView addSubview:indicatorView];
    }
    return _tipView;
}
- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText = NSLocalizedString(@"努力同步数据中...", nil);
        _hud.minSize = MBProgressHUD_MinSize;
    }
    return _hud;
}

#pragma mark - Setter
- (void)setSleepDurations:(NSUInteger)sleepMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",sleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",sleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    if (sleepMinute/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(55.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(55.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //self.labelSleepHour.text = [NSString stringWithFormat:@"%u",hour];
    //self.labelSleepMinute.text = [NSString stringWithFormat:@"%u",minute];
    self.labelSleepHour.attributedText = text;
    self.labelSleepHour.adjustsFontSizeToFitWidth = YES;
}
- (void)setDeepSleepDurations:(NSUInteger)deepSleepMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",deepSleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",deepSleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    if (deepSleepMinute/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(30.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(30.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //self.labelDeepsleepHour.text = [NSString stringWithFormat:@"%u",hour];
    //self.labelDeepsleepMinute.text = [NSString stringWithFormat:@"%u",minute];
    self.labelDeepsleepHour.attributedText = text;
    self.labelDeepsleepHour.adjustsFontSizeToFitWidth = YES;
}
- (void)setLightSleepDurations:(NSUInteger)lightSleepMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",lightSleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",lightSleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    if (lightSleepMinute/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(30.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(30.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //self.labelLightSleepHour.text = [NSString stringWithFormat:@"%u",hour];
    //self.labelLightSleepMinute.text = [NSString stringWithFormat:@"%u",minute];
    self.labelLightSleepHour.attributedText = text;
    self.labelLightSleepHour.adjustsFontSizeToFitWidth = YES;
}
//- (void)setAwakeCount:(NSUInteger)awakeCount
//{
//    self.labelWakeupSleepHour.text = [NSString stringWithFormat:@"%u",awakeCount];
//}
- (void)setAwakeDurations:(NSUInteger)awakeMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",awakeMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",awakeMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    if (awakeMinute/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(30.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(30.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //self.labelWakeupSleepHour.text = [NSString stringWithFormat:@"%u",hour];
    //self.labelWakeupSleepMinute.text = [NSString stringWithFormat:@"%u",minute];
    self.labelWakeupSleepHour.attributedText = text;
    self.labelWakeupSleepHour.adjustsFontSizeToFitWidth = YES;
}

- (void)setSleepMinute:(NSUInteger)sleepMinute
       deepSleepMinute:(NSUInteger)deepSleepMinute
      lightSleepMinute:(NSUInteger)lightSleepMinute
           awakeMinute:(NSUInteger)awakeMinute
{
    NSArray *percents = nil;
    if (sleepMinute > 0) {
        float perDeepSleep = deepSleepMinute*1.0/sleepMinute;
        float perLightSleep = lightSleepMinute*1.0/sleepMinute;
        float perAwake = awakeMinute*1.0/sleepMinute;
        perDeepSleep = (perDeepSleep<=1.0 ? perDeepSleep : 1.0);
        perLightSleep = (perLightSleep<=1.0-perDeepSleep ? perLightSleep : 1.0-perDeepSleep);
        perAwake = (perAwake<=1.0-perDeepSleep-perLightSleep ? perAwake : 1.0-perDeepSleep-perLightSleep);
        perLightSleep = (perLightSleep>=0 ? perLightSleep : 0);
        perAwake      = (perAwake>=0 ? perAwake : 0);
        percents = @[@(perDeepSleep),@(perLightSleep),@(perAwake)];
    } else {
        percents = @[@(0),@(0),@(0)];
    }
    NSArray *colors = @[UIColorFromRGBAlpha(0x2BFFD5, 1.0),
                        UIColorFromRGBAlpha(0xF3EC83, 1.0),
                        UIColorFromRGBAlpha(0x76F5FF, 1.0)];
    [self.annulusView setAnnulusColors:colors andPercents:percents];
}

- (void)setLabelShowDate:(NSDate *)date
{
    self.showDate = date;
    self.labelDate.text = [WMSHelper describeWithDate:date andFormart:DateFormat];
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
    
    [self setupView];
    [self setupControl];
    [self localizableView];
    [self adaptiveIphone4];
    
    ////////////
    [self setLabelShowDate:[NSDate systemDate]];
    //[self updateView];
    
    [self bleOperation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSyncData:) name:WMSAppDelegateReSyncData object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.isVisible = YES;
    if (self.isNeedUpdate && self.bleControl.isConnected) {
        [self startSyncSleepData];
    }
    self.isNeedUpdate = NO;
    
    //更新状态
    if ([WMSMyAccessory isBindAccessory] == NO) {
        [self showTipView:2];
    } else {
        if ([self.bleControl isConnected]) {
            [self showTipView:NO];
            int batteryEnergy = [WMSDeviceModel deviceModel].batteryEnergy;
            [self.syncDataView setEnergy:batteryEnergy];
        } else {
            [self showTipView:YES];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.isVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%@ dealloc",[self class]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setup
- (void)setupView
{
    [self.view addSubview:self.syncDataView];
    [self.view addSubview:self.tipView];
    [self.view addSubview:self.hud];
}
- (void)setupControl
{
    [self.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonRight setTitle:@"" forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_a.png"] forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonNext setTitle:@"" forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_a.png"] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonClock setTitle:@"" forState:UIControlStateNormal];
    [self.buttonClock setBackgroundImage:[UIImage imageNamed:@"main_clock_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonClock setBackgroundImage:[UIImage imageNamed:@"main_clock_btn_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonHistory setTitle:@"" forState:UIControlStateNormal];
    [self.buttonHistory setBackgroundImage:[UIImage imageNamed:@"main_history_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonHistory setBackgroundImage:[UIImage imageNamed:@"main_history_btn_b.png"] forState:UIControlStateHighlighted];
}

//本地化
- (void)localizableView
{
    _labelTitle.text = NSLocalizedString(@"My sleep", nil);
    _labelMySleep.text = NSLocalizedString(@"睡眠时长",nil);
    _labelDeepsleep.text = NSLocalizedString(@"Deep sleep",nil);
    _labelLightsleep.text = NSLocalizedString(@"Light sleep",nil);
    _labelWakeup.text = NSLocalizedString(@"Wake up",nil);
    _labelMySleep.adjustsFontSizeToFitWidth = YES;
    _labelDeepsleep.adjustsFontSizeToFitWidth = YES;
    _labelLightsleep.adjustsFontSizeToFitWidth = YES;
    _labelWakeup.adjustsFontSizeToFitWidth = YES;
    _labelHour0.text = _labelHour1.text = _labelHour2.text = _labelHour3.text = NSLocalizedString(@"Hour",nil);
    _labelMinute0.text = _labelMinute1.text = _labelMinute2.text = _labelMinute3.text = NSLocalizedString(@"Minutes",nil);
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.dateView.frame;
    frame.origin.y -= DATE_VIEW_MOVE_HEIGHT;
    self.dateView.frame = frame;
    
    frame = self.syncDataView.frame;
    frame.origin.y -= TIP_VIEW_MOVE_HEIGHT;
    self.syncDataView.frame = frame;
    frame = self.tipView.frame;
    frame.origin.y -= TIP_VIEW_MOVE_HEIGHT;
    self.tipView.frame = frame;
    
    frame = self.annulusView.frame;
    frame.origin.y -= SPORT_SLEEP_VIEW_MOVE_HEIGHT;
    self.annulusView.frame = frame;
    
    
    frame = self.buttonClock.frame;
    frame.origin.y -= BOTTOM_BUTTON_MOVE_HEIGHT;
    self.buttonClock.frame = frame;
    frame = self.buttonHistory.frame;
    frame.origin.y -= BOTTOM_BUTTON_MOVE_HEIGHT;
    self.buttonHistory.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y -= BOTTOM_VIEW_MOVE_HEIGHT;
    self.bottomView.frame = frame;
    
    frame = self.labelDeepsleepHour.frame;
    frame.origin.y -= BOTTOM_LABEL_MOVE_HEIGHT;
    self.labelDeepsleepHour.frame = frame;
    frame = self.labelLightSleepHour.frame;
    frame.origin.y -= BOTTOM_LABEL_MOVE_HEIGHT;
    self.labelLightSleepHour.frame = frame;
    frame = self.labelWakeupSleepHour.frame;
    frame.origin.y -= BOTTOM_LABEL_MOVE_HEIGHT;
    self.labelWakeupSleepHour.frame = frame;
}

//更新界面上的数据
- (void)updateView
{
    WMSSleepModel *model = nil;
    
    if (self.bleControl && [self.bleControl isConnected]) {
        //从数据库中查询数据
        NSArray *results = [[WMSSleepDatabase sleepDatabase] querySleepData:self.showDate];
        if (results.count > 0) {
            model = results[0];
        }
    }
    
    if (model) {
        NSUInteger awakeDurations = 0;
        int rc = (unsigned int)(model.sleepMinute-model.deepSleepMinute-model.lightSleepMinute);
        awakeDurations = rc>=0 ? rc : 0;
        [self setSleepDurations:model.sleepMinute];
        [self setDeepSleepDurations:model.deepSleepMinute];
        [self setLightSleepDurations:model.lightSleepMinute];
        [self setAwakeDurations:awakeDurations];
        [self setSleepMinute:model.sleepMinute deepSleepMinute:model.deepSleepMinute lightSleepMinute:model.lightSleepMinute awakeMinute:awakeDurations];
    } else {
        [self setSleepDurations:0];
        [self setDeepSleepDurations:0];
        [self setLightSleepDurations:0];
        [self setAwakeDurations:0];
        [self setSleepMinute:0 deepSleepMinute:0 lightSleepMinute:0 awakeMinute:0];
    }
    /*
    [self setSleepDurations:8*60+5];
    [self setDeepSleepDurations:4*60+26];
    [self setLightSleepDurations:2*60+30];
    [self setAwakeDurations:(8*60+5)-(4*60+26)-(2*60+30)];
    [self setSleepMinute:8*60+5 deepSleepMinute:4*60+26 lightSleepMinute:2*60+30 awakeMinute:(8*60+5)-(4*60+26)-(2*60+30)];
    */
}

//是否显示TipView，0表示显示syncDataView，1表示显示tipView，2表示两者都不显示
- (void)showTipView:(int)show
{
    if (show == 0) {
        [self.syncDataView setHidden:NO];
        [self.tipView setHidden:YES];
    } else if(show == 1) {
        [self.syncDataView setHidden:YES];
        [self.tipView setHidden:NO];
    } else if(show == 2) {
        [self.syncDataView setHidden:YES];
        [self.tipView setHidden:YES];
    }
}

- (void)readDeviceInfo
{
    [WMSDeviceModel readDeviceInfo:self.bleControl completion:^(NSUInteger batteryEnergy, NSUInteger version) {}];
}

#pragma mark - Date
- (void)savaSleepData:(WMSSleepModel *)model
{
    NSArray *results = [[WMSSleepDatabase sleepDatabase] querySleepData:model.sleepDate];
    if (results && results.count>0) {//若数据库中已存在该日期的数据，则更新数据库
        [[WMSSleepDatabase sleepDatabase] updateSleepData:model];
    } else {
        [[WMSSleepDatabase sleepDatabase] insertSleepData:model];
    }
}


#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (IBAction)prevDateAction:(id)sender {
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
    [self setLabelShowDate:date];
    [self updateView];
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    [self setLabelShowDate:date];
    [self updateView];
}

- (IBAction)gotoMyClockViewAction:(id)sender {
    WMSSmartClockViewController *VC = [[WMSSmartClockViewController alloc] init];
    VC.title = NSLocalizedString(@"Smart alarm clock", nil);
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)gotoMyHistoryViewAction:(id)sender {
    WMSSleepHistoryViewController *vc = [[WMSSleepHistoryViewController alloc] initWithNibName:@"WMSSleepHistoryViewController" bundle:nil];
    vc.showDate = self.showDate;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)syncData
{
    if (![self.bleControl isConnected]) {
        return;
    }
    
    [self startSyncSleepData];
}

#pragma mark - 收发数据
- (void)startSyncSleepData
{
    [self.syncDataView startAnimating];
    [self.hud show:YES];
    
    [self.bleControl.deviceProfile syncDeviceSleepDataWithCompletion:^(NSString *sleepDate, NSUInteger sleepEndHour, NSUInteger sleepEndMinute, NSUInteger todaySleepMinute, NSUInteger todayAsleepMinute, NSUInteger awakeCount, NSUInteger deepSleepMinute, NSUInteger lightSleepMinute, UInt16 *startedMinutes, UInt8 *startedStatus, UInt8 *statusDurations, NSUInteger dataLength)
     {
         //         DEBUGLog(@"====>>>date:%@,sleepEndHour:%d,sleepEndMinute:%d,SleepDurations:%d,AsleepDurations:%d,awakeCount:%d",sleepDate,sleepEndHour,sleepEndMinute,todaySleepMinute,todayAsleepMinute,awakeCount);
         //         printf("\t\t [startedMinutes--startedStatus--statusDurations]\n");
         //         for (int i=0; i<dataLength; i++) {
         //             printf("\t\t [%d--%d--%d] ",startedMinutes[i],startedStatus[i],statusDurations[i]);
         //         }
         //         printf("\n");
         DEBUGLog(@"sleep date %@",sleepDate);
         
         if ([sleepDate isEqualToString:@"0000-00-00"]) {
             DEBUGLog(@"同步睡眠数据完成");
             [self syncSleepDataOver];
             return ;
         }
         
         //保存数据
         NSDate *date = [NSDate dateFromString:sleepDate format:@"yyyy-MM-dd"];
         WMSSleepModel *model = [[WMSSleepModel alloc] initWithSleepDate:date sleepEndHour:sleepEndHour sleepEndMinute:sleepEndMinute sleepMinute:todaySleepMinute asleepMinute:todayAsleepMinute awakeCount:awakeCount deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];
         [self savaSleepData:model];
         
         
         [self continueSyncSleepData];
     }];
}

- (void)continueSyncSleepData
{
    [self.bleControl.deviceProfile syncDeviceSleepDataWithCompletion:^(NSString *sleepDate, NSUInteger sleepEndHour, NSUInteger sleepEndMinute, NSUInteger todaySleepMinute, NSUInteger todayAsleepMinute, NSUInteger awakeCount, NSUInteger deepSleepMinute, NSUInteger lightSleepMinute, UInt16 *startedMinutes, UInt8 *startedStatus, UInt8 *statusDurations, NSUInteger dataLength)
     {
         //         DEBUGLog(@"====>>>date:%@,sleepEndHour:%d,sleepEndMinute:%d,SleepDurations:%d,AsleepDurations:%d,awakeCount:%d",sleepDate,sleepEndHour,sleepEndMinute,todaySleepMinute,todayAsleepMinute,awakeCount);
         //         printf("\t\t [startedMinutes--startedStatus--statusDurations]\n");
         //         for (int i=0; i<dataLength; i++) {
         //             printf("\t\t [%d--%d--%d] ",startedMinutes[i],startedStatus[i],statusDurations[i]);
         //         }
         //         printf("\n");
         DEBUGLog(@"sleep date %@",sleepDate);
         if ([sleepDate isEqualToString:@"0000-00-00"]) {
             DEBUGLog(@"同步睡眠数据完成");
             [self syncSleepDataOver];
             return ;
         }
         
         //保存数据
         NSDate *date = [NSDate dateFromString:sleepDate format:@"yyyy-MM-dd"];
         WMSSleepModel *model = [[WMSSleepModel alloc] initWithSleepDate:date sleepEndHour:sleepEndHour sleepEndMinute:sleepEndMinute sleepMinute:todaySleepMinute asleepMinute:todayAsleepMinute awakeCount:awakeCount deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];
         [self savaSleepData:model];
         
         [self continueSyncSleepData];
     }];
}

- (void)syncSleepDataOver
{
    [self.syncDataView stopAnimating];
    [self.hud hide:YES afterDelay:0];
    
    //更新界面
    [self setLabelShowDate:[NSDate systemDate]];
    [self updateView];
}


#pragma mark - 蓝牙操作
- (void)bleOperation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdatedBLEState:) name:WMSBleControlBluetoothStateUpdated object:nil];
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    
    if ([self.bleControl isConnected]) {
        DEBUGLog(@"同步睡眠数据");
        [self startSyncSleepData];
    }
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));
    
    //[self.syncDataView setCellElectricQuantity:[WMSDeviceModel deviceModel].batteryEnergy];
    
    [self showTipView:NO];
    
    //若该视图控制器不可见，则不同步数据，等到该界面显示时同步
    if (self.isVisible) {
        [self startSyncSleepData];
        self.isNeedUpdate = NO;
    } else {
        self.isNeedUpdate = YES;
    }
    
}
- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    [self showTipView:YES];
    [self.syncDataView stopAnimating];
    [self.hud hide:YES afterDelay:0];
}
- (void)handleUpdatedBLEState:(NSNotification *)notification
{
    DEBUGLog(@"%@ %s",self.class,__FUNCTION__);
    switch ([self.bleControl bleState]) {
        case WMSBleStateResetting:
        case WMSBleStatePoweredOff:
            [self handleDidDisConnectPeripheral:nil];
            break;
        default:
            break;
    }
}

#pragma mark -  Notification
- (void)appDidBecomeActive:(NSNotification *)notification
{
    switch (self.bleControl.bleState) {
        case WMSBleStatePoweredOff:
        {
            [self showTipView:YES];
            [self.hud hide:YES afterDelay:0];
            [self.syncDataView stopAnimating];
            break;
        }
        default:
            break;
    }
}
- (void)reSyncData:(NSNotification *)notification
{
    [self syncData];
}


#pragma mark - WMSSyncDataViewDelegate
- (void)syncDataView:(WMSSyncDataView *)syncView didClickSyncButton:(UIButton *)button
{
    [self syncData];
}


@end
