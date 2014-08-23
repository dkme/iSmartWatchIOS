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

@interface WMSBindingAccessoryViewController ()
{
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelTip;
}

@end

@implementation WMSBindingAccessoryViewController

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
    
    [self initUI];
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
    DEBUGLog(@"WMSBindingAccessoryViewController dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
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
    _labelTitle.text = NSLocalizedString(@"Binding accessories",nil);
    _labelTip.text = NSLocalizedString(@"Please make sure the watch power is on and near the phone",nil);
    
}


#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}
@end
