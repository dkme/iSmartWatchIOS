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

@interface CheckTimeViewController ()

@property (nonatomic, strong) WMSBleControl *bleControl;

@end

@implementation CheckTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavBar];
    [self setupUI];
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

- (void)setupUI
{
    self.view.backgroundColor = UICOLOR_DEFAULT;
    
    [self updateDescribeLabelWithHour:0 minute:0];
}

#pragma mark - Update UI
- (void)updateDescribeLabelWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    self.describeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"将手表时间向后调整%02d小时%02d分钟", nil), hour, minute];
}

#pragma mark - Action
- (void)clickLeftBarButtonItem:(id)action
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 12;
        case 1:
            return 60;
        default:
            break;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return ScreenWidth/2.0;
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = [NSString stringWithFormat:@"%d", (int)row];
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 };
    return [[NSAttributedString alloc] initWithString:str attributes:attributes];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger hour, minute;
    hour = minute = 0;
    hour = [pickerView selectedRowInComponent:0];
    minute = [pickerView selectedRowInComponent:1];
    [self updateDescribeLabelWithHour:hour minute:minute];
}

@end
