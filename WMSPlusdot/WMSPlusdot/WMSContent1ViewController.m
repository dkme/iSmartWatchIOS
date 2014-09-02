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

#define OneDayTimeInterval    (24*60*60)
#define DateFormat           @"yyyy/MM/dd"

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

@property (strong, nonatomic) NSDate *showDate;
@end

@implementation WMSContent1ViewController

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
    
    [self setupControl];
    
    [self localizableView];
    
    [self adaptiveIphone4];
    
    [self reloadView];
    
    
    [self.mySleepView setSleepTime:120];
    [self.mySleepView setDeepSleepTime:60 andLightSleepTime:30 andWakeupTime:30];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc
{
    DEBUGLog(@"Content1ViewController dealloc");
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
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
}

- (IBAction)gotoMyClockViewAction:(id)sender {
    WMSSmartClockViewController *VC = [[WMSSmartClockViewController alloc] init];
    [self.navigationController pushViewController:VC animated:NO];
}

- (IBAction)gotoMyHistoryViewAction:(id)sender {
}
@end
