//
//  WMSSmartClockViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSmartClockViewController.h"
#import "WMSSelectValueViewController.h"
#import "WMSAppDelegate.h"
#import "WMSBluetooth.h"
#import "WMSAlarmClockModel.h"

#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

#define DefaultAlarmClockID 1
#define SavaAlramClockFileName @"alramClocks.plist"

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

@interface WMSSmartClockViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
{

}
@property (strong,nonatomic) UISwitch *cellSwitch;
@property (strong,nonatomic) NSArray *textArray;
@property (strong,nonatomic) NSArray *detailTextArray;

@property (strong,nonatomic) WMSAlarmClockModel *alarmClockModel;

@end

@implementation WMSSmartClockViewController
{
    WMSSelectValueViewController *_selectValueVC;
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
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = [[NSArray alloc] initWithObjects:
                                NSLocalizedString(@"Alarm clock",nil),
                                NSLocalizedString(@"Alarm clock time",nil),
                                NSLocalizedString(@"Smart sleep Windows",nil),
                                NSLocalizedString(@"Repeat",nil),
                                nil];
    }
    return _textArray;
}
- (NSArray *)detailTextArray
{
    if (!_detailTextArray) {
        NSString *strStartTime = [NSString stringWithFormat:@"%02d:%02d",(int)self.alarmClockModel.startHour,(int)self.alarmClockModel.startMinute];
        NSString *strSnooze = [NSString stringWithFormat:@"%d %@",(int)self.alarmClockModel.snoozeMinute,NSLocalizedString(@"Minutes clock",nil)];
        
        NSArray *arr = @[NSLocalizedString(@"一",nil),
                         NSLocalizedString(@"二",nil),
                         NSLocalizedString(@"三",nil),
                         NSLocalizedString(@"四",nil),
                         NSLocalizedString(@"五",nil),
                         NSLocalizedString(@"六",nil),
                         NSLocalizedString(@"七",nil)];
        NSString *strRepeats = @"";
        for (int i=0; i<[self.alarmClockModel.repeats count]; i++) {
            BOOL var = [self.alarmClockModel.repeats[i] boolValue];
            if (YES == var) {
                strRepeats = [strRepeats stringByAppendingString:@" "];
                strRepeats = [strRepeats stringByAppendingString:arr[i]];
            }
        }
        
        _detailTextArray = @[@"",strStartTime,strSnooze,strRepeats];
    }
    return _detailTextArray;
}

- (WMSAlarmClockModel *)alarmClockModel
{
    if (!_alarmClockModel) {
        _alarmClockModel = [[self loadAlarmClock] objectAtIndex:0];
        if (_alarmClockModel == nil) {
            _alarmClockModel = [[WMSAlarmClockModel alloc] init];
        }
    }
    return _alarmClockModel;
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
    
    self.labelTitle.text = NSLocalizedString(@"Smart alarm clock",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.navigationController.delegate = self;
    
    
    
    [self initView];
}

- (void)dealloc
{
    DEBUGLog(@"WMSSmartClockViewController dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.cellSwitch.on = self.alarmClockModel.status;
}

//
- (NSString *)filePath:(NSString *)fileName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSArray *)loadAlarmClock
{
    NSArray *clockArray = [NSArray arrayWithContentsOfFile:[self filePath:SavaAlramClockFileName]];
    return clockArray;
}

- (void)savaAlarmClock:(WMSAlarmClockModel *)model
{
    NSArray *clockArray = @[model];
    [clockArray writeToFile:[self filePath:SavaAlramClockFileName] atomically:YES];
}


- (void)setAlarmClock
{
    NSUInteger hour = self.alarmClockModel.startHour;
    NSUInteger minute = self.alarmClockModel.startMinute;
    BOOL status = self.alarmClockModel.status;
    NSUInteger snooze = self.alarmClockModel.snoozeMinute;
    Byte repeats[7] = {0};
    NSUInteger length = 7;
    for (int i=0; i<[self.alarmClockModel.repeats count]; i++) {
        Byte b = (Byte)self.alarmClockModel.repeats[i];
        if (i < 7) {
            repeats[i] = b;
        }
    }
    
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    [bleControl.settingProfile setAlarmClockWithId:DefaultAlarmClockID withHour:hour withMinute:minute withStatus:status withRepeat:NULL withLength:length withSnoozeMinute:snooze withCompletion:^(BOOL success)
     {
         DEBUGLog(@"设置活动提醒%@",success?@"成功":@"失败");
         [self savaAlarmClock:self.alarmClockModel];
     }];
}


#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self setAlarmClock];
    
    self.navigationController.delegate = nil;//一定要加入这条语句
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)switchBtnValueChanged:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    self.alarmClockModel.status = sw.on;
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
    cell.detailTextLabel.font = [UIFont fontWithName:@"System" size:12.f];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WMSSelectValueViewController *VC = [[WMSSelectValueViewController alloc] init];
    VC.selectIndex = indexPath.row;
    VC.VCTitle = [self.textArray objectAtIndex:indexPath.row];
    _selectValueVC = VC;
    
    if (indexPath.row == 1) {
        VC.alarmClockHour = self.alarmClockModel.startHour;
        VC.alarmClockMinute = self.alarmClockModel.startMinute;
    } else if (indexPath.row == 2) {
        VC.smartSleepMinute = self.alarmClockModel.snoozeMinute;
    } else if (indexPath.row == 3) {
        if (self.alarmClockModel.repeats) {
            VC.selectedWeekArray = [NSMutableArray arrayWithArray:self.alarmClockModel.repeats];
        }
    }
    
    [self.navigationController pushViewController:VC animated:NO];
    
}


#pragma mark - --UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self && _selectValueVC) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectValueVC.selectIndex inSection:0]];
        
        
        if (_selectValueVC.selectIndex == SmartClockTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d",_selectValueVC.alarmClockHour,_selectValueVC.alarmClockMinute];
            
            self.alarmClockModel.startHour = _selectValueVC.alarmClockHour;
            self.alarmClockModel.startMinute = _selectValueVC.alarmClockMinute;
            
        } else if (_selectValueVC.selectIndex == SmartClockSleepTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@",_selectValueVC.smartSleepMinute,NSLocalizedString(@"Minutes clock",nil)];
            
            self.alarmClockModel.snoozeMinute = _selectValueVC.smartSleepMinute;
            
        } else if (_selectValueVC.selectIndex == SmartClockRepeatCell) {
            NSArray *arr = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七"];
            NSString *str = @"";
            for (int i=0; i<_selectValueVC.selectedWeekArray.count; i++) {
                BOOL var = [_selectValueVC.selectedWeekArray[i] boolValue];
                if (YES == var) {
                    str = [str stringByAppendingString:@" "];
                    str = [str stringByAppendingString:arr[i]];
                }
            }
            cell.detailTextLabel.text = str;
            
            self.alarmClockModel.repeats = _selectValueVC.selectedWeekArray;
            
        }
        
        _selectValueVC = nil;
    }
}

@end
