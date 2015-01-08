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

#define SECTION_NUMBER                  1
#define SECTION_FOOTER_HEIGHT           1
#define SECTION_HEADER_HEIGHT           40

#define PICKER_VIEW_COMPONENT_NUMBER        1
#define PICKER_VIEW_COMPONENT_WIDTH         ScreenWidth
#define PICKER_VIEW_ROW_NUMBER              24

#define DAY_HOURS                           24
#define DAY_MINUTES                         60

#define DefaultAlarmClockID     1
#define ArchiverKey             @"alarmClockModels"

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

@interface WMSSmartClockViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WMSInputViewDelegate,WMSWeekPickerDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) UISwitch *cellSwitch;
@property (strong,nonatomic) WMSInputView *myInputView;
@property (strong,nonatomic) WMSWeekPicker *weekPicker;
@property (strong,nonatomic) NSArray *textArray;
@property (strong,nonatomic) NSArray *detailTextArray;
@property (strong,nonatomic) NSArray *intervalValueArray;
@end

@implementation WMSSmartClockViewController
{
    BOOL alarmClockStatus;
    int alarmClockHour;
    int alarmClockMimute;
    int alarmClockSnooze;
    NSArray *alarmClockRepeats;
    
    WMSAlarmClockModel *_oldAlarmClockModel;
}

#pragma mark - Property Getter Method
- (UISwitch *)cellSwitch
{
    if (!_cellSwitch) {
        _cellSwitch = [[UISwitch alloc] initWithFrame:UISwitch_Frame];
        [_cellSwitch setOn:YES animated:NO];
        [_cellSwitch addTarget:self action:@selector(switchBtnValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_cellSwitch setOnTintColor:UIColorFromRGBAlpha(0x00D5E1, 1)];
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
        CGRect tableViewFrame = self.tableView.frame;
        CGPoint or = CGPointMake(0, tableViewFrame.size.height+tableViewFrame.origin.y+10);
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
                                NSLocalizedString(@"Alarm clock",nil),
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
        NSString *strStartTime = [NSString stringWithFormat:@"%02d:%02d",alarmClockHour,alarmClockMimute];
        NSString *strSnooze = [NSString stringWithFormat:@"%d %@",alarmClockSnooze,NSLocalizedString(@"Minutes clock",nil)];
        NSString *strRepeats = [WMSRemindHelper descriptionOfRepeats:alarmClockRepeats];
        _detailTextArray = @[@"",strStartTime,strSnooze,strRepeats];
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
    
    [self.view addSubview:self.weekPicker];
    [self.view addSubview:self.myInputView];
    [self setupNavBarView];
    [self setupTableView];
    _oldAlarmClockModel = [self loadData];
    [self setupWeekPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"WMSSmartClockViewController dealloc");
}

- (void)setupNavBarView
{
    [self.buttonBack setTitle:@"" forState:UIControlStateNormal];
    [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.buttonSync setTitle:NSLocalizedString(@"同步", nil) forState:UIControlStateNormal];
    [self.buttonSync setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonSync.titleLabel setFont:Font_System(15.0)];
    
    self.labelTitle.text = NSLocalizedString(@"Smart alarm clock",nil);
    self.view.backgroundColor = [UIColor whiteColor];
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
    self.weekPicker.componentStates = alarmClockRepeats;
    [self.weekPicker reloadView];
}
- (WMSAlarmClockModel *)loadData
{
    WMSAlarmClockModel *model = [self loadAlarmClock];
    if (model == nil) {
        alarmClockStatus = YES;
        alarmClockHour = DEFAULT_START_HOUR;
        alarmClockMimute = DEFAULT_START_MINUTE;
        alarmClockSnooze = DEFAULT_SNOOZE_MINUTE;
        alarmClockRepeats = @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)];
    } else {
        alarmClockStatus = model.status;
        alarmClockHour = model.startHour;
        alarmClockMimute = model.startMinute;
        alarmClockSnooze = model.snoozeMinute;
        alarmClockRepeats = model.repeats;
    }
    self.cellSwitch.on = alarmClockStatus;
    if (model == nil) {
        return [[WMSAlarmClockModel alloc] initWithStatus:alarmClockStatus startHour:alarmClockHour startMinute:alarmClockMimute snoozeMinute:alarmClockSnooze repeats:alarmClockRepeats];
    }
    return model;
}

- (WMSAlarmClockModel *)loadAlarmClock
{
    NSString *fileName = FilePath(FILE_ALRAM_CLOCK);
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    if ([data length] > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        WMSAlarmClockModel *model= [unArchiver decodeObjectForKey:ArchiverKey];
        [unArchiver finishDecoding];
        
        return model;
    }
    return nil;
}

- (void)savaAlarmClock:(WMSAlarmClockModel *)model
{
    //coding
    NSString *fileName = FilePath(FILE_ALRAM_CLOCK);
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:model forKey:ArchiverKey];
    [archiver finishEncoding];
    [data writeToFile:fileName atomically:YES];
}

- (void)setAlarmClock
{
    WMSAlarmClockModel *model = [[WMSAlarmClockModel alloc] initWithStatus:alarmClockStatus startHour:alarmClockHour startMinute:alarmClockMimute snoozeMinute:alarmClockSnooze repeats:alarmClockRepeats];
    NSArray *array = [WMSRemindHelper repeatsWithArray:model.repeats];
    Byte repeats[7] = {0};
    NSUInteger length = 7;
    for (int i=0; i<[array count]; i++) {
        Byte b = (Byte)array[i];
        if (i < length) {
            repeats[i] = b;
        }
    }
    
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    [bleControl.settingProfile setAlarmClockWithId:DefaultAlarmClockID withHour:model.startHour withMinute:model.startMinute withStatus:model.status withRepeat:repeats withLength:length withSnoozeMinute:model.snoozeMinute withCompletion:^(BOOL success)
     {
         DEBUGLog(@"设置闹钟%@",success?@"成功":@"失败");
         [self showTip:NSLocalizedString(@"设置闹钟成功", nil)];
         [self savaAlarmClock:model];
         _oldAlarmClockModel = model;
     }];
}


#pragma mark - Action
- (IBAction)backAction:(id)sender {
    WMSAlarmClockModel *model = [[WMSAlarmClockModel alloc] initWithStatus:alarmClockStatus startHour:alarmClockHour startMinute:alarmClockMimute snoozeMinute:alarmClockSnooze repeats:alarmClockRepeats];
    BOOL res = [model isEqual:_oldAlarmClockModel];
    if (res == NO) {
        NSString *message = NSLocalizedString(@"您的闹钟已修改，尚未同步到手表，是否同步?", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        [alert show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)syncSettingAction:(id)sender {
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    BOOL isBind = [WMSMyAccessory isBindAccessory];
    BOOL isConnected = [bleControl isConnected];
    BOOL result = [self checkoutWithIsBind:isBind isConnected:isConnected];
    if (result == NO) {
        return;
    }
    [self setAlarmClock];
}
- (void)switchBtnValueChanged:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    alarmClockStatus = sw.on;
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
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    
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
    titleLabel.text = NSLocalizedString(@"添加闹钟，手表会在指定的时间将您唤醒", nil);
    UIView *myView = [[UIView alloc] init];
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
    
    switch (indexPath.row) {
        case SmartClockTimeCell:
        {
            NSUInteger hour = 0;
            NSUInteger minute = 0;
            if (alarmClockHour < DAY_HOURS) {
                hour = alarmClockHour;
            }
            if (alarmClockMimute < DAY_MINUTES) {
                minute = alarmClockMimute;
            }
            [self.myInputView show:YES forView:cell];
            [self.myInputView.pickerView selectRow:hour inComponent:0 animated:NO];
            [self.myInputView.pickerView selectRow:minute inComponent:1 animated:NO];
            break;
        }
        case SmartClockSleepTimeCell:
        {
            NSUInteger row = 0;
            NSUInteger i = [self.intervalValueArray indexOfObject:@(alarmClockSnooze)];
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
            alarmClockHour = (int)hour;
            alarmClockMimute = (int)minute;
            break;
        }
        case SmartClockSleepTimeCell:
        {
            NSInteger row = [inputView.pickerView selectedRowInComponent:0];
            alarmClockSnooze = [self.intervalValueArray[row] intValue];
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
    alarmClockRepeats = weekPicker.componentStates;
    [self.tableView reloadData];
}

@end
