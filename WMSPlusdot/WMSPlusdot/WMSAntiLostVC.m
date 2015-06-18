//
//  WMSAntiLostVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAntiLostVC.h"
#import "WMSAppDelegate.h"
#import "UIViewController+Tip.h"
#import "WMSNavBarView.h"
#import "WMSSwitchCell.h"
#import "WMSInputView.h"
#import "WMSMyAccessory.h"
#import "WMSFileMacro.h"
#import "WMSConstants.h"

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

#define SECTION_NUMBER              1
#define SECTION0_HEADER_HEIGHT      40

#define PICKER_VIEW_COMPONENT_NUMBER        1
#define PICKER_VIEW_COMPONENT_WIDTH         ScreenWidth

#define ANTI_LOST_DISTANCE          60

@interface WMSAntiLostVC ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WMSInputViewDelegate,UIAlertViewDelegate>
{
    NSInteger _oldStatus;
    NSInteger _oldTimeInterval;
    NSInteger _timeInterval;
}
@property (nonatomic, strong) WMSInputView *myInputView;
@property (strong, nonatomic) UISwitch *cellSwitch;
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, strong) NSArray *pickerViewDataSource;
@end

@implementation WMSAntiLostVC

#pragma mark - Getter/Setter
- (WMSInputView *)myInputView
{
    if (!_myInputView) {
        _myInputView= [[WMSInputView alloc] initWithLeftItemTitle:NSLocalizedString(@"Cancel", nil) RightItemTitle:NSLocalizedString(@"Confirm",nil)];
        _myInputView.pickerView.delegate = self;
        _myInputView.pickerView.dataSource = self;
        _myInputView.delegate = self;
        [_myInputView hidden:NO];
    }
    return _myInputView;
}
- (UISwitch *)cellSwitch
{
    if (!_cellSwitch) {
        _cellSwitch = [[UISwitch alloc] initWithFrame:UISwitch_Frame];
        [_cellSwitch setOn:YES animated:NO];
        [_cellSwitch addTarget:self action:@selector(switchBtnValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_cellSwitch setOnTintColor:UICOLOR_DEFAULT];
    }
    return _cellSwitch;
}
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = @[NSLocalizedString(@"防丢", nil),
                       NSLocalizedString(@"Interval", nil),
                       ];
    }
    return _textArray;
}
- (NSArray *)pickerViewDataSource
{
    if (!_pickerViewDataSource) {
        _pickerViewDataSource = @[@"5",@"10",@"20",@"35"];
    }
    return _pickerViewDataSource;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadData];
    [self setupView];
    [self setupNavigationBar];
    [self setupTableView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - setup UI
- (void)setupView
{
    [self.view addSubview:self.myInputView];
}
- (void)setupNavigationBar
{
    SetControllerKeepExtendedLayout();
    UIBarButtonItem *leftItem = [UIBarButtonItem itemWithImageName:@"back_btn_a.png" highImageName:@"back_btn_b.png" target:self action:@selector(backAction:)];
    UIBarButtonItem *item1 = [UIBarButtonItem itemWithTitle:NSLocalizedString(@"同步", nil) font:Font_System(18.0) size:SYNC_BUTTON_SIZE target:self action:@selector(syncSettingAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = item1;
}
- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
}

#pragma mark - Data
- (void)loadData
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FileDocumentPath(FILE_ANTILOST)];
    _timeInterval = [readData[@"interval"] integerValue];
    self.cellSwitch.on = [readData[@"on"] integerValue];
    if (readData==nil || _timeInterval==0) {
        _timeInterval = 5;
        self.cellSwitch.on = NO;
    }
    _oldStatus = self.cellSwitch.on;
    _oldTimeInterval = _timeInterval;
}
- (void)savaData
{
    BOOL on = self.cellSwitch.on;
    NSDictionary *writeData = @{@"interval":@(_timeInterval),@"on":@(on)};
    [writeData writeToFile:FileDocumentPath(FILE_ANTILOST) atomically:YES];
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    if (self.cellSwitch.on          == _oldStatus &&
        _timeInterval               == _oldTimeInterval)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSString *message = NSLocalizedString(@"您的防丢提醒已修改，尚未同步到手表，是否同步?", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        [alert show];
    }
}

- (void)syncSettingAction:(id)sender
{
    WMSBleControl *bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
    BOOL isBind = [WMSMyAccessory isBindAccessory];
    BOOL isConnected = [bleControl isConnected];
    BOOL result = [self checkoutWithIsBind:isBind isConnected:isConnected];
    if (result == NO) {
        return;
    }
    BOOL on = self.cellSwitch.on;
    NSUInteger interval = _timeInterval;
//    [bleControl.settingProfile setAntiLostStatus:on distance:ANTI_LOST_DISTANCE timeInterval:interval completion:^(BOOL success)
//     {
//         DEBUGLog(@"设置防丢%@",success?@"成功":@"失败");
//         _oldStatus = on;
//         _oldTimeInterval = interval;
//         [self savaData];
//         [self showOperationSuccessTip:NSLocalizedString(@"设置防丢成功", nil)];
//     }];
}

- (void)switchBtnValueChanged:(id)sender
{
    //UISwitch *sw = (UISwitch *)sender;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//NO
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self syncSettingAction:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.textArray count];
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)section,(int)row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [self.textArray objectAtIndex:row];
        [cell.contentView addSubview:self.cellSwitch];
        return cell;
    }
    
    cell.textLabel.text = [self.textArray objectAtIndex:row];
    //cell.textLabel.font = Font_System(18.0);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ds",(int)_timeInterval];
    cell.detailTextLabel.font = Font_System(15.0);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
            break;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
    CGRect frame = CGRectMake(0, height-30, ScreenWidth, 30);
    UIView *myView = [[UIView alloc] init];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.font = Font_System(12.0);
    titleLabel.numberOfLines = -1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSString *title = NSLocalizedString(@"添加时间，手表会在蓝牙断开后的这个时间提醒您", nil);
    
    [titleLabel setText:title];
    [myView addSubview:titleLabel];
    
    return myView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.myInputView show:YES];
    NSUInteger row = [self.pickerViewDataSource indexOfObject:[NSString stringWithFormat:@"%d",(int)_timeInterval]];
    if (row < [self.pickerViewDataSource count]) {
        [self.myInputView.pickerView selectRow:row inComponent:0 animated:NO];
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return PICKER_VIEW_COMPONENT_NUMBER;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerViewDataSource count];
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return PICKER_VIEW_COMPONENT_WIDTH;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerViewDataSource[row];
}

#pragma mark - WMSInputViewDelegate
- (void)inputView:(WMSInputView *)inputView didClickLeftItem:(UIBarButtonItem *)item
{
    [inputView hidden:YES];
}
- (void)inputView:(WMSInputView *)inputView didClickRightItem:(UIBarButtonItem *)item
{
    [inputView hidden:YES];
    
    NSInteger row = [inputView.pickerView selectedRowInComponent:0];
    _timeInterval = [self.pickerViewDataSource[row] integerValue];
    [self.tableView reloadData];
}

@end
