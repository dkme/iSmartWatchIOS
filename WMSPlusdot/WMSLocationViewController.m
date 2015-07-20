//
//  WMSLocationViewController.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/15.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSLocationViewController.h"
#import "WMSLocationManager.h"

typedef enum {
    GET_LOCATION_STATUS_GETTING = 0,
    GET_LOCATION_STATUS_FAIL,
    GET_LOCATION_STATUS_SUCCESS,
} GetLocationStatus;

@interface WMSLocationViewController () <WMSLocationManagerDelegate>

@property (nonatomic, assign) GetLocationStatus status;

@property (nonatomic, strong) WMSLocationManager *manager;

@end

@implementation WMSLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupProperty];
    [self setupNavBar];
    [self setupUI];
    
    [self findCurrentLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog_METHOD;
    self.manager.delegate = nil;
}

- (void)setupProperty
{
    self.status = GET_LOCATION_STATUS_GETTING;
}
- (void)setupNavBar
{
    self.title = NSLocalizedString(@"城市",nil);
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
}
- (void)setupUI
{
    self.locationButton.layer.shadowOffset = CGSizeMake(-1, 3);
    self.locationButton.layer.shadowColor = [UIColor grayColor].CGColor;
    self.locationButton.layer.shadowOpacity = 1.f;
}

- (void)findCurrentLocation
{
    [self.locationButton setTitle:NSLocalizedString(@"正在定位中...", nil) forState:UIControlStateNormal];
    self.manager = [WMSLocationManager sharedManager];
    self.manager.delegate = self;
    WeakObj(self.manager, weakManager);
    [self.manager findCurrentLocation:^(BOOL isSuccess, float lat, float lon, NSError *error) {
        StrongObj(weakManager, strongManager);
        if (strongManager) {
            if (isSuccess) {
                self.status = GET_LOCATION_STATUS_SUCCESS;
                [self.locationButton setTitle:strongManager.currentCityName forState:UIControlStateNormal];
            } else {
                //提示定位失败
                self.status = GET_LOCATION_STATUS_FAIL;
                [self.locationButton setTitle:NSLocalizedString(@"定位失败，点击重试", nil)forState:UIControlStateNormal];
                
                if (error.code == kCLErrorDenied) {
                    [strongManager showAlertView];
                }
            }
        }
        
    }];
}

- (void)callDelegate:(NSString *)name
{
    DEBUGLog(@"name:%@", name);
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationViewController:didGetLocation:)]) {
        [self.delegate locationViewController:self didGetLocation:name];
    }
    [self close];
}

- (void)close
{
    if (self.status == GET_LOCATION_STATUS_GETTING) {
        WMSLocationManager *manager = [WMSLocationManager sharedManager];
        [manager stopFindLocation];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    [self close];
}

- (IBAction)findLocationAction:(id)sender {
    switch (self.status) {
        case GET_LOCATION_STATUS_FAIL:
            [self findCurrentLocation];
            break;
        case GET_LOCATION_STATUS_SUCCESS:
        {
            NSString *name = [(UIButton *)sender titleForState:UIControlStateNormal];
            [self callDelegate:name];
            break;
        }
        default:
            break;
    }
}

- (IBAction)confirmAction:(id)sender {
    NSString *name = [self.cityText text];
    if (name && ![@"" isEqualToString:name]) {
        [self callDelegate:name];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - WMSLocationManagerDelegate
- (void)locationManagerdidCanPosition:(WMSLocationManager *)manager
{
    [self findCurrentLocation];
}


@end
