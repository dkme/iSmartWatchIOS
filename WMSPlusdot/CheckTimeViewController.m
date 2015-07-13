//
//  CheckTimeViewController.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/5/21.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "CheckTimeViewController.h"
#import "WMSAppDelegate.h"
#import "Masonry.h"

@interface CheckTimeViewController ()<TurntableViewDelegate>

@property (nonatomic, strong) WMSBleControl *bleControl;

@end

@implementation CheckTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavBar];
    [self setupTurntableView];
    
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
- (void)setupTurntableView
{
    self.turntableView.delegate = self;
    self.turntableView.translatesAutoresizingMaskIntoConstraints = NO;
}


#pragma mark - Action
- (void)clickLeftBarButtonItem:(id)action
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - TurntableViewDelegate
- (void)turntableViewDidRotate:(TurntableView *)turntableView byRotateDirection:(RotateDirection)direction
{
    DEBUGLog(@"RotateDirection：%d", direction);
    if (!self.bleControl) {
        _bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
    }
    [self.bleControl.settingProfile adjustTimeDirection:(ROTATE_DIRECTION)direction completion:^(BOOL isSuccess) {
        DEBUGLog_DETAIL(@"调整时间成功");
    }];
}

@end
