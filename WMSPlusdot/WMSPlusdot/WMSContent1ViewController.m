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


#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (IBAction)prevDateAction:(id)sender {
}

- (IBAction)nextDateAction:(id)sender {
}

- (IBAction)gotoMyClockViewAction:(id)sender {
    UIViewController *VC = [[UIViewController alloc] init];
    VC.view.backgroundColor = UIColorFromRGBAlpha(0x00D5E1, 1);
//    [self.navigationController pushViewController:VC animated:NO];
}

- (IBAction)gotoMyHistoryViewAction:(id)sender {
}
@end
