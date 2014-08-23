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

#define MIN_SPORT_STEPS     0
#define MAX_SPORT_STEPS     20000

@interface WMSContent2ViewController ()
{
    __weak IBOutlet UILabel *_labelStep;
    __weak IBOutlet UILabel *_labelRange;
    __weak IBOutlet UILabel *_labelTip;
}

@end

@implementation WMSContent2ViewController

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
    _labelStep.text = NSLocalizedString(@"Step",nil);
    _labelRange.text = [NSString stringWithFormat:NSLocalizedString(@"The range of %d-%d steps",nil), MIN_SPORT_STEPS,MAX_SPORT_STEPS];
    _labelTip.text = NSLocalizedString(@"Experts suggest that exercise every day 10000 steps is positive and healthy lifestyle",nil);
    
    //[_labelTip superview].bounds.size.height - _labelTip.frame.origin.y;
    //_labelTip.bounds = (CGRect){_labelTip.bounds.origin,_labelTip.bounds.size.width,100};
    _labelTip.numberOfLines = 10;//表示label可以多行显示
    //_labelTip.lineBreakMode = NSLineBreakByClipping;//换行模式，与上面的计算保持一致。UILineBreakModeCharacterWrap
    CGSize size = CGSizeMake(60, 1000);
    CGSize labelSize = [_labelTip.text sizeWithFont:_labelTip.font
                                  constrainedToSize:size
                                      lineBreakMode:NSLineBreakByClipping];
    _labelTip.frame = CGRectMake(_labelTip.frame.origin.x, _labelTip.frame.origin.y,
                             _labelTip.frame.size.width, labelSize.height);
}

#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}
@end
