//
//  WMSActivityRemindViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSActivityRemindViewController.h"
//#import "WMSInputViewController.h"
#import "UIViewController+Tip.h"
#import "WMSAppDelegate.h"

#import "MBProgressHUD.h"
#import "WMSInputView.h"
#import "WMSWeekPicker.h"

#import "WMSActivityModel.h"
#import "WMSMyAccessory.h"
#import "WMSDataManager.h"
#import "WMSRemindHelper.h"
#import "WMSFileMacro.h"
#import "WMSConstants.h"

#define SECTION_NUMBER                      1
#define SECTION_FOOTER_HEIGHT               60.f
#define SECTION_HEADER_HEIGHT               40

#define PICKER_VIEW_COMPONENT_NUMBER        1
#define PICKER_VIEW_COMPONENT_WIDTH         ScreenWidth
#define PICKER_VIEW_ROW_NUMBER              24

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

@interface WMSActivityRemindViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WMSInputViewDelegate,WMSWeekPickerDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) UISwitch *cellSwitch;
@property (strong,nonatomic) WMSInputView *myInputView;
@property (strong,nonatomic) WMSWeekPicker *weekPicker;
@property (strong,nonatomic) NSArray *textArray;
@property (strong,nonatomic) NSArray *detailTextArray;
@property (strong,nonatomic) NSArray *intervalValueArray;
@end

@implementation WMSActivityRemindViewController
{
    BOOL activityStatus;
    int activityStartHour;
    int activityStartMinute;
    int activityEndHour;
    int activityEndMinute;
    int activityInterval;
    NSArray *activityRepeats;
    
    WMSActivityModel *_oldActivityModel;
}

#pragma mark - Getter
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
- (WMSInputView *)myInputView
{
    if (!_myInputView) {
        _myInputView= [[WMSInputView alloc] initWithLeftItemTitle:NSLocalizedString(@"Cancel", nil) RightItemTitle:NSLocalizedString(@"Confirm",nil)];
        _myInputView.pickerView.backgroundColor = [UIColor whiteColor];
        _myInputView.pickerView.delegate = self;
        _myInputView.pickerView.dataSource = self;
        _myInputView.delegate = self;
        [_myInputView hidden:NO];
    }
    return _myInputView;
}
- (WMSWeekPicker *)weekPicker
{
    if (!_weekPicker) {
        CGSize size = CGSizeMake(ScreenWidth, 50.f);
        CGPoint or = CGPointMake(0, 5.f);
        CGRect frame = (CGRect){or,size};
        _weekPicker = [[WMSWeekPicker alloc] initWithFrame:frame];
        _weekPicker.delegate = self;
    }
    return _weekPicker;
}
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = [[NSArray alloc] initWithObjects:
                      NSLocalizedString(@"Remind",nil),
                      NSLocalizedString(@"Start",nil),
                      NSLocalizedString(@"Finish",nil),
                      NSLocalizedString(@"Interval",nil),
                      NSLocalizedString(@"Repeat",nil),
                      nil];
    }
    return _textArray;
}
- (NSArray *)detailTextArray
{
    _detailTextArray = nil;
    if (!_detailTextArray) {
        NSString *strStartTime = [NSString stringWithFormat:@"%02d:%02d",(int)activityStartHour,(int)activityStartMinute];
        NSString *strEndTime = [NSString stringWithFormat:@"%02d:%02d",(int)activityEndHour,(int)activityEndMinute];
        NSString *strInterval = [NSString stringWithFormat:@"%d %@",(int)activityInterval,NSLocalizedString(@"Minutes clock",nil)];
        NSString *strRepeats = [WMSRemindHelper descriptionOfRepeats:activityRepeats];
        
        _detailTextArray = @[@"",strStartTime,strEndTime,strInterval,strRepeats];
    }
    return _detailTextArray;
}
- (NSArray *)intervalValueArray
{
    if (!_intervalValueArray) {
        _intervalValueArray = @[@(DEFAULT_ACTIVITY_INTERVAL),
                                @(30),
                                @(45),
                                @(60),
                                @(75),
                                @(90),
                                @(105),
                                @(120),
                                ];
    }
    return _intervalValueArray;
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
    
    [self setupValue];
    [self setupView];
    [self setupNavBarView];
    [self setupTableView];
    [self setupWeekPicker];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"WMSActivityRemindViewController dealloc");
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.navigationController.delegate = nil;
}

#pragma mark - Setup
- (void)setupView
{
    [self.view addSubview:self.myInputView];
    [self.cellSwitch setOn:activityStatus];
}
- (void)setupNavBarView
{
    self.title = NSLocalizedString(@"Activities remind", nil);
    self.navigationController.navigationBarHidden = NO;
    SetControllerKeepExtendedLayout();
    UIBarButtonItem *leftItem = [UIBarButtonItem itemWithImageName:@"back_btn_a.png" highImageName:@"back_btn_b.png" target:self action:@selector(backAction:)];
    UIBarButtonItem *item1 = [UIBarButtonItem itemWithTitle:NSLocalizedString(@"同步", nil) font:Font_System(18.0) size:SYNC_BUTTON_SIZE target:self action:@selector(syncSettingAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = item1;
}
- (void)setupTableView
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
}
- (void)setupWeekPicker
{
    self.weekPicker.componentStates = activityRepeats;
    [self.weekPicker reloadView];
}
- (void)setupValue
{
    NSArray *activities = [WMSDataManager loadActivityRemind];
    WMSActivityModel *activity = nil;
    if (activities && activities.count > 0) {
        activity = activities[0];
    } else {
        activity = [[WMSActivityModel alloc] initWithStatus:NO startHour:DEFAULT_HOUR startMinute:DEFAULT_MINUTE endHour:DEFAULT_HOUR endMinute:DEFAULT_MINUTE intervalMinute:DEFAULT_ACTIVITY_INTERVAL repeats:@[@(NO),@(NO),@(NO),@(NO),@(NO),@(NO),@(NO)]];
    }
    activityStatus = activity.status;
    activityStartHour = (int)activity.startHour;
    activityStartMinute = (int)activity.startMinute;
    activityEndHour = (int)activity.endHour;
    activityEndMinute = (int)activity.endMinute;
    activityInterval = (int)activity.intervalMinute;
    activityRepeats = activity.repeats;
    _oldActivityModel = activity;
}

- (void)setActivityRemind
{
    WMSActivityModel *model = [[WMSActivityModel alloc] initWithStatus:activityStatus startHour:activityStartHour startMinute:activityStartMinute endHour:activityEndHour endMinute:activityEndMinute intervalMinute:activityInterval repeats:activityRepeats];
    NSArray *repeats = [WMSRemindHelper repeatsWithArray:model.repeats];
    
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    //设置提醒成功
    [bleControl.settingProfile setSportRemindWithStatus:model.status startHour:model.startHour startMinute:model.startMinute endHour:model.endHour endMinute:model.endMinute intervalMinute:model.intervalMinute repeats:repeats completion:^(BOOL success)
    {
        DEBUGLog(@"设置提醒%@",success?@"成功":@"失败");
        [self showTip:NSLocalizedString(@"设置活动提醒成功", nil)];
        [WMSDataManager savaActivityRemind:@[model]];
        _oldActivityModel = model;
    }];
}

- (BOOL)checkoutTime 
{
    //将开始，结束时间都转成距离00:00的秒数，来比较时间先后
    int startSeconds = activityStartHour*60*60+activityStartMinute*60;
    int endSeconds = activityEndHour*60*60+activityEndMinute*60;
    return (endSeconds>startSeconds?YES:NO);
}

#pragma mark - Action
- (void)backAction:(id)sender {
    WMSActivityModel *model = [[WMSActivityModel alloc] initWithStatus:activityStatus startHour:activityStartHour startMinute:activityStartMinute endHour:activityEndHour endMinute:activityEndMinute intervalMinute:activityInterval repeats:activityRepeats];
    BOOL res = [model isEqual:_oldActivityModel];
    if (res == NO) {
        NSString *message = NSLocalizedString(@"您的活动提醒已修改，尚未同步到手表，是否同步?", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        [alert show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)syncSettingAction:(id)sender {
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    BOOL isBind = [WMSMyAccessory isBindAccessory];
    BOOL isConnected = [bleControl isConnected];
    BOOL result = [self checkoutWithIsBind:isBind isConnected:isConnected];
    if (result == NO) {
        return;
    }
    if ([self checkoutTime] == NO) {
        [self showTip:NSLocalizedString(@"结束时间必须晚于开始时间", nil)];
    } else {
        [self setActivityRemind];
    }
}
- (void)switchBtnValueChanged:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    activityStatus = sw.on;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//NO
        [self.navigationController popViewControllerAnimated:YES];
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
    return [self.textArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)indexPath.section,(int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [self.textArray objectAtIndex:indexPath.row];
        [cell.contentView addSubview:self.cellSwitch];
        return cell;
    }
    cell.textLabel.text = [self.textArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.detailTextArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = Font_System(12.0);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == RepeatCell) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_HEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
    CGRect frame = CGRectMake(0, height-30, ScreenWidth, 30);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.font = Font_System(12.0);
    titleLabel.numberOfLines = -1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"如果您坐的时间过长，手表会轻微震动，提醒您活动一下", nil);
    UIView *myView = [[UIView alloc] init];
    [myView addSubview:titleLabel];
    return myView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.weekPicker;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger selectRow = 0;
    switch (indexPath.row) {
        case StartTimeCell:
        {
            if (activityStartHour < PICKER_VIEW_ROW_NUMBER) {
                selectRow = activityStartHour;
            }
            break;
        }
        case FinishTimeCell:
        {
            if (activityEndHour < PICKER_VIEW_ROW_NUMBER) {
                selectRow = activityEndHour;
            }
            break;
        }
        case IntervalTimeCell:
        {
            NSUInteger i = [self.intervalValueArray indexOfObject:@(activityInterval)];
            if (i < [self.intervalValueArray count]) {
                selectRow = i;
            }
            break;
        }
        default:
            return;
    }
    [self.myInputView show:YES forView:cell];
    [self.myInputView.pickerView selectRow:selectRow inComponent:0 animated:NO];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return PICKER_VIEW_COMPONENT_NUMBER;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    UIResponder *responder = [self.myInputView responder];
    if (![responder isKindOfClass:[UITableViewCell class]]) {
        return 0;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responder];
    switch (indexPath.row) {
        case StartTimeCell:
        case FinishTimeCell:
            return PICKER_VIEW_ROW_NUMBER;
        case IntervalTimeCell:
            return [self.intervalValueArray count];
        default:
            break;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return PICKER_VIEW_COMPONENT_WIDTH;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UIResponder *responder = [self.myInputView responder];
    if (![responder isKindOfClass:[UITableViewCell class]]) {
        return nil;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responder];
    switch (indexPath.row) {
        case StartTimeCell:
        case FinishTimeCell:
            return [NSString stringWithFormat:@"%d",(int)row];
        case IntervalTimeCell:
        {
            int value = [self.intervalValueArray[row] intValue];
            return [NSString stringWithFormat:@"%d",value];
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - WMSInputViewDelegate
- (void)inputView:(WMSInputView *)inputView forView:(UIView *)responseView didClickRightItem:(UIBarButtonItem *)item
{
    if (![responseView isKindOfClass:[UITableViewCell class]]) {
        return ;
    }
    NSInteger row = [inputView.pickerView selectedRowInComponent:0];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responseView];
    switch (indexPath.row) {
        case StartTimeCell:
        {
            activityStartHour = (int)row;
            activityStartMinute = 0;
            break;
        }
        case FinishTimeCell:
        {
            activityEndHour = (int)row;
            activityEndMinute = 0;
            break;
        }
        case IntervalTimeCell:
        {
            activityInterval = [self.intervalValueArray[row] intValue];
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - WMSWeekPickerDelegate
- (void)weekPicker:(WMSWeekPicker *)weekPicker didClickComponent:(NSUInteger)index
{
    activityRepeats = weekPicker.componentStates;
    [self.tableView reloadData];
}

@end
