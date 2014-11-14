//
//  WMSInputViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSInputViewController.h"
#import "WMSActivityRemindViewController.h"
#import "NSDate+Formatter.h"
#import "UIDatePicker+Time.h"

#define TableView_Frame ( CGRectMake(0, 66, self.view.bounds.size.width, self.view.bounds.size.height) )
#define DatePicker_Frame ( CGRectMake(0, (self.view.bounds.size.height-160)/2, 320, 160) )

#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

#define Array_Length    7

@interface WMSInputViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIDatePicker *datePicker;

@property (nonatomic,strong) NSArray *smartSleepValueArray;
@property (nonatomic,strong) NSArray *weekArray;
@end

@implementation WMSInputViewController
{
    int selected_index_intervals;
    int selected_indexs_repeats[Array_Length];
}

#pragma mark - Getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:TableView_Frame style:UITableViewStylePlain];
    }
    return _tableView;
}
- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:DatePicker_Frame];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        _datePicker.locale = [NSLocale systemLocale];
    }
    return _datePicker;
}
- (NSArray *)smartSleepValueArray
{
    if (!_smartSleepValueArray) {
        _smartSleepValueArray = [[NSArray alloc] initWithObjects:
                                 @(30),
                                 @(60),
                                 @(90),
                                 @(120),
                                 @(150),
                                 @(180),
                                 nil];
    }
    return _smartSleepValueArray;
}
- (NSArray *)weekArray
{
    if (!_weekArray) {
        _weekArray = @[NSLocalizedString(@"周一",nil),
                       NSLocalizedString(@"周二",nil),
                       NSLocalizedString(@"周三",nil),
                       NSLocalizedString(@"周四",nil),
                       NSLocalizedString(@"周五",nil),
                       NSLocalizedString(@"周六",nil),
                       NSLocalizedString(@"周日",nil)];
    }
    return _weekArray;
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
    
    [self.buttonBack setTitle:@"" forState:UIControlStateNormal];
    [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    
    self.labelTitle.text = self.VCTitle;
    
    if (_selectedWeekArray == nil) {
        NSArray *arr = @[@(NO),@(NO),@(NO),@(NO),@(NO),@(NO),@(NO)];
        _selectedWeekArray = [[NSMutableArray alloc] initWithArray:arr];
    }
    
    switch (self.selectIndex) {
        case StartTimeCell:
        {
            NSString *strDate = [NSString stringWithFormat:@"%02d:%02d",_startTimeHour,_startTimeMinute];
            NSDate *date = [NSDate dateFromString:strDate format:@"HH:mm"];
            [self.datePicker setPickerDate:date];
            [self.view addSubview:self.datePicker];
            break;
        }
        case FinishTimeCell:
        {
            NSString *strDate = [NSString stringWithFormat:@"%02d:%02d",_finishTimeHour,_finishTimeMinute];
            NSDate *date = [NSDate dateFromString:strDate format:@"HH:mm"];
            [self.datePicker setPickerDate:date];
            [self.view addSubview:self.datePicker];
            break;
        }
        case IntervalTimeCell:
        {
            int fg = -1;
            for (int i=0; i<[self.smartSleepValueArray count]; i++) {
                NSNumber *object = self.smartSleepValueArray[i];
                if (_intervalMinute == [object integerValue]) {
                    fg = i;
                    break;
                }
            }
            selected_index_intervals = fg;
            
            self.tableView.dataSource = self;
            self.tableView.delegate = self;
            self.tableView.scrollEnabled = NO;
            [self.view addSubview:self.tableView];
            break;
        }
        case RepeatCell:
        {
            memset(selected_indexs_repeats, 0, Array_Length);
            for (int i=0; i<[_selectedWeekArray count]; i++) {
                if (YES == [_selectedWeekArray[i] boolValue]) {
                    if (i < Array_Length) {
                        selected_indexs_repeats[i] = 1;
                    }
                }
            }
            self.tableView.dataSource = self;
            self.tableView.delegate = self;
            self.tableView.scrollEnabled = NO;
            [self.view addSubview:self.tableView];
        }
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"WMSInputViewController dealloc");
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    switch (self.selectIndex) {
        case StartTimeCell:
        case FinishTimeCell:
        {
            NSDate *date = self.datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH";
            NSString *strHour = [dateFormatter stringFromDate:date];
            dateFormatter.dateFormat = @"mm";
            NSString *strMinute = [dateFormatter stringFromDate:date];
            if (self.selectIndex == StartTimeCell) {
                _startTimeHour = [strHour intValue];
                _startTimeMinute = [strMinute intValue];
            } else if (self.selectIndex == FinishTimeCell) {
                _finishTimeHour = [strHour intValue];
                _finishTimeMinute = [strMinute intValue];
            }
            break;
        }
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectIndex == IntervalTimeCell) {
        return [self.smartSleepValueArray count];
    } else if (self.selectIndex == RepeatCell) {
        return [self.weekArray count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.selectIndex == IntervalTimeCell) {
        int minute = (int)[[self.smartSleepValueArray objectAtIndex:indexPath.row] integerValue];
        cell.textLabel.text = [NSString stringWithFormat:@"%d %@",minute,NSLocalizedString(@"Minutes clock",nil)];
        
        if (indexPath.row == selected_index_intervals) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    
    if (self.selectIndex == RepeatCell) {
        cell.textLabel.text = self.weekArray[indexPath.row];
        
        if (indexPath.row < Array_Length) {
            if (selected_indexs_repeats[indexPath.row] == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectIndex == IntervalTimeCell) {
        for (int i=0; i<[self.smartSleepValueArray count]; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:path];//
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
        [checkedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        _intervalMinute = [self.smartSleepValueArray[indexPath.row] intValue];
        
        return;
    }
    
    if (self.selectIndex == RepeatCell) {
        UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
        if (UITableViewCellAccessoryCheckmark == checkedCell.accessoryType) {
            checkedCell.accessoryType = UITableViewCellAccessoryNone;
            [_selectedWeekArray replaceObjectAtIndex:indexPath.row withObject:@(NO)];
        } else if (UITableViewCellAccessoryNone == checkedCell.accessoryType) {
            checkedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_selectedWeekArray replaceObjectAtIndex:indexPath.row withObject:@(YES)];
        }
        
        return;
    }
    
}

@end
