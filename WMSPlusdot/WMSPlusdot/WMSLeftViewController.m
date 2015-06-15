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
#import "CheckTimeViewController.h"
#import "WMSSettingVC.h"
#import "WMSAppDelegate.h"
#import "WMSClockListVC.h"
#import "TestViewController.h"

#import "WMSLeftViewCell.h"

#import "WMSPersonModel.h"
#import "Condition.h"

#import "WMSConstants.h"
#import "WMSUserInfoHelper.h"
#import "WMSAppConfig.h"
#import "RequestClass.h"
#import "WMSLocationManager.h"

#define Null_Object     @"Null_Object"

#define SECTION_NUMBER  1
#define CELL_HEIGHT     46

@interface WMSLeftViewController ()<UITableViewDataSource,UITableViewDelegate,WMSMyAccountViewControllerDelegate>

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *imageNameArray;
@property (strong, nonatomic) NSArray *seletedImageNameArray;

@property (strong, nonatomic) NSArray *specifyContentVCClassArray;
@end

@implementation WMSLeftViewController

#pragma mark - Getter
- (NSArray *)titleArray
{
    if (!_titleArray) {
        NSArray *items = @[NSLocalizedString(@"My sport",nil),
                           NSLocalizedString(@"My sleep",nil),
                           NSLocalizedString(@"Target setting",nil),
                           NSLocalizedString(@"Bound watch",nil),
                           NSLocalizedString(@"校对时间", nil),
                           @"test",
                           ];
        NSMutableArray *mutiArr = [NSMutableArray arrayWithArray:items];
        _titleArray = mutiArr;
    }
    return _titleArray;
}
- (NSArray *)imageNameArray
{
    if (!_imageNameArray) {
        _imageNameArray = @[@"main_menu_sport_icon_a.png",
                            @"main_menu_sleep_icon_a.png",
                            @"main_menu_target_icon_a.png",
                            @"main_menu_binding_icon_a.png",
                            @"main_menu_checkTime_icon_a.png",
                            @"",
                            ];
    }
    return _imageNameArray;
}
- (NSArray *)seletedImageNameArray
{
    if (!_seletedImageNameArray) {
        _seletedImageNameArray = @[@"main_menu_sport_icon_b.png",
                                   @"main_menu_sleep_icon_b.png",
                                   @"main_menu_target_icon_b.png",
                                   @"main_menu_binding_icon_b.png",
                                   @"main_menu_checkTime_icon_b.png",
                                   @"",
                                   ];
    }
    return _seletedImageNameArray;
}
- (NSArray *)specifyContentVCClassArray
{
    if (!_specifyContentVCClassArray) {
        _specifyContentVCClassArray = @[
                                        [WMSContentViewController class],
                                        [WMSContent1ViewController class],
                                        [WMSContent2ViewController class],
                                        [WMSMyAccessoryViewController class],
                                        [CheckTimeViewController class],
                                        [TestViewController class],
                                        ];
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
                           Null_Object,
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
    
    [self loadUserInfo];
    [self setupTableView];
    [self setupUserPhoto];
    
    [self findCurrentLocation];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"LeftViewController dealloc");
}

#pragma mark - Setup
- (void)setupTableView
{
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.menuTableView.opaque = NO;
    self.menuTableView.backgroundColor = [UIColor clearColor];
    self.menuTableView.backgroundView = nil;
    self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.menuTableView.bounces = NO;
    self.menuTableView.scrollsToTop = NO;
}
- (void)setupUserPhoto
{
    [self.userPhoto setClipsToBounds:YES];
    [self.userPhoto.layer setCornerRadius:self.userPhoto.bounds.size.width/2];
    [self.userPhoto.layer setBorderWidth:1];
    [self.userPhoto.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.userPhoto.layer setBackgroundColor:[UIColor whiteColor].CGColor];
}

- (void)loadUserInfo
{
    WMSPersonModel *model = [WMSUserInfoHelper readPersonInfo];
    
    [self.userPhoto setBackgroundImage:model.image forState:UIControlStateNormal];
    [self.nickNameLabel setText:model.name];
}

#pragma mark - Weather
- (void)findCurrentLocation
{
    __block WMSLocationManager *manager = [WMSLocationManager sharedManager];
    WeakObj(manager, weakManager);
    [manager findCurrentLocation:^(BOOL isSuccess, float lat, float lon) {
        if (isSuccess) {
            StrongObj(weakManager, strongManager);
            if (strongManager) {
                [self requestWeatherOfCity:strongManager.currentCityName];
                
                self.cityLabel.text = strongManager.currentCityName;
            }
        } else {
            //TODO 提示定位失败
        }
    }];
}

- (void)requestWeatherOfCity:(NSString *)cityName
{
    [RequestClass requestWeatherOfCityName:cityName completion:^(BOOL isSuccess, id data, NSError *error) {
        if (isSuccess) {
            DEBUGLog(@"data:%@", data);
            [self updateWeather:data];
        } else {
            DEBUGLog(@"error code:%d", (int)error.code);
        }
    }];
}

- (void)updateWeather:(Condition *)weather
{
    self.tempLabel.text = [NSString stringWithFormat:@"%d°", weather.temperature.intValue];
    self.humidityLabel.text = [NSString stringWithFormat:@"%d%%", weather.humidity.intValue];
    self.weatherIcon.image = [UIImage imageNamed:weather.imageName];
    self.weatherLabel.text = weather.weatherName;
}




#pragma mark - Action
- (IBAction)clickUserPhoto:(id)sender {
    WMSMyAccountViewController *VC = [[WMSMyAccountViewController alloc] init];
    VC.isModifyAccount = YES;
    VC.isNewUser = NO;
    VC.delegate = self;
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:VC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)clickSettingButton:(id)sender {
    WMSSettingVC *vc = [[WMSSettingVC alloc] init];
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - WMSMyAccountViewControllerDelegate
- (void)accountViewControllerDidClose:(WMSMyAccountViewController *)viewController
{
    [self loadUserInfo];
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
    [tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    WMSLeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
    
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

#pragma mark - Public methods
- (void)skipToViewControllerForIndex:(NSUInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self tableView:nil didSelectRowAtIndexPath:path];
}

@end
