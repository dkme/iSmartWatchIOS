//
//  CheckTimeViewController.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/5/21.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "CheckTimeViewController.h"
#import "WMSAppDelegate.h"
#import "WMSTestView.h"


@interface CheckTimeViewController ()

@end

@implementation CheckTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavBar];
    [self setupDialView];
    
    self.view.backgroundColor = UICOLOR_DEFAULT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}


#pragma mark - Setup
- (void)setupNavBar
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"main_menu_icon_a.png" highImageName:@"main_menu_icon_b.png" target:self action:@selector(clickLeftBarButtonItem:)];
    self.title = NSLocalizedString(@"校对时间", nil);
}
- (void)setupDialView
{
//    self.dialView.backgroundColor = [UIColor clearColor];
//    self.dialView.backgroundImage.image = [UIImage imageNamed:@"Dial"];
//    self.dialView.backgroundColor = [UIColor redColor];
    
    DialView *aa = [[DialView alloc] initWithFrame:CGRectMake(65, 100, 190, 190)];
    aa.backgroundColor = [UIColor yellowColor];
    aa.userInteractionEnabled = YES;
    [self.view addSubview:aa];
    
//    WMSTestView *test = [[WMSTestView alloc] initWithFrame:CGRectMake(20, 60+190+20, 200, 200)];
//    test.backgroundColor = [UIColor redColor];
//    test.userInteractionEnabled = YES;
//    [self.view addSubview:test];
}


#pragma mark - Action
- (void)clickLeftBarButtonItem:(id)action
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

@end
