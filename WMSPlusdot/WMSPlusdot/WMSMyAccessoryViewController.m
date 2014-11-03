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

#import "WMSAppDelegate.h"
#import "MBProgressHUD.h"
#import "WMSNavBarView.h"

#import "WMSMyAccessory.h"

#define SECTION_NUMBER  1
#define CELL_HIGHT      60
#define HEADER_HEIGHT   10

@interface WMSMyAccessoryViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic, strong) WMSNavBarView *navBarView;
@end

@implementation WMSMyAccessoryViewController

#pragma mark - Getter
- (WMSNavBarView *)navBarView
{
    if (!_navBarView) {
        _navBarView = [[WMSNavBarView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        _navBarView.backgroundColor = UIColorFromRGBAlpha(0x00D5E1, 1);
        _navBarView.labelTitle.text = NSLocalizedString(@"绑定的配件",nil);
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
    
    CGRect frame = self.navBarView.buttonLeft.frame;
    frame.origin.y -= 5;
    self.navBarView.buttonLeft.frame = frame;
}


#pragma mark - Other
- (void)showActionSheet
{
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"解除绑定", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)showTip
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeText;
    hud.minSize = CGSizeMake(250, 60);
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    hud.yOffset = ScreenHeight/2.0-60;
    hud.xOffset = 0;
    hud.labelText = NSLocalizedString(@"绑定成功", nil);
    [self.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
    
    WMSLeftViewController *leftVC = (WMSLeftViewController *)self.sideMenuViewController.leftMenuViewController;
    WMSContentViewController *vc = leftVC.contentVCArray[0];
    [vc scanAndConnectPeripheral];
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
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if ([WMSMyAccessory isBindAccessory] == NO) {
//        return 0;
//    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",@"plusdot",NSLocalizedString(@"手表", nil)];
    cell.textLabel.font = Font_System(23.0);//Font_DINCondensed(23.0);
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"追踪活动/睡眠，蓝牙4.0无线连接", nil)];
    cell.detailTextLabel.font = Font_System(15.0);//Font_DINCondensed(15.0);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    CGRect frame = cell.textLabel.frame;
    frame.size.height += 10;
    cell.textLabel.frame = frame;
    
    if ([WMSMyAccessory isBindAccessory]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aa"]];
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
        WMSBindingAccessoryViewController *vc = [[WMSBindingAccessoryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
