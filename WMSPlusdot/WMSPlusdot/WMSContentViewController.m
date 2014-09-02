//
//  WMSContentViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSContentViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSMySportView.h"
#import "WMSActivityRemindViewController.h"
#import "NSDate+Formatter.h"

#define OneDayTimeInterval    (24*60*60)
#define DateFormat            @"yyyy/MM/dd"

@interface WMSContentViewController ()
{
    //需本地化
    __weak IBOutlet UILabel *_labelMySport;
    __weak IBOutlet UILabel *_labelStep;
    __weak IBOutlet UILabel *_labelStep2;
    __weak IBOutlet UILabel *_labelMuBiao;
    __weak IBOutlet UILabel *_labelRanShao;
    __weak IBOutlet UILabel *_labelJuli;
    __weak IBOutlet UILabel *_labelShiJian;
    
}

@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet WMSMySportView *mySportView;

@property (strong, nonatomic) NSDate *showDate;
@end

@implementation WMSContentViewController

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
    
    [self setupControl];
    
    [self localizableView];
    
    [self reloadView];
    
    [self adaptiveIphone4];
    
    [self.mySportView setTargetSetps:100];
    [self.mySportView setSportSteps:50];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc
{
    DEBUGLog(@"ContentViewController dealloc");
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
    
    [self.buttonTarget setTitle:@"" forState:UIControlStateNormal];
    [self.buttonTarget setBackgroundImage:[UIImage imageNamed:@"main_target_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonTarget setBackgroundImage:[UIImage imageNamed:@"main_target_btn_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonHistory setTitle:@"" forState:UIControlStateNormal];
    [self.buttonHistory setBackgroundImage:[UIImage imageNamed:@"main_history_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonHistory setBackgroundImage:[UIImage imageNamed:@"main_history_btn_b.png"] forState:UIControlStateHighlighted];
}

- (void)localizableView
{
    _labelMySport.text = NSLocalizedString(@"My sports",nil);
    _labelStep.text = NSLocalizedString(@"Step",nil);
    _labelStep2.text = NSLocalizedString(@"Step",nil);
    _labelMuBiao.text = NSLocalizedString(@"Target",nil);
    _labelRanShao.text = NSLocalizedString(@"Burn",nil);
    _labelJuli.text = NSLocalizedString(@"Distance",nil);
    _labelShiJian.text = NSLocalizedString(@"Time",nil);
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.dateView.frame;
    frame.origin.y -= 20;
    self.dateView.frame = frame;
    
    frame = self.mySportView.frame;
    frame.origin.y -= 40;
    self.mySportView.frame = frame;
    
    frame = self.buttonTarget.frame;
    frame.origin.y -= 50;
    self.buttonTarget.frame = frame;
    
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
    //DEBUGLog(@"newDate:%@,%f,%f",[newDate description],[self.showDate timeIntervalSinceNow],OneDayTimeInterval*-1.0);
    
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
}

- (IBAction)gotoMyTargetViewAction:(id)sender {
    WMSActivityRemindViewController *VC = [[WMSActivityRemindViewController alloc] init];
    [self.navigationController pushViewController:VC animated:NO];
}

- (IBAction)gotoMyHistoryViewAction:(id)sender {
    
}
@end
