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
#import "WMSMySleepView.h"
#import "WMSSmartClockViewController.h"
#import "NSDate+Formatter.h"
#import "WMSAppDelegate.h"
#import "WMSSyncDataView.h"
#import "WMSSleepModel.h"
#import "WMSSleepDatabase.h"
#import "MBProgressHUD.h"
#import "WMSSleepHistoryViewController.h"
#import "WMSDeviceModel.h"

#define OneDayTimeInterval    (24*60*60)
#define DateFormat           @"yyyy/MM/dd"

#define TipViewFrame          ( (CGRect){0,125,ScreenWidth,35} )

@interface WMSContent1ViewController ()
{
    //需本地化的UIView
    __weak IBOutlet UILabel *_labelMySleep;
    __weak IBOutlet UILabel *_labelDeepsleep;
    __weak IBOutlet UILabel *_labelLightsleep;
    __weak IBOutlet UILabel *_labelWakeup;
    
    
    __weak IBOutlet UILabel *_labelHour0;
    __weak IBOutlet UILabel *_labelMinute0;
    __weak IBOutlet UILabel *_labelHour1;
    __weak IBOutlet UILabel *_labelMinute1;
    __weak IBOutlet UILabel *_labelHour2;
    __weak IBOutlet UILabel *_labelMinute2;
    __weak IBOutlet UILabel *_labelHour3;
    __weak IBOutlet UILabel *_labelMinute3;
}

@property (weak, nonatomic) IBOutlet UILabel *labelSleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelSleepMinute;
@property (weak, nonatomic) IBOutlet UILabel *labelDeepsleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelDeepsleepMinute;
@property (weak, nonatomic) IBOutlet UILabel *labelLightSleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelLightSleepMinute;
@property (weak, nonatomic) IBOutlet UILabel *labelWakeupSleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelWakeupSleepMinute;

@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet WMSMySleepView *mySleepView;
@property (strong, nonatomic) WMSSyncDataView *syncDataView;
@property (strong, nonatomic) UIView *tipView;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSDate *showDate;

@property (strong, nonatomic) WMSBleControl *bleControl;

@property (strong, nonatomic) NSMutableArray *everydaySleepDataArray;
@end

@implementation WMSContent1ViewController

#pragma mark - Getter
- (WMSSyncDataView *)syncDataView
{
    if (!_syncDataView) {
        _syncDataView = [[WMSSyncDataView alloc] initWithFrame:(CGRect){0,125,ScreenWidth,35}];
        _syncDataView.backgroundColor = [UIColor clearColor];
        
        _syncDataView.labelTip.text = NSLocalizedString(@"智能手表已连接",nil);
        _syncDataView.labelTip.font = [UIFont fontWithName:@"DIN Condensed" size:17.0];
        
        UIImage *image = [UIImage imageNamed:@"zq_sync_btn.png"];
        CGRect frame = _syncDataView.imageView.frame;
        frame.size = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
        _syncDataView.imageView.image = image;
        _syncDataView.imageView.frame = frame;
        
        [_syncDataView.buttonSync setTitle:NSLocalizedString(@"同步",nil) forState:UIControlStateNormal];
        [_syncDataView.buttonSync.titleLabel setFont:[UIFont fontWithName:@"DIN Condensed" size:16.0]];
        [_syncDataView.buttonSync addTarget:self action:@selector(syncDataAction:) forControlEvents:UIControlEventTouchUpInside];
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

- (NSMutableArray *)everydaySleepDataArray
{
    if (!_everydaySleepDataArray) {
        _everydaySleepDataArray = [NSMutableArray new];
    }
    return _everydaySleepDataArray;
}

#pragma mark - Setter
- (void)setSleepDurations:(NSUInteger)sleepMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",sleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",sleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(45.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(45.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //self.labelSleepHour.text = [NSString stringWithFormat:@"%u",hour];
    //self.labelSleepMinute.text = [NSString stringWithFormat:@"%u",minute];
    self.labelSleepHour.attributedText = text;
}
- (void)setDeepSleepDurations:(NSUInteger)deepSleepMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",deepSleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",deepSleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
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
}
- (void)setLightSleepDurations:(NSUInteger)lightSleepMinute
{
    NSString *hour = [NSString stringWithFormat:@"%u",lightSleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",lightSleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
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
    
//    self.title = @"plusdot";
//    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"main_menu_icon_a.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showLeftViewAction:)];
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
//    self.navigationItem.leftBarButtonItem = leftBtn;
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"main_setting_icon_a.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showRightViewAction:)];
    
    [self.view addSubview:self.syncDataView];
    [self.view addSubview:self.tipView];
    [self.view addSubview:self.hud];
    
    [self setupControl];
    
    [self localizableView];
    
    [self adaptiveIphone4];
    
    [self reloadView];
    
    
    [self.mySleepView setSleepMinute:0 deepSleepMinute:0 lightSleepMinute:0];
    [self setSleepDurations:0];
    [self setDeepSleepDurations:0];
    [self setLightSleepDurations:0];
    //[self setAwakeCount:0];
    [self setAwakeDurations:0];
    
    //
    [self bleOperation];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([self.bleControl isConnected]) {
        [self showTipView:NO];
    } else {
        [self showTipView:YES];
    }
    
    [self.syncDataView setCellElectricQuantity:[WMSDeviceModel deviceModel].batteryEnergy];
}

- (void)dealloc
{
    DEBUGLog(@"Content1ViewController dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    _labelMySleep.text = NSLocalizedString(@"My sleep",nil);
    _labelDeepsleep.text = NSLocalizedString(@"Deep sleep",nil);
    _labelLightsleep.text = NSLocalizedString(@"Light sleep",nil);
    _labelWakeup.text = NSLocalizedString(@"Wake up",nil);
    
    _labelHour0.text = _labelHour1.text = _labelHour2.text = _labelHour3.text = NSLocalizedString(@"Hour",nil);
    _labelMinute0.text = _labelMinute1.text = _labelMinute2.text = _labelMinute3.text = NSLocalizedString(@"Minutes",nil);
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.dateView.frame;
    frame.origin.y -= 20;
    self.dateView.frame = frame;
    
    frame = self.syncDataView.frame;
    frame.origin.y -= 30;
    self.syncDataView.frame = frame;
    frame = self.tipView.frame;
    frame.origin.y -= 30;
    self.tipView.frame = frame;
    
    frame = self.mySleepView.frame;
    frame.origin.y -= 40;
    self.mySleepView.frame = frame;
    
    frame = self.buttonClock.frame;
    frame.origin.y -= 50;
    self.buttonClock.frame = frame;
    
    frame = self.buttonHistory.frame;
    frame.origin.y -= 50;
    self.buttonHistory.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y -= 60;
    self.bottomView.frame = frame;
}

- (void)reloadView
{
    self.showDate = [NSDate date];
    self.labelDate.text = [self stringWithDate:[NSDate date] andFormart:DateFormat];
}

- (NSString *)stringWithDate:(NSDate *)date andFormart:(NSString *)formart
{
    switch ([NSDate compareDate:date]) {
        case NSDateModeToday:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeYesterday:
            return NSLocalizedString(@"Yesterday",nil);
        case NSDateModeTomorrow:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeUnknown:
            return [NSDate formatDate:date withFormat:formart];
        default:
            return nil;
    }
    return nil;
}

//是否显示TipView
- (void)showTipView:(BOOL)show
{
    if (show) {
        [self.syncDataView setHidden:YES];
        [self.tipView setHidden:NO];
    } else {
        [self.syncDataView setHidden:NO];
        [self.tipView setHidden:YES];
    }
}

//更新界面上的数据
- (void)updateView
{
    WMSSleepModel *sleepModel = nil;
//    for (WMSSleepModel *model in self.everydaySleepDataArray) {
//        NSInteger interval_days = [NSDate daysOfDuringDate:self.showDate andDate:model.sleepDate];
//        if (interval_days == 0)
//        {
//            DEBUGLog(@"两个日期是同一天");
//            sleepModel = model;
//            break;
//        }
//    }
    
    //从数据库中查询数据
    NSArray *results = [[WMSSleepDatabase sleepDatabase] querySleepData:self.showDate];
    if (results.count > 0) {
        sleepModel = results[0];
    }
    
    if (sleepModel) {
        [self.mySleepView setSleepMinute:sleepModel.sleepMinute deepSleepMinute:sleepModel.deepSleepMinute lightSleepMinute:sleepModel.lightSleepMinute];
        [self setSleepDurations:sleepModel.sleepMinute];
        [self setDeepSleepDurations:sleepModel.deepSleepMinute];
        [self setLightSleepDurations:sleepModel.lightSleepMinute];
        //[self setAwakeCount:sleepModel.awakeCount];
        [self setAwakeDurations:sleepModel.sleepMinute-sleepModel.deepSleepMinute-sleepModel.lightSleepMinute];
    } else {
        [self.mySleepView setSleepMinute:0 deepSleepMinute:0 lightSleepMinute:0];
        [self setSleepDurations:0];
        [self setDeepSleepDurations:0];
        [self setLightSleepDurations:0];
        //[self setAwakeCount:0];
        [self setAwakeDurations:0];
    }
}

#pragma mark - Date
- (void)savaSleepDataWithDate:(NSDate *)date
                 sleepEndHour:(NSUInteger)endHour
               sleepEndMinute:(NSUInteger)endMinute
             sleepMinute:(NSUInteger)sleepMinute
                 asleepMinute:(NSUInteger)asleepMinute
                   awakeCount:(NSUInteger)count
              deepSleepMinute:(NSUInteger)deepSleepMinute
             lightSleepMinute:(NSUInteger)lightSleepMinute
               startedMinutes:(UInt16 *)startedMinutes
                startedStatus:(UInt8 *)startedStatus
              statusDurations:(UInt8 *)statusDurations
                   dataLength:(NSUInteger)dataLength;
{
    WMSSleepModel *model = [[WMSSleepModel alloc] initWithSleepDate:date sleepEndHour:endHour sleepEndMinute:endMinute sleepMinute:sleepMinute asleepMinute:asleepMinute awakeCount:count deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];

    NSArray *results = [[WMSSleepDatabase sleepDatabase] querySleepData:date];
    DEBUGLog(@"query results:");
    for (WMSSleepModel *obj in results) {
        DEBUGLog(@"\t\t\t %@",[obj.sleepDate.description substringToIndex:10]);
    }
    
    if (results && results.count>0) {//若数据库中已存在该日期的数据，则更新数据库
        [[WMSSleepDatabase sleepDatabase] updateSleepData:model];
    } else {
        [[WMSSleepDatabase sleepDatabase] insertSleepData:model];
    }
    
    
    [self.everydaySleepDataArray addObject:model];
}


#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (IBAction)prevDateAction:(id)sender {
    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    
    [self updateView];
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    
    [self updateView];
}

- (IBAction)gotoMyClockViewAction:(id)sender {
    WMSSmartClockViewController *VC = [[WMSSmartClockViewController alloc] init];
    [self.navigationController pushViewController:VC animated:NO];
}

- (IBAction)gotoMyHistoryViewAction:(id)sender {
    WMSSleepHistoryViewController *vc = [[WMSSleepHistoryViewController alloc] initWithNibName:@"WMSSleepHistoryViewController" bundle:nil];
    vc.showDate = self.showDate;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)syncDataAction:(id)sender
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
         DEBUGLog(@"====>>>date:%@,sleepEndHour:%d,sleepEndMinute:%d,SleepDurations:%d,AsleepDurations:%d,awakeCount:%d",sleepDate,sleepEndHour,sleepEndMinute,todaySleepMinute,todayAsleepMinute,awakeCount);
         printf("\t\t [startedMinutes--startedStatus--statusDurations]\n");
         for (int i=0; i<dataLength; i++) {
             printf("\t\t [%d--%d--%d] ",startedMinutes[i],startedStatus[i],statusDurations[i]);
         }
         printf("\n");
         
         if ([sleepDate isEqualToString:@"0000-00-00"]) {
             DEBUGLog(@"同步睡眠数据完成");
             [self syncSleepDataOver];
             return ;
         }
         
         //保存数据
         [self savaSleepDataWithDate:[NSDate dateFromString:sleepDate format:@"yyyy-MM-dd"] sleepEndHour:sleepEndHour sleepEndMinute:sleepEndMinute sleepMinute:todaySleepMinute asleepMinute:todayAsleepMinute awakeCount:awakeCount deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];
         
         [self continueSyncSleepData];
     }];
}

- (void)continueSyncSleepData
{
    [self.bleControl.deviceProfile syncDeviceSleepDataWithCompletion:^(NSString *sleepDate, NSUInteger sleepEndHour, NSUInteger sleepEndMinute, NSUInteger todaySleepMinute, NSUInteger todayAsleepMinute, NSUInteger awakeCount, NSUInteger deepSleepMinute, NSUInteger lightSleepMinute, UInt16 *startedMinutes, UInt8 *startedStatus, UInt8 *statusDurations, NSUInteger dataLength)
     {
         DEBUGLog(@"====>>>date:%@,sleepEndHour:%d,sleepEndMinute:%d,SleepDurations:%d,AsleepDurations:%d,awakeCount:%d",sleepDate,sleepEndHour,sleepEndMinute,todaySleepMinute,todayAsleepMinute,awakeCount);
         printf("\t\t [startedMinutes--startedStatus--statusDurations]\n");
         for (int i=0; i<dataLength; i++) {
             printf("\t\t [%d--%d--%d] ",startedMinutes[i],startedStatus[i],statusDurations[i]);
         }
         printf("\n");
         
         if ([sleepDate isEqualToString:@"0000-00-00"]) {
             DEBUGLog(@"同步睡眠数据完成");
             [self syncSleepDataOver];
             return ;
         }
         
         //保存数据
         [self savaSleepDataWithDate:[NSDate dateFromString:sleepDate format:@"yyyy-MM-dd"] sleepEndHour:sleepEndHour sleepEndMinute:sleepEndMinute sleepMinute:todaySleepMinute asleepMinute:todayAsleepMinute awakeCount:awakeCount deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];
         
         [self continueSyncSleepData];
     }];
}

- (void)syncSleepDataOver
{
    [self.syncDataView stopAnimating];
    [self.hud hide:YES afterDelay:0];
    
    //更新界面
    [self updateView];
}


#pragma mark - 蓝牙操作
- (void)bleOperation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    
 ///////测试
//    NSArray *results = [[WMSSleepDatabase sleepDatabase] queryAllSleepData];
//    DEBUGLog(@"所有睡眠数据：");
//    for (WMSSleepModel *modelObj in results) {
//        DEBUGLog(@"sleep Date:%@",[modelObj.sleepDate.description substringToIndex:10]);
//    }
    
    if ([self.bleControl isConnected]) {
        DEBUGLog(@"同步睡眠数据");
        [self startSyncSleepData];
    }
    
//    NSArray *array = [[WMSSleepDatabase sleepDatabase] getSleepModel];
//    for (WMSSleepModel *model in array) {
//        DEBUGLog(@"$$$$$ sleep Date:%@, endHour:%d,endMinute:%d,Durations:%d",
//                 model.sleepDate,
//                 model.sleepEndHour,
//                 model.sleepEndMinute,
//                 model.sleepMinute);
//        //model.perHourData
//        printf("startedMinutes:[");
//        for (int i=0; i<model.dataLength; i++) {
//            printf("%d ",model.startedMinutes[i]);
//        }
//        printf("]\n");
//        
//        printf("startedStatus:[");
//        for (int i=0; i<model.dataLength; i++) {
//            printf("%d ",model.startedStatus[i]);
//        }
//        printf("]\n");
//        
//        printf("statusDurations:[");
//        for (int i=0; i<model.dataLength; i++) {
//            printf("%d ",model.statusDurations[i]);
//        }
//        printf("]\n");
//    }

}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));
    
    //[self.syncDataView setCellElectricQuantity:[WMSDeviceModel deviceModel].batteryEnergy];
    
    [self showTipView:NO];
    
    [self startSyncSleepData];
}
- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    [self showTipView:YES];
    [self.syncDataView stopAnimating];
    [self.hud hide:YES afterDelay:0];
}

#pragma mark -  Notification
- (void)appWillEnterForeground:(NSNotification *)notification
{
    switch (self.bleControl.bleState) {
        case BleStatePoweredOff:
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

@end
