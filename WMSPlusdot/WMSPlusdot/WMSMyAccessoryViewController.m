//
//  WMSMyAccessoryViewController.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-15.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMyAccessoryViewController.h"
#import "UIViewController+RESideMenu.h"
#import "WMSLeftViewController.h"
#import "RESideMenu.h"
#import "WMSBindingAccessoryViewController.h"
#import "WMSContentViewController.h"
#import "WMSRightViewController.h"
#import "UIViewController+Tip.h"

#import "WMSAppDelegate.h"
#import "MBProgressHUD.h"
#import "WMSNavBarView.h"

#import "WMSMyAccessory.h"
#import "WMSHelper.h"

#define SECTION_NUMBER  1
#define CELL_HIGHT      60
#define HEADER_HEIGHT   10

@interface WMSMyAccessoryViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic, strong) WMSNavBarView *navBarView;

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation WMSMyAccessoryViewController

#pragma mark - Getter
- (WMSNavBarView *)navBarView
{
    if (!_navBarView) {
        _navBarView = [[WMSNavBarView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        _navBarView.backgroundColor = UICOLOR_DEFAULT;
        _navBarView.labelTitle.text = NSLocalizedString(@"绑定配件",nil);
        _navBarView.labelTitle.font = Font_DINCondensed(20.f);
    }
    return _navBarView;
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
    
    [self.view addSubview:self.navBarView];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setupControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupControl
{
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Other
- (void)showActionSheet
{
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"解除绑定", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)showBindingTip:(BOOL)successOrFail
{
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    hud.mode = MBProgressHUDModeText;
//    hud.minSize = CGSizeMake(250, 60);
//    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
//    hud.yOffset = ScreenHeight/2.0-60;
//    hud.xOffset = 0;
//    hud.labelText = NSLocalizedString(@"绑定成功", nil);
//    [self.view addSubview:hud];
//    [hud showAnimated:YES whileExecutingBlock:^{
//        sleep(1);
//    } completionBlock:^{
//        [hud removeFromSuperview];
//    }];
    if (successOrFail) {
        [self showTip:NSLocalizedString(@"绑定成功", nil)];
    } else {
        [self showTip:NSLocalizedString(@"绑定失败", nil)];
    }
    
//    WMSLeftViewController *leftVC = (WMSLeftViewController *)self.sideMenuViewController.leftMenuViewController;
//    WMSContentViewController *vc = leftVC.contentVCArray[0];
//    [vc scanAndConnectPeripheral];

}

- (BOOL)showAlertView
{
    self.alertView = nil;
    WMSBleState state = [[WMSAppDelegate appDelegate].wmsBleControl bleState];
    switch (state) {
        case BleStateUnsupported:
        {
            _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的设备不支持BLE4.0",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
            [_alertView show];
            return YES;
        }
        case BleStatePoweredOff:
        {
            _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的蓝牙已关闭，请在“设置-蓝牙”中将其打开",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
            [_alertView show];
            return YES;
        }
        default:
            break;
    }
    return NO;
}


#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//destructive
        //。。。。。。
        //。。。。。。
        [WMSMyAccessory unBindAccessory];
        [self.tableView reloadData];
        
        WMSRightViewController *rightVC = (WMSRightViewController *)self.sideMenuViewController.rightMenuViewController;
        [rightVC resetFirstConnectedConfig];
        
        [WMSHelper clearCache];//清除缓存
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",@"plusdot",NSLocalizedString(@"手表", nil)];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"Plusdot",NSLocalizedString(@"手表", nil)];
    cell.textLabel.font = Font_System(23.0);//Font_DINCondensed(23.0);
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"追踪活动/睡眠，蓝牙4.0无线连接", nil)];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"追踪活动/睡眠，蓝牙4.0无线连接", nil)];
    cell.detailTextLabel.font = Font_System(15.0);//Font_DINCondensed(15.0);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    CGRect frame = cell.textLabel.frame;
    frame.size.height += 10;
    cell.textLabel.frame = frame;
    
    if ([WMSMyAccessory isBindAccessory]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        CGRect frame = imageView.frame;
        frame.size = CGSizeMake(25, 25);
        imageView.frame = frame;
        UIImage *image = [UIImage imageNamed:@"bind_success.png"];
        imageView.image = image;
        cell.accessoryView = imageView;
    } else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aa"]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([WMSMyAccessory isBindAccessory]) {
        [self showActionSheet];
    } else {
        if ([self showAlertView]) {
            return;
        }
        WMSBindingAccessoryViewController *vc = [[WMSBindingAccessoryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notification
- (void)appWillEnterBackground:(NSNotification *)notification
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView = nil;
}


@end
