//
//  WMSContent2ViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-23.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSContent2ViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSAppDelegate.h"

#import "TemperaBar.h"

#import "WMSConstants.h"
#import "WMSHelper.h"

#define CRITICAL_SPORT_STEPS    10000
#define MULTIPLE                100

#define LABEL_MAX_WIDTH     172.f
#define LABEL_MAX_HEIGHT    100.f

@interface WMSContent2ViewController ()
{
    __weak IBOutlet UILabel *_labelViewTitle;
    __weak IBOutlet UILabel *_labelStep;
    __weak IBOutlet UILabel *_labelRange;
    __weak IBOutlet UILabel *_labelTip;
}

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (nonatomic, strong) TemperaBar *temperaBar;
@end

@implementation WMSContent2ViewController

#pragma mark - Getter
- (TemperaBar *)temperaBar
{
    if (!_temperaBar) {
        CGRect frame = CGRectMake(0, 0, 0, 0);/* 大小由背景图决定 */
        _temperaBar = [[TemperaBar alloc] initWithFrame:frame minimumTempera:MIN_SPORT_STEPS/MULTIPLE maximumTempera:MAX_SPORT_STEPS/MULTIPLE];
        [_temperaBar addTarget:self action:@selector(onTemperaBarChange:) forControlEvents:UIControlEventValueChanged];
        [_temperaBar addTarget:self action:@selector(onTmpTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _temperaBar;
}

#pragma mark - Setter
- (void)setTargetSteps:(NSUInteger)targetSteps
{
    NSString *mode = @"";
    if (targetSteps < CRITICAL_SPORT_STEPS) {
        mode = NSLocalizedString(@"菜鸟", nil);
    } else {
        mode = NSLocalizedString(@"砖家", nil);
    }
    NSString *steps = [NSString stringWithFormat:@"%u",targetSteps];
    NSString *unit = NSLocalizedString(@"步",nil);
    NSString *str = [NSString stringWithFormat:@"%@%@",steps,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = steps.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(55.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //self.labelMySteps.text = [NSString stringWithFormat:@"%d",targetSteps];
    //self.labelModeType.text = [NSString stringWithFormat:NSLocalizedString(@"%@ mode", nil), mode];
    self.labelMySteps.attributedText = text;
    self.labelMySteps.adjustsFontSizeToFitWidth = YES;
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
    
    [self.view addSubview:self.temperaBar];
    
    CGPoint center = [[self.temperaBar superview] center];
    self.temperaBar.center = center;
    CGRect frame = self.temperaBar.frame;
    frame.origin = (CGPoint){frame.origin.x-1,frame.origin.y-20};
    self.temperaBar.frame = frame;

    [self setupControl];
    [self localizableView];
    [self adaptiveIphone4];
    [self reloadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DEBUGLog(@"Content2ViewController viewDidAppear");
    
    //self.sideMenuViewController.panGestureEnabled = NO;
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DEBUGLog(@"Content2ViewController viewWillDisappear");
    //self.sideMenuViewController.panGestureEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"Content2ViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupControl
{
    [self.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonRight setTitle:@"" forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_b.png"] forState:UIControlStateHighlighted];
    [self.buttonRight setHidden:YES];
}

//本地化
- (void)localizableView
{
    _labelViewTitle.text = NSLocalizedString(@"设置目标",nil);
    _labelStep.text = NSLocalizedString(@"Step",nil);
    //_labelRange.text = [NSString stringWithFormat:NSLocalizedString(@"The range of %d-%d steps",nil), MIN_SPORT_STEPS,MAX_SPORT_STEPS];
    _labelRange.text = [NSString stringWithFormat:@"%@,",NSLocalizedString(@"坚持锻炼一个月", nil)];
    
    //_labelTip.text = NSLocalizedString(@"Experts suggest that exercise every day 10000 steps is positive and healthy lifestyle",nil);
    //[self setLabelTipText:NSLocalizedString(@"Experts suggest that exercise every day 10000 steps is positive and healthy lifestyle",nil)];
    [self setLabelTipText:[NSString stringWithFormat:@"%@！",NSLocalizedString(@"并分享到朋友圈，即可获得精美礼品哦",nil)] ];
    
}

- (void)reloadView
{
    self.sportTargetSteps = [WMSHelper readTodayTargetSteps];
    [self setTargetSteps:self.sportTargetSteps];
    [self.temperaBar setCurrentTempera:self.sportTargetSteps/MULTIPLE];
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    
    CGRect frame = self.centerView.frame;
    frame.origin.y -= 20;
    self.centerView.frame = frame;
    
    frame = self.temperaBar.frame;
    frame.origin.y -= 20;
    self.temperaBar.frame = frame;

    frame = self.bottomView.frame;
    frame.origin.y -= 20;
    self.bottomView.frame = frame;
}

- (void)setLabelTipText:(NSString *)text
{
    _labelTip.lineBreakMode = NSLineBreakByTruncatingTail;
    _labelTip.numberOfLines = 1;
    UIFont *font = _labelTip.font;
    
    //label可设置的最大宽度和高度
    CGSize size = CGSizeMake(LABEL_MAX_WIDTH, LABEL_MAX_HEIGHT);
    
    //获取当前文本的属性
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    //ios7方法，获取文本需要的size，限制宽度
    CGSize actualsize =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    CGRect frame = _labelTip.frame;
    frame.size.height = actualsize.height;
    _labelTip.frame = frame;
    _labelTip.text = text;
    _labelTip.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (void)onTemperaBarChange:(id)sender
{
    TemperaBar *bar = (TemperaBar *)sender;
    //DEBUGLog(@"value:%d",bar.currentTempera);
    self.sportTargetSteps = bar.currentTempera*MULTIPLE;
    [self setTargetSteps:self.sportTargetSteps];
}
- (void)onTmpTouchUp:(id)sender
{
}

#pragma mark - Notification
- (void)appDidEnterBackground:(NSNotification *)notification
{
    [WMSHelper savaTodayTargetSteps:self.sportTargetSteps];
}

- (void)appWillTerminate:(NSNotification *)notification
{
    //[WMSHelper savaTodayTargetSteps:self.sportTargetSteps];
}

@end
