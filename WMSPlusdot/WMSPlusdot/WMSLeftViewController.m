//
//  WMSLeftViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-21.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSLeftViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSContentViewController.h"
#import "WMSContent1ViewController.h"
#import "WMSContent2ViewController.h"
#import "WMSBindingAccessoryViewController.h"
#import "WMSMyAccountViewController.h"
#import "WMSMyAccessoryViewController.h"
#import "WMSSettingVC.h"
#import "WMSAppDelegate.h"
#import "WMSClockListVC.h"

#import "WMSLeftViewCell.h"

#import "WMSPersonModel.h"

#import "WMSConstants.h"
#import "WMSUserInfoHelper.h"


#define userInfoViewFrame ( CGRectMake(0, 0, self.view.frame.size.width - 82, (self.view.frame.size.height - 54 * 5) / 2.0f + 30) )
#define userImgBtnFrame ( CGRectMake(_userInfoView.center.x - 40, _userInfoView.center.y - 45 - 10, 79, 79) )
#define userLabelFrame ( CGRectMake(0, userImgBtn.center.y + 45, _userInfoView.frame.size.width, 35) )
#define tableViewFrame ( iPhone5 ? (CGRectMake(0, (self.view.frame.size.height - 65 * 5) / 2.0f + 60, self.view.frame.size.width, 65 * 5)) : (CGRectMake(0, (self.view.frame.size.height - 65 * 5) / 2.0f + 150, self.view.frame.size.width, 65 * 5)) )
#define settingBtnFrame ( iPhone5 ? CGRectMake(16, self.view.frame.size.height - 50, 30, 30) : CGRectMake(16, self.view.frame.size.height - 150, 30, 30) )

#define Null_Object     @"Null_Object"

#define SECTION_NUMBER  1
#define CELL_HEIGHT     46

@interface WMSLeftViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIView *userInfoView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *buttonSetting;

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *imageNameArray;
@property (strong, nonatomic) NSArray *seletedImageNameArray;

@property (strong, nonatomic) NSArray *specifyContentVCClassArray;
@end

@implementation WMSLeftViewController

#pragma mark - Property Getter Method
- (UIView *)userInfoView
{
    if (!_userInfoView) {
        _userInfoView = [[UIView alloc] initWithFrame:userInfoViewFrame];
        [_userInfoView setBackgroundColor:[UIColor clearColor]];
        
        UIButton *userImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [userImgBtn setFrame:userImgBtnFrame];
        [userImgBtn setImage:[UIImage imageNamed:@"main_avatar_default.png"] forState:UIControlStateNormal];
        [userImgBtn setHighlighted:NO];
        [userImgBtn addTarget:self action:@selector(userImgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [userImgBtn setClipsToBounds:YES];
        [userImgBtn.layer setCornerRadius:userImgBtn.bounds.size.width/2];
        [userImgBtn.layer setBorderWidth:0];
        [userImgBtn.layer setBorderColor:[UIColor clearColor].CGColor];
        [_userInfoView addSubview:userImgBtn];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:userLabelFrame];
        [userLabel setText:@""];
        [userLabel setTextAlignment:NSTextAlignmentCenter];
        [userLabel setTextColor:[UIColor whiteColor]];
        [userLabel setBackgroundColor:[UIColor clearColor]];
        [userLabel setFont:Font_DINCondensed(17)];
        [_userInfoView addSubview:userLabel];
    }
    return _userInfoView;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        
        _tableView = tableView;
    }
    return _tableView;
}
- (UIButton *)buttonSetting
{
    if (!_buttonSetting) {
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingBtn setFrame:settingBtnFrame];
        [settingBtn setImage:[UIImage imageNamed:@"main_menu_setting_icon_a.png"] forState:UIControlStateNormal];
        [settingBtn setImage:[UIImage imageNamed:@"main_menu_setting_icon_b.png"] forState:UIControlStateHighlighted];
        [settingBtn addTarget:self action:@selector(settingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonSetting = settingBtn;
    }
    return _buttonSetting;
}

- (NSArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = [[NSArray alloc] initWithObjects:
                       NSLocalizedString(@"My sport",nil),
                       NSLocalizedString(@"Target setting",nil),
                       //NSLocalizedString(@"Smart alarm clock", nil),
                       NSLocalizedString(@"Bound watch",nil),
                       nil];
    }
    return _titleArray;
}
- (NSArray *)imageNameArray
{
    if (!_imageNameArray) {
        _imageNameArray = [[NSArray alloc] initWithObjects:
                           @"main_menu_sport_icon_a.png",
                           @"main_menu_sleep_icon_a.png",
                           //@"main_menu_target_icon_a.png",
                           @"main_menu_binding_icon_a.png",
                           nil];
    }
    return _imageNameArray;
}
- (NSArray *)seletedImageNameArray
{
    if (!_seletedImageNameArray) {
        _seletedImageNameArray = [[NSArray alloc] initWithObjects:
                           @"main_menu_sport_icon_b.png",
                           @"main_menu_sleep_icon_b.png",
                           //@"main_menu_target_icon_b.png",
                           @"main_menu_binding_icon_b.png",
                           nil];
    }
    return _seletedImageNameArray;
}

- (NSArray *)specifyContentVCClassArray
{
    if (!_specifyContentVCClassArray) {
        _specifyContentVCClassArray = [[NSArray alloc] initWithObjects:
                                       [WMSContentViewController class],
                                       [WMSContent2ViewController class],
                                       //[WMSClockListVC class],
                                       [WMSMyAccessoryViewController class],
                                       nil];
    }
    return _specifyContentVCClassArray;
}
- (NSMutableArray *)contentVCArray
{
    if (!_contentVCArray) {
        if ([MyNavigationController class] != [self.sideMenuViewController.contentViewController class]) {
            return nil;
        }
        UIViewController *vc = ((MyNavigationController *)self.sideMenuViewController.contentViewController).topViewController;
        _contentVCArray = [[NSMutableArray alloc] initWithObjects:
                           vc,
                           Null_Object,
                           //Null_Object,
                           Null_Object,
                           nil];
    }
    return _contentVCArray;
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
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.userInfoView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.buttonSetting];
    
    [self reloadView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self reloadView];
    DEBUGLog(@"LeftViewController viewWillAppear");
}
- (void)dealloc
{
    DEBUGLog(@"LeftViewController dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView
{
    WMSPersonModel *model = [WMSUserInfoHelper readPersonInfo];
    [self setUserImage:model.image];
    [self setUserNickname:model.name];
}


//设置用户头像和昵称
- (void)setUserImage:(UIImage *)image
{
    if (image == nil) {
        return;
    }
    NSArray *views = self.userInfoView.subviews;
    UIButton *buttonUserImage = nil;
    for (UIView *viewObj in views) {
        if ([UIButton class] == [viewObj class]) {
            buttonUserImage = (UIButton *)viewObj;
            break;
        }
    }
    [buttonUserImage setImage:image forState:UIControlStateNormal];
}

- (void)setUserNickname:(NSString *)nickname
{
    if (nickname == nil) {
        return;
    }
    NSArray *views = self.userInfoView.subviews;
    UILabel *labelUserNickname = nil;
    for (UIView *viewObj in views) {
        if ([UILabel class] == [viewObj class]) {
            labelUserNickname = (UILabel *)viewObj;
            break;
        }
    }
    [labelUserNickname setText:nickname];
}

- (void)skipToViewControllerForIndex:(NSUInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self tableView:nil didSelectRowAtIndexPath:path];
}

#pragma mark - Events
- (void)userImgBtnClick:(id)sender
{
    WMSMyAccountViewController *VC = [[WMSMyAccountViewController alloc] init];
    VC.isModifyAccount = YES;
    VC.isNewUser = NO;
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:VC];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)settingBtnClick:(id)sender
{
    WMSSettingVC *vc = [[WMSSettingVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"WMSLeftViewCell";
    UINib *cellNib = [UINib nibWithNibName:@"WMSLeftViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    WMSLeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WMSLeftViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
    
    //不用系统自带的
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.font = [UIFont fontWithName:@"System" size:8.f];
//    cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:[self.imageNameArray objectAtIndex:indexPath.row]];
//    cell.imageView.highlightedImage = [UIImage imageNamed:[self.seletedImageNameArray objectAtIndex:indexPath.row]];
    
    cell.leftImageView.image = [UIImage imageNamed:[self.imageNameArray objectAtIndex:indexPath.row]];
    cell.leftImageView.highlightedImage = [UIImage imageNamed:[self.seletedImageNameArray objectAtIndex:indexPath.row]];
    cell.leftLabelText.textColor = [UIColor whiteColor];
    cell.leftLabelText.font = Font_DINCondensed(18);
    cell.leftLabelText.text = [self.titleArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.specifyContentVCClassArray objectAtIndex:indexPath.row] == [self.sideMenuViewController.contentViewController class]) {
        [self.sideMenuViewController hideMenuViewController];
        return;
    }
    
    MyNavigationController *nav = nil;
    UIViewController *VC = nil;
    if ([Null_Object isEqualToString:[self.contentVCArray objectAtIndex:indexPath.row]]) {
        Class VCClass=[self.specifyContentVCClassArray objectAtIndex:indexPath.row];
        VC = [[VCClass alloc] init];
        [self.contentVCArray setObject:VC atIndexedSubscript:indexPath.row];
    } else {
        VC = [self.contentVCArray objectAtIndex:indexPath.row];
    }
    
    nav = [[MyNavigationController alloc] initWithRootViewController:VC];
    [self.sideMenuViewController setContentViewController:nav
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

@end
