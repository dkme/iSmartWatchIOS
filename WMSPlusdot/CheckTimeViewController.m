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
    WS(weakSelf);
    
    UIImageView *presentView = [[UIImageView alloc] init];
    presentView.image = [UIImage imageNamed:@"Turntable"];
    CGSize sz = self.turntableView.frame.size;
    
    [self.turntableView addSubview:presentView];
    self.turntableView.delegate = self;
    
    //在做autoLayout之前 一定要先将view添加到superview上 否则会报错
    [presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.turntableView);
        make.size.mas_equalTo(sz);
    }];
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
}

@end
