//
//  WMSActivityRemindViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSActivityRemindViewController.h"
#import "WMSInputViewController.h"
#import "WMSAppDelegate.h"
#import "WMSBluetooth.h"
#import "WMSActivityModel.h"

#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

#define SavaActivityFileName    @"activityModels.archiver"
#define ArchiverKey             @"ActivityModels"

@interface WMSActivityRemindViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
@property (strong,nonatomic) UISwitch *cellSwitch;
@property (strong,nonatomic) NSArray *textArray;
@property (strong,nonatomic) NSArray *detailTextArray;
@end

@implementation WMSActivityRemindViewController
{
    WMSInputViewController *_inputVC;
    
    BOOL activityStatus;
    int activityStartHour;
    int activityStartMinute;
    int activityEndHour;
    int activityEndMinute;
    int activityInterval;
    NSArray *activityRepeats;
}

#pragma mark - Getter
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
    if (!_detailTextArray) {
        NSString *strStartTime = [NSString stringWithFormat:@"%02d:%02d",(int)activityStartHour,(int)activityStartMinute];
        NSString *strEndTime = [NSString stringWithFormat:@"%02d:%02d",(int)activityEndHour,(int)activityEndMinute];
        
        NSString *strInterval = [NSString stringWithFormat:@"%d %@",(int)activityInterval,NSLocalizedString(@"Minutes clock",nil)];
        
        NSArray *arr = @[NSLocalizedString(@"一",nil),
                         NSLocalizedString(@"二",nil),
                         NSLocalizedString(@"三",nil),
                         NSLocalizedString(@"四",nil),
                         NSLocalizedString(@"五",nil),
                         NSLocalizedString(@"六",nil),
                         NSLocalizedString(@"七",nil)];
        NSString *strRepeats = @"";
        BOOL flag = YES;//标识是否每天都重复
        for (int i=0; i<[activityRepeats count]; i++) {
            BOOL var = [activityRepeats[i] boolValue];
            if (YES == var) {
                strRepeats = [strRepeats stringByAppendingString:@" "];
                strRepeats = [strRepeats stringByAppendingString:arr[i]];
            } else {flag = NO;}
        }
        if ([activityRepeats count] > 0 && flag) {
            strRepeats = NSLocalizedString(@"每天",nil);
        }
        
        _detailTextArray = @[@"",strStartTime,strEndTime,strInterval,strRepeats];
    }
    return _detailTextArray;
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
    
    self.labelTitle.text = NSLocalizedString(@"Activities remind",nil);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.navigationController.delegate = self;
    
    [self initView];
}
- (void)dealloc
{
    DEBUGLog(@"WMSActivityRemindViewController dealloc");
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.navigationController.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    NSArray *array = [self loadActivityRemind];
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    NSString *identifier = bleControl.connectedPeripheral.UUIDString;
    WMSActivityModel *model = nil;
    for (NSDictionary *dicObj in array) {
        if (identifier == nil) {
            identifier = @"";
        }
        model = [dicObj objectForKey:identifier];
    }
    activityStatus = model.status;
    activityStartHour = (int)model.startHour;
    activityStartMinute = (int)model.startMinute;
    activityEndHour = (int)model.endHour;
    activityEndMinute = (int)model.endMinute;
    activityInterval = (int)model.intervalMinute;
    activityRepeats = model.repeats;
    
    self.cellSwitch.on = activityStatus;
}

//
- (NSString *)filePath:(NSString *)fileName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSArray *)loadActivityRemind
{
    NSString *fileName = [self filePath:SavaActivityFileName];
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    if ([data length] > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        NSArray *clockArray = [unArchiver decodeObjectForKey:ArchiverKey];
        [unArchiver finishDecoding];
        
        return clockArray;
    }
    return nil;
}

- (void)savaActivityModel:(WMSActivityModel *)model
{
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    NSString *identifier = bleControl.connectedPeripheral.UUIDString;
    
    int index = [self isExistForBleIdentifier:identifier];//是否已存在这个identifier
    NSArray *savedData = [self loadActivityRemind];
    
    NSDictionary *dictionary = @{identifier:model};
    NSMutableArray *writeData = [NSMutableArray arrayWithArray:savedData];
    if (index >= 0) {//存在，则替换成新的数据
        [writeData replaceObjectAtIndex:index withObject:dictionary];
    } else {//不存在，则添加新的数据，保留旧的数据
        [writeData addObject:dictionary];
    }
    
    //coding
    NSString *fileName = [self filePath:SavaActivityFileName];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:writeData forKey:ArchiverKey];
    [archiver finishEncoding];
    [data writeToFile:fileName atomically:YES];
}

- (int)isExistForBleIdentifier:(NSString *)identifier
{
    if (identifier == nil) {
        return -1;
    }
    
    int index = -1;
    NSArray *savedData = [self loadActivityRemind];
    for (int i=0; i<[savedData count]; i++) {
        NSDictionary *dicObj = savedData[i];
        NSArray *keys = [dicObj allKeys];
        NSString *key = @"";
        if (keys.count > 0) {
            key = [keys objectAtIndex:0];
        }
        
        if ([identifier isEqualToString:key]) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)setActivityRemind
{
    WMSActivityModel *model = [[WMSActivityModel alloc] initWithStatus:activityStatus startHour:activityStartHour startMinute:activityStartMinute endHour:activityEndHour endMinute:activityEndMinute intervalMinute:activityInterval repeats:activityRepeats];
    
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    
    //设置提醒成功
    [bleControl.settingProfile setSportRemindWithStatus:YES startHour:model.startHour startMinute:model.startMinute endHour:model.endHour endMinute:model.endMinute intervalMinute:model.intervalMinute repeats:model.repeats completion:^(BOOL success)
    {
        DEBUGLog(@"设置提醒%@",success?@"成功":@"失败");
        [self savaActivityModel:model];
    }];
}


#pragma mark - Action
- (IBAction)backAction:(id)sender {
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    if ([bleControl isConnected]) {
        [self setActivityRemind];
    }
    
    self.navigationController.delegate = nil;//一定要加入这条语句
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)switchBtnValueChanged:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    activityStatus = sw.on;
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
    
    WMSInputViewController *vc = [[WMSInputViewController alloc] init];
    vc.selectIndex = (int)indexPath.row;
    vc.VCTitle = self.textArray[indexPath.row];
    _inputVC = vc;
    
    switch (indexPath.row) {
        case 1:
            _inputVC.startTimeHour = activityStartHour;
            _inputVC.startTimeMinute = activityStartMinute;
            break;
        case 2:
            _inputVC.finishTimeHour = activityEndHour;
            _inputVC.finishTimeMinute = activityEndMinute;
            break;
        case 3:
            _inputVC.intervalMinute = activityInterval;
            break;
        case 4:
            if (activityRepeats) {
               _inputVC.selectedWeekArray = [NSMutableArray arrayWithArray:activityRepeats]; 
            }
            break;
            
        default:
            break;
    }
    
    
    [self.navigationController pushViewController:vc animated:NO];
}


#pragma mark - --UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self == viewController && _inputVC) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_inputVC.selectIndex inSection:0]];
        
        if (_inputVC.selectIndex == StartTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d",_inputVC.startTimeHour,_inputVC.startTimeMinute];
            
            activityStartHour = _inputVC.startTimeHour;
            activityStartMinute = _inputVC.startTimeMinute;
            
        } else if (_inputVC.selectIndex == FinishTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d",_inputVC.finishTimeHour,_inputVC.finishTimeMinute];
            
            activityEndHour = _inputVC.finishTimeHour;
            activityEndMinute = _inputVC.finishTimeMinute;
            
        } else if (_inputVC.selectIndex == IntervalTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@",_inputVC.intervalMinute,NSLocalizedString(@"Minutes clock",nil)];
            
            activityInterval = _inputVC.intervalMinute;
            
        } else if (_inputVC.selectIndex == RepeatCell) {
            NSArray *arr = @[NSLocalizedString(@"一",nil),
                             NSLocalizedString(@"二",nil),
                             NSLocalizedString(@"三",nil),
                             NSLocalizedString(@"四",nil),
                             NSLocalizedString(@"五",nil),
                             NSLocalizedString(@"六",nil),
                             NSLocalizedString(@"七",nil)];
            NSString *str = @"";
            BOOL flag = YES;//标识是否每天都重复
            for (int i=0; i<_inputVC.selectedWeekArray.count; i++) {
                BOOL var = [_inputVC.selectedWeekArray[i] boolValue];
                if (YES == var) {
                    str = [str stringByAppendingString:@" "];
                    str = [str stringByAppendingString:arr[i]];
                } else {flag = NO;}
            }
            if (flag) {
                str = NSLocalizedString(@"每天",nil);
            }
            cell.detailTextLabel.text = str;
            
            activityRepeats = _inputVC.selectedWeekArray;
            
        }
        
        _inputVC = nil;
    }
}

@end
