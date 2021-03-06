//
//  WMSSmartClockViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSmartClockViewController.h"
//#import "WMSSelectValueViewController.h"
#import "UIViewController+Tip.h"
#import "WMSAppDelegate.h"

#import "MBProgressHUD.h"
#import "WMSInputView.h"
#import "WMSWeekPicker.h"

#import "WMSAlarmClockModel.h"
#import "WMSMyAccessory.h"

#import "WMSRemindHelper.h"
#import "WMSFileMacro.h"

#define SECTION_FOOTER_HEIGHT               60.f
#define SECTION_HEADER_HEIGHT               0.1//40

#define PICKER_VIEW_COMPONENT_NUMBER        1
#define PICKER_VIEW_COMPONENT_WIDTH         ScreenWidth
#define PICKER_VIEW_ROW_NUMBER              24

#define DAY_HOURS                           24
#define DAY_MINUTES                         60

@interface WMSSmartClockViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WMSInputViewDelegate,WMSWeekPickerDelegate>
@property (strong,nonatomic) WMSInputView *myInputView;
@property (strong,nonatomic) WMSWeekPicker *weekPicker;
@property (strong,nonatomic) NSArray *textArray;
@property (strong,nonatomic) NSArray *detailTextArray;
@property (strong,nonatomic) NSArray *intervalValueArray;
@end

@implementation WMSSmartClockViewController
{
    WMSAlarmClockModel *_clock;
}

#pragma mark - Getter
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
                                NSLocalizedString(@"Start",nil),
                                NSLocalizedString(@"唤醒时段",nil),
                                NSLocalizedString(@"Repeat",nil),
                                nil];
    }
    return _textArray;
}
- (NSArray *)detailTextArray
{
    _detailTextArray = nil;
    if (!_detailTextArray) {
        NSString *strStartTime = [NSString stringWithFormat:@"%02d:%02d",self.clockModel.startHour, self.clockModel.startMinute];
        NSString *strSnooze = [NSString stringWithFormat:@"%d %@",self.clockModel.snoozeMinute,NSLocalizedString(@"Minutes clock",nil)];
        NSString *strRepeats = [WMSRemindHelper descriptionOfRepeats:self.clockModel.repeats];
        _detailTextArray = @[strStartTime,strSnooze,strRepeats];
    }
    return _detailTextArray;
}
- (NSArray *)intervalValueArray
{
    if (!_intervalValueArray) {
        _intervalValueArray = @[@(DEFAULT_SNOOZE_MINUTE),
                                @(20),
                                @(30),
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
    [self setupTableView];
    [self setupWeekPicker];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - Setup
- (void)setupView
{
    [self.view addSubview:self.myInputView];
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
    self.weekPicker.componentStates = self.clockModel.repeats;
    [self.weekPicker reloadView];
}
- (void)setupValue
{
    if (!_clockModel) {
        NSDate *date = [NSDate systemDate];
        NSArray *repeats = @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)];
        _clockModel = [[WMSAlarmClockModel alloc] initWithStatus:YES startHour:[NSDate hourOfDate:date] startMinute:[NSDate minuteOfDate:date] snoozeMinute:DEFAULT_SNOOZE_MINUTE repeats:repeats];
    }
    _clock = [[WMSAlarmClockModel alloc] initWithClock:self.clockModel];
    [self setClockModel:_clock];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.textArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.textArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.detailTextArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = Font_System(12.0);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == SmartClockRepeatCell) {
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
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.weekPicker;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
//    CGRect frame = CGRectMake(0, height-30, ScreenWidth, 30);
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
//    titleLabel.textColor=[UIColor blackColor];
//    titleLabel.font = Font_System(12.0);
//    titleLabel.numberOfLines = -1;
//    titleLabel.adjustsFontSizeToFitWidth = YES;
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = NSLocalizedString(@"添加闹钟，手表会在指定的时间将您唤醒", nil);
//    UIView *myView = [[UIView alloc] init];
//    [myView addSubview:titleLabel];
//    return myView;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case SmartClockTimeCell:
        {
            NSUInteger hour = 0;
            NSUInteger minute = 0;
            if (self.clockModel.startHour < DAY_HOURS) {
                hour = self.clockModel.startHour;
            }
            if (self.clockModel.startMinute < DAY_MINUTES) {
                minute = self.clockModel.startMinute;
            }
            [self.myInputView show:YES forView:cell];
            [self.myInputView.pickerView selectRow:hour inComponent:0 animated:NO];
            [self.myInputView.pickerView selectRow:minute inComponent:1 animated:NO];
            break;
        }
        case SmartClockSleepTimeCell:
        {
            NSUInteger row = 0;
            NSUInteger i = [self.intervalValueArray indexOfObject:@(self.clockModel.snoozeMinute)];
            if (i < [self.intervalValueArray count]) {
                row = i;
            }
            [self.myInputView show:YES forView:cell];
            [self.myInputView.pickerView selectRow:row inComponent:0 animated:NO];
            break;
        }
        default:
            return;
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    UIResponder *responder = [self.myInputView responder];
    if (![responder isKindOfClass:[UITableViewCell class]]) {
        return 0;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responder];
    switch (indexPath.row) {
        case SmartClockTimeCell:
            return 2;
        case SmartClockSleepTimeCell:
            return 1;
        default:
            break;
    }
    return 0;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    UIResponder *responder = [self.myInputView responder];
    if (![responder isKindOfClass:[UITableViewCell class]]) {
        return 0;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responder];
    switch (indexPath.row) {
        case SmartClockTimeCell:
        {
            if (component == 0) {
                return DAY_HOURS;
            } else {
                return DAY_MINUTES;
            }
        }
        case SmartClockSleepTimeCell:
            return [self.intervalValueArray count];
        default:
            break;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    UIResponder *responder = [self.myInputView responder];
    if (![responder isKindOfClass:[UITableViewCell class]]) {
        return 0;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responder];
    switch (indexPath.row) {
        case SmartClockTimeCell:
        {
            if (component == 0) {
                return 100.f;
            } else {
                return 100.f;
            }
        }
        case SmartClockSleepTimeCell:
            return PICKER_VIEW_COMPONENT_WIDTH;
        default:
            break;
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UIResponder *responder = [self.myInputView responder];
    if (![responder isKindOfClass:[UITableViewCell class]]) {
        return nil;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responder];
    switch (indexPath.row) {
        case SmartClockTimeCell:
            return [NSString stringWithFormat:@"%d",(int)row];
        case SmartClockSleepTimeCell:
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)responseView];
    switch (indexPath.row) {
        case SmartClockTimeCell:
        {
            NSInteger hour = [inputView.pickerView selectedRowInComponent:0];
            NSInteger minute = [inputView.pickerView selectedRowInComponent:1];
//            alarmClockHour = (int)hour;
//            alarmClockMimute = (int)minute;
            self.clockModel.startHour = hour;
            self.clockModel.startMinute = minute;
            break;
        }
        case SmartClockSleepTimeCell:
        {
            NSInteger row = [inputView.pickerView selectedRowInComponent:0];
            NSInteger snooze = [self.intervalValueArray[row] integerValue];
            self.clockModel.snoozeMinute = (NSUInteger)snooze;
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
    self.clockModel.repeats = weekPicker.componentStates;
    [self.tableView reloadData];
}

@end
