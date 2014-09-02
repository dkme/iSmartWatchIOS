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
#import "WMSLeftViewCell.h"
#import "WMSMyAccountViewController.h"

#define userInfoViewFrame ( CGRectMake(0, 0, self.view.frame.size.width - 82, (self.view.frame.size.height - 54 * 5) / 2.0f + 64) )
#define userImgBtnFrame ( CGRectMake(_userInfoView.center.x - 45, _userInfoView.center.y - 45 - 10, 79, 79) )
#define userLabelFrame ( CGRectMake(0, userImgBtn.center.y + 45, _userInfoView.frame.size.width, 35) )
#define tableViewFrame ( iPhone5 ? (CGRectMake(0, (self.view.frame.size.height - 65 * 5) / 2.0f + 60, self.view.frame.size.width, 65 * 5)) : (CGRectMake(0, (self.view.frame.size.height - 65 * 5) / 2.0f + 150, self.view.frame.size.width, 65 * 5)) )
#define settingBtnFrame ( iPhone5 ? CGRectMake(16, self.view.frame.size.height - 50, 30, 30) : CGRectMake(16, self.view.frame.size.height - 150, 30, 30) )

#define Null_Object     @"Null_Object"

#define SECTION_NUMBER  1
#define CELL_HEIGHT     44

@interface WMSLeftViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIView *userInfoView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *buttonSetting;

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *imageNameArray;
@property (strong, nonatomic) NSArray *seletedImageNameArray;

@property (strong, nonatomic) NSArray *specifyContentVCClassArray;
@property (strong, nonatomic) NSMutableArray *contentVCArray;
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
        [_userInfoView addSubview:userImgBtn];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:userLabelFrame];
        [userLabel setText:@"xxxxx"];
        [userLabel setTextAlignment:NSTextAlignmentCenter];
        [userLabel setTextColor:[UIColor whiteColor]];
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
                       NSLocalizedString(@"My sports",nil),
                       NSLocalizedString(@"My sleep",nil),
                       NSLocalizedString(@"Set target",nil),
                       NSLocalizedString(@"Binding accessories",nil),
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
                           @"main_menu_target_icon_a.png",
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
                           @"main_menu_target_icon_b.png",
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
                                       [WMSContent1ViewController class],
                                       [WMSContent2ViewController class],
                                       [WMSBindingAccessoryViewController class],
                                       nil];
    }
    return _specifyContentVCClassArray;
}
- (NSMutableArray *)contentVCArray
{
    if (!_contentVCArray) {
        if ([UINavigationController class] != [self.sideMenuViewController.contentViewController class]) {
            return nil;
        }
        UIViewController *vc = ((UINavigationController *)self.sideMenuViewController.contentViewController).topViewController;
        _contentVCArray = [[NSMutableArray alloc] initWithObjects:
                           vc,
                           Null_Object,
                           Null_Object,
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
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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


#pragma mark - Events
- (void)userImgBtnClick:(id)sender
{
    WMSMyAccountViewController *VC = [[WMSMyAccountViewController alloc] init];
    [self presentViewController:VC animated:YES completion:nil];
}
- (void)settingBtnClick:(id)sender
{
    
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
    cell.leftLabelText.font = [UIFont fontWithName:@"System" size:8.f];
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
/*
    if (indexPath.row == 0) {
        if ([WMSContentViewController class] == [self.sideMenuViewController.contentViewController class]) {
            [self.sideMenuViewController hideMenuViewController];
            return;
        }
        UIViewController *VC = nil;
        if ([Null_Object isEqualToString:[self.contentVCArray objectAtIndex:indexPath.row]]) {
            VC = [[WMSContentViewController alloc] init];
            [self.contentVCArray setObject:VC atIndexedSubscript:indexPath.row];
        } else {
            VC = [self.contentVCArray objectAtIndex:indexPath.row];
        }
        [self.sideMenuViewController setContentViewController:VC
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
        
        return;
    }
    
    if (indexPath.row == 1) {
        if ([WMSContent1ViewController class] == [self.sideMenuViewController.contentViewController class]) {
            [self.sideMenuViewController hideMenuViewController];
            return;
        }
        UIViewController *VC = nil;
        if ([Null_Object isEqualToString:[self.contentVCArray objectAtIndex:indexPath.row]]) {
            VC =
            [[UINavigationController alloc] initWithRootViewController:[[WMSContent1ViewController alloc] init]];
            [self.contentVCArray setObject:VC atIndexedSubscript:indexPath.row];
        } else {
            VC = [self.contentVCArray objectAtIndex:indexPath.row];
        }
        [self.sideMenuViewController setContentViewController:VC
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
        
        return;
    }
    
    if (indexPath.row == 2) {
        if ([WMSContent2ViewController class] == [self.sideMenuViewController.contentViewController class]) {
            [self.sideMenuViewController hideMenuViewController];
            return;
        }
        UIViewController *VC = nil;
        if ([Null_Object isEqualToString:[self.contentVCArray objectAtIndex:indexPath.row]]) {
            VC =
            [[UINavigationController alloc] initWithRootViewController:[[WMSContent2ViewController alloc] init]];
            [self.contentVCArray setObject:VC atIndexedSubscript:indexPath.row];
        } else {
            VC = [self.contentVCArray objectAtIndex:indexPath.row];
        }
        [self.sideMenuViewController setContentViewController:VC
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
        
        return;
    }
    
    if (indexPath.row == 3) {
        if ([WMSBindingAccessoryViewController class] == [self.sideMenuViewController.contentViewController class]) {
            [self.sideMenuViewController hideMenuViewController];
            return;
        }
        UIViewController *VC = nil;
        if ([Null_Object isEqualToString:[self.contentVCArray objectAtIndex:indexPath.row]]) {
            VC =
            [[UINavigationController alloc] initWithRootViewController:[[WMSBindingAccessoryViewController alloc] init]];
            [self.contentVCArray setObject:VC atIndexedSubscript:indexPath.row];
        } else {
            VC = [self.contentVCArray objectAtIndex:indexPath.row];
        }
        [self.sideMenuViewController setContentViewController:VC
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
        
        return;
    }
*/
    
    if ([self.specifyContentVCClassArray objectAtIndex:indexPath.row] == [self.sideMenuViewController.contentViewController class]) {
        [self.sideMenuViewController hideMenuViewController];
        return;
    }
    
    UINavigationController *nav = nil;
    UIViewController *VC = nil;
    if ([Null_Object isEqualToString:[self.contentVCArray objectAtIndex:indexPath.row]]) {
        Class VCClass=[self.specifyContentVCClassArray objectAtIndex:indexPath.row];
        VC = [[VCClass alloc] init];
        [self.contentVCArray setObject:VC atIndexedSubscript:indexPath.row];
    } else {
        VC = [self.contentVCArray objectAtIndex:indexPath.row];
    }
    
    nav = [[UINavigationController alloc] initWithRootViewController:VC];
    [self.sideMenuViewController setContentViewController:nav
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

@end