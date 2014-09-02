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
#import "TemperaBar.h"

#define MIN_SPORT_STEPS     0
#define MAX_SPORT_STEPS     20000

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
        _temperaBar = [[TemperaBar alloc] initWithFrame:frame minimumTempera:MIN_SPORT_STEPS maximumTempera:MAX_SPORT_STEPS];
        [_temperaBar addTarget:self action:@selector(onTemperaBarChange:) forControlEvents:UIControlEventValueChanged];
        [_temperaBar addTarget:self action:@selector(onTmpTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _temperaBar;
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
    
    self.labelMySteps.text = @"0";
    self.labelModeType.text = [NSString stringWithFormat:NSLocalizedString(@"%@ mode", nil),@""];
    
    DEBUGLog(@"temperaBar frame:(%f,%f,%f,%f)",self.temperaBar.frame.origin.x,self.temperaBar.frame.origin.y,self.temperaBar.frame.size.width,self.temperaBar.frame.size.height);
    [self.view addSubview:self.temperaBar];
    //[self.centerView addSubview:self.temperaBar];
    
    CGPoint center = [[self.temperaBar superview] center];
    self.temperaBar.center = center;
    CGRect frame = self.temperaBar.frame;
    frame.origin = (CGPoint){frame.origin.x-1,frame.origin.y-20};
    self.temperaBar.frame = frame;
    
    
    [self setupControl];
    
    [self localizableView];
    
    [self adaptiveIphone4];
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

- (void)dealloc
{
    DEBUGLog(@"Content2ViewController dealloc");
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
    [self.buttonRight setHidden:YES];
}

//本地化
- (void)localizableView
{
    _labelViewTitle.text = NSLocalizedString(@"Set target",nil);
    _labelStep.text = NSLocalizedString(@"Step",nil);
    //_labelRange.text = [NSString stringWithFormat:NSLocalizedString(@"The range of %d-%d steps",nil), MIN_SPORT_STEPS,MAX_SPORT_STEPS];
    _labelRange.text = @"坚持锻炼一个月,";
    
    //_labelTip.text = NSLocalizedString(@"Experts suggest that exercise every day 10000 steps is positive and healthy lifestyle",nil);
    //[self setLabelTipText:NSLocalizedString(@"Experts suggest that exercise every day 10000 steps is positive and healthy lifestyle",nil)];
    [self setLabelTipText:@"并分享到朋友圈，即可获得精美礼品哦！"];
    
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    
    CGRect frame = self.centerView.frame;
    frame.origin.y -= 40;
    self.centerView.frame = frame;
    
    frame = self.temperaBar.frame;
    frame.origin.y -= 40;
    self.temperaBar.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y -= 40;
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
    self.labelMySteps.text = [NSString stringWithFormat:@"%d",bar.currentTempera];
}
- (void)onTmpTouchUp:(id)sender
{
    
}

@end
