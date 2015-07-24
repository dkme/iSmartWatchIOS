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

#import "WMSBoundCell.h"
#import "MBProgressHUD.h"
#import "WMSNavBarView.h"

#import "WMSMyAccessory.h"
#import "WMSHelper.h"

#define SECTION_NUMBER      1
#define CELL_HIGHT          207
#define HEADER_HEIGHT       50
#define FOOTER_HEIGHT       1

NSString* const WMSBindAccessorySuccess = @"com.guogee.pludsot.WMSBindAccessorySuccess";
NSString* const WMSUnBindAccessorySuccess =
    @"com.guogee.pludsot.WMSUnBindAccessorySuccess";

@interface WMSMyAccessoryViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) WMSNavBarView *navBarView;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) NSArray *imageNameArray;
@property (nonatomic, strong) NSArray *textArray;
@end

@implementation WMSMyAccessoryViewController

#pragma mark - Getter
- (WMSNavBarView *)navBarView
{
    if (!_navBarView) {
        _navBarView = [[WMSNavBarView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        _navBarView.backgroundColor = UICOLOR_DEFAULT;
        _navBarView.labelTitle.text = NSLocalizedString(@"Bound watch",nil);
        _navBarView.labelTitle.font = Font_DINCondensed(20.f);
        CGRect frame = _navBarView.buttonLeft.frame;
        frame.origin.x = 15.0;
        _navBarView.buttonLeft.frame = frame;
    }
    return _navBarView;
}
- (NSArray *)imageNameArray
{
    if (!_imageNameArray) {
        _imageNameArray = @[@"plusdot_one.png",
                            //@"plusdot_two.png",
                            //@"plusdot_one.png",
                            ];
    }
    return _imageNameArray;
}
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = @[
                       //NSLocalizedString(@"SMART WATCH P1", nil),
                       //NSLocalizedString(@"SMART WATCH P2", nil),
                       NSLocalizedString(@"SMART WATCH P3", nil),
                       ];
    }
    return _textArray;
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
    
    [self setupNavBarView];
    [self setupTableView];
    [self registerForNotifications];
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

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
    [self unregisterFromNotifications];
}

#pragma mark - Private
- (void)setupNavBarView
{
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navBarView];
}
- (void)setupTableView
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollEnabled = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)reset
{
    //复位操作
    [WMSRightVCHelper resetFirstConnectedConfig];
    [WMSHelper clearCache];//清除缓存
}

#pragma mark - Show view
- (void)showActionSheet
{
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"解除绑定", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)showBindingTip:(BOOL)successOrFail
{
    if (successOrFail) {
        [self showTip:NSLocalizedString(@"绑定成功", nil)];
        [self.tableView reloadData];
        [self buttonLeftClicked:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(skipSportVC) object:nil];
        [self performSelector:@selector(skipSportVC) withObject:nil afterDelay:0.8];
        [[NSNotificationCenter defaultCenter] postNotificationName:WMSBindAccessorySuccess object:nil userInfo:nil];
    } else {
        [self showTip:NSLocalizedString(@"绑定失败", nil)];
    }
}
- (void)showUnBindTip:(BOOL)success
{
    if (success) {
        [self reset];
        [WMSMyAccessory unBindAccessory];
        [[NSNotificationCenter defaultCenter] postNotificationName:WMSUnBindAccessorySuccess object:nil userInfo:nil];
        [self.tableView reloadData];
        [self showTip:NSLocalizedString(@"解绑成功", nil)];
    } else {
        [self showTip:NSLocalizedString(@"解绑失败", nil)];
    }
}

//cmd：0表示解绑，1表示绑定
- (BOOL)showAlertView:(int)cmd
{
    self.alertView = nil;
    if (cmd == 0) {
        _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您还没有连接手表,强制解绑会导致之前设置在手表的信息（闹钟，久坐）残留在手表中",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"解绑",nil), nil];
        [_alertView show];
        return YES;
    }
    else {
        WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
        switch ([bleControl bleState]) {
            case WMSBleStateUnsupported:
            {
                _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的设备不支持BLE4.0",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
                [_alertView show];
                return YES;
            }
            case WMSBleStatePoweredOff:
            {
                _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的蓝牙已关闭，请在“设置-蓝牙”中将其打开",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
                [_alertView show];
                return YES;
            }
            default:
                break;
        }
    }
    return NO;
}


#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)skipSportVC
{
    WMSLeftViewController *vc = (WMSLeftViewController *)self.sideMenuViewController.leftMenuViewController;
    [vc skipToViewControllerForIndex:0];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self showUnBindTip:YES];
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//destructive
        WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
//        [bleControl bindSettingCMD:bindSettingCMDUnbind completion:^(BindingResult result) {
//            DEBUGLog(@"解绑%d",result);
//            switch (result) {
//                case BindingResultSuccess:
//                {
//                    [bleControl disconnect:^(BOOL success) {
//                        [self showUnBindTip:success];
//                    }];
//                    break;
//                }
//                default:
//                    [self showUnBindTip:NO];
//                    break;
//            }
//        }];
        WeakObj(bleControl, weakBleControl);
        [bleControl unbindDevice:^(BOOL isSuccess) {
            if (isSuccess) {
                StrongObj(weakBleControl, strongBleControl);
                if (strongBleControl) {
                    [strongBleControl disconnect:^(BOOL success) {
                        [self showUnBindTip:success];
                    }];
                }
            } else {
                [self showUnBindTip:NO];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageNameArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"WMSBoundCell";
    UINib *cellNib = [UINib nibWithNibName:@"WMSBoundCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    WMSBoundCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[WMSBoundCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *state = self.textArray[indexPath.row];
    UIColor *color = nil;
    if ([WMSMyAccessory isBindAccessory]) {
        AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
        g = 1;//补丁
        if (indexPath.row+1 == g) {
            state = [NSString stringWithFormat:@"%@(%@)",state,NSLocalizedString(@"已绑定", nil)];
            color = [UIColor redColor];
        } else {
            state = [NSString stringWithFormat:@"%@%@",state,NSLocalizedString(@"", nil)];
            color = UICOLOR_DEFAULT;
        }
    } else {
        state = [NSString stringWithFormat:@"%@(%@)",state,NSLocalizedString(@"点击绑定", nil)];
        color = UICOLOR_DEFAULT;
    }
    cell.bottomLabel.text = state;
    cell.bottomLabel.textColor = color;
    cell.bottomLabel.font = Font_System(15.0);
    NSString *imageName = self.imageNameArray[indexPath.row];
    cell.topImageView.image = [UIImage imageNamed:imageName];
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FOOTER_HEIGHT;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([WMSMyAccessory isBindAccessory]) {
        AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
        if (indexPath.row+1 == g) {
            WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
            if (bleControl.isConnected) {
                [self showActionSheet];
            } else {
                [self showAlertView:0];
            }
        } else {
            [self showTip:NSLocalizedString(@"您已经绑定了手表，请先解绑", nil)];
        }
    } else {
        if ([self showAlertView:1]) {
            return;
        }
        WMSBindingAccessoryViewController *vc = [[WMSBindingAccessoryViewController alloc] init];
        vc.generation = (int)indexPath.row+1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)appWillEnterBackground:(NSNotification *)notification
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView = nil;
}


@end
