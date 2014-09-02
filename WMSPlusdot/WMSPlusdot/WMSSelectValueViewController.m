//
//  WMSSelectValueViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-26.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSelectValueViewController.h"
#import "WMSSmartClockViewController.h"

#define TableView_Frame ( CGRectMake(0, 66, self.view.bounds.size.width, self.view.bounds.size.height) )
#define DatePicker_Frame ( CGRectMake(0, (self.view.bounds.size.height-160)/2, 320, 160) )

#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

@interface WMSSelectValueViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIDatePicker *datePicker;

@property (nonatomic,strong) NSArray *smartSleepValueArray;
@property (nonatomic,strong) NSArray *weekArray;

@end

@implementation WMSSelectValueViewController

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
    }
    return _datePicker;
}
- (NSArray *)smartSleepValueArray
{
    if (!_smartSleepValueArray) {
        _smartSleepValueArray = [[NSArray alloc] initWithObjects:
                                                @(5),
                                                @(7),
                                                @(10),
                                                @(15),
                                                @(20),
                                                @(30),
                                                nil];
    }
    return _smartSleepValueArray;
}
- (NSArray *)weekArray
{
    if (!_weekArray) {
        _weekArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
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
    
    NSArray *arr = @[@(NO),@(NO),@(NO),@(NO),@(NO),@(NO),@(NO)];
    _selectedWeekArray = [[NSMutableArray alloc] initWithArray:arr];
    
    switch (self.selectIndex) {
        case SmartClockTimeCell:
        {
            [self.view addSubview:self.datePicker];
            //DEBUGLog(@"datePicker bounds:%f,%f",self.datePicker.bounds.size.width,self.datePicker.bounds.size.height);
            break;
        }
        case SmartClockSleepTimeCell:
        case SmartClockRepeatCell:
        {
            self.tableView.dataSource = self;
            self.tableView.delegate = self;
            self.tableView.scrollEnabled = NO;
            [self.view addSubview:self.tableView];
        }
            
        default:
            break;
    }
}

- (void)dealloc
{
    DEBUGLog(@"WMSSelectValueViewController dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    switch (self.selectIndex) {
        case SmartClockTimeCell:
        {
            NSDate *date = self.datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH";
            NSString *strHour = [dateFormatter stringFromDate:date];
            dateFormatter.dateFormat = @"mm";
            NSString *strMinute = [dateFormatter stringFromDate:date];
            DEBUGLog(@"time:[%02d:%02d]",[strHour integerValue],[strMinute integerValue]);
            _alarmClockHour = (int)[strHour integerValue];
            _alarmClockMinute = (int)[strMinute integerValue];
            break;
        }
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectIndex == SmartClockSleepTimeCell) {
        return [self.smartSleepValueArray count];
    } else if (self.selectIndex == SmartClockRepeatCell) {
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
    
    if (self.selectIndex == SmartClockSleepTimeCell) {
        int minute = (int)[[self.smartSleepValueArray objectAtIndex:indexPath.row] integerValue];
        cell.textLabel.text = [NSString stringWithFormat:@"%d %@",minute,NSLocalizedString(@"Minutes clock",nil)];
        
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        return cell;
    }
    
    if (self.selectIndex == SmartClockRepeatCell) {
        cell.textLabel.text = self.weekArray[indexPath.row];
        
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
    
    if (self.selectIndex == SmartClockSleepTimeCell) {
        for (int i=0; i<[self.smartSleepValueArray count]; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:path];//
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
        [checkedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        _smartSleepMinute = (int)[[self.smartSleepValueArray objectAtIndex:indexPath.row] integerValue];
        
        return;
    }
    
    if (self.selectIndex == SmartClockRepeatCell) {
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