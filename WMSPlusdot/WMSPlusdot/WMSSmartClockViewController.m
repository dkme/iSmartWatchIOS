//
//  WMSSmartClockViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSmartClockViewController.h"
#import "WMSSelectValueViewController.h"
#import "UIViewController+Tip.h"
#import "WMSAppDelegate.h"

#import "MBProgressHUD.h"

#import "WMSAlarmClockModel.h"
#import "WMSMyAccessory.h"

#import "WMSRemindHelper.h"

#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

#define DefaultAlarmClockID 1
#define SavaAlramClockFileName @"alarmClockModels.archiver"
#define ArchiverKey            @"alarmClockModels"

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

@interface WMSSmartClockViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
{

}
@property (strong,nonatomic) UISwitch *cellSwitch;
@property (strong,nonatomic) NSArray *textArray;
@property (strong,nonatomic) NSArray *detailTextArray;

@end

@implementation WMSSmartClockViewController
{
    WMSSelectValueViewController *_selectValueVC;
    
    BOOL alarmClockStatus;
    int alarmClockHour;
    int alarmClockMimute;
    int alarmClockSnooze;
    NSArray *alarmClockRepeats;
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
        NSString *strStartTime = [NSString stringWithFormat:@"%02d:%02d",alarmClockHour,alarmClockMimute];
        NSString *strSnooze = [NSString stringWithFormat:@"%d %@",alarmClockSnooze,NSLocalizedString(@"Minutes clock",nil)];
        NSString *strRepeats = [WMSRemindHelper descriptionOfRepeats:alarmClockRepeats];
        _detailTextArray = @[@"",strStartTime,strSnooze,strRepeats];
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
    [self.buttonSync setTitle:NSLocalizedString(@"同步", nil) forState:UIControlStateNormal];
    [self.buttonSync setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonSync.titleLabel setFont:Font_System(17.0)];
    [self.buttonSync.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
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
    WMSAlarmClockModel *model = nil;
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    NSString *identifier = bleControl.connectedPeripheral.UUIDString;
    NSArray *array = [self loadAlarmClock];
    for (NSDictionary *dicObj in array) {
        if (identifier == nil) {
            identifier = @"";
        }
        model = [dicObj objectForKey:identifier];
    }
    if (model == nil) {
        alarmClockStatus = YES;
        alarmClockHour = DEFAULT_START_HOUR;
        alarmClockMimute = DEFAULT_START_MINUTE;
        alarmClockSnooze = DEFAULT_SNOOZE_MINUTE;
        alarmClockRepeats = 0;
    } else {
        alarmClockStatus = model.status;
        alarmClockHour = model.startHour;
        alarmClockMimute = model.startMinute;
        alarmClockSnooze = model.snoozeMinute;
        alarmClockRepeats = model.repeats;
    }
    self.cellSwitch.on = alarmClockStatus;
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
    NSString *fileName = [self filePath:SavaAlramClockFileName];
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    if ([data length] > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        NSArray *clockArray = [unArchiver decodeObjectForKey:ArchiverKey];
        [unArchiver finishDecoding];
        
        return clockArray;
    }
    return nil;
}

- (void)savaAlarmClock:(WMSAlarmClockModel *)model
{
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    NSString *identifier = bleControl.connectedPeripheral.UUIDString;
    
    int index = [self isExistForBleIdentifier:identifier];//是否已存在这个identifier
    NSArray *savedData = [self loadAlarmClock];
    NSString *key = (identifier==nil?@"":identifier);
    NSDictionary *dictionary = @{key:model};
    NSMutableArray *writeData = [NSMutableArray arrayWithArray:savedData];
    if (index >= 0) {//存在，则替换成新的数据
        //[writeData addObject:dictionary];
        [writeData replaceObjectAtIndex:index withObject:dictionary];
    } else {//不存在，则添加新的数据，保留旧的数据
        [writeData addObject:dictionary];
    }
    
    //coding
    NSString *fileName = [self filePath:SavaAlramClockFileName];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:writeData forKey:ArchiverKey];
    [archiver finishEncoding];
    [data writeToFile:fileName atomically:YES];
}

- (int)isExistForBleIdentifier:(NSString *)identifier
{
    if (identifier == nil) {
        //return NO;
        return -1;
    }
    
    //BOOL isExist = NO;//是否已存在这个identifier
    int index = -1;//下标
    NSArray *savedData = [self loadAlarmClock];
//    for (NSDictionary *dicObj in savedData) {
//        NSArray *keys = [dicObj allKeys];
//        NSString *key = @"";
//        if (keys.count > 0) {
//            key = [keys objectAtIndex:0];
//        }
//        
//        if ([identifier isEqualToString:key]) {
//            isExist = YES;
//            break;
//        }
//    }
    
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
    //return isExist;
}


- (void)setAlarmClock
{
    WMSAlarmClockModel *model = [[WMSAlarmClockModel alloc] initWithStatus:alarmClockStatus startHour:alarmClockHour startMinute:alarmClockMimute snoozeMinute:alarmClockSnooze repeats:alarmClockRepeats];
    Byte repeats[7] = {0};
    NSUInteger length = 7;
    for (int i=0; i<[model.repeats count]; i++) {
        Byte b = (Byte)model.repeats[i];
        if (i < length) {
            repeats[i] = b;
        }
    }
    
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    [bleControl.settingProfile setAlarmClockWithId:DefaultAlarmClockID withHour:model.startHour withMinute:model.startMinute withStatus:model.status withRepeat:repeats withLength:length withSnoozeMinute:model.snoozeMinute withCompletion:^(BOOL success)
     {
         DEBUGLog(@"设置闹钟%@",success?@"成功":@"失败");
//         MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//         hud.mode = MBProgressHUDModeText;
//         hud.yOffset = ScreenHeight/2.0-60;
//         hud.minSize = CGSizeMake(250.0, 60.0);
//         hud.labelText = NSLocalizedString(@"设置闹钟成功", nil);
//         [self.view addSubview:hud];
//         [hud showAnimated:YES whileExecutingBlock:^{
//             sleep(1);
//         } completionBlock:^{
//             [hud removeFromSuperview];
//         }];
         [self showTip:NSLocalizedString(@"设置闹钟成功", nil)];
         [self savaAlarmClock:model];
     }];
}


#pragma mark - Action
- (IBAction)backAction:(id)sender {
    WMSAlarmClockModel *model = [[WMSAlarmClockModel alloc] initWithStatus:alarmClockStatus startHour:alarmClockHour startMinute:alarmClockMimute snoozeMinute:alarmClockSnooze repeats:alarmClockRepeats];
    [self savaAlarmClock:model];
    
    self.navigationController.delegate = nil;//一定要加入这条语句
    [self.navigationController popViewControllerAnimated:YES];
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
        VC.alarmClockHour = alarmClockHour;
        VC.alarmClockMinute = alarmClockMimute;
    } else if (indexPath.row == 2) {
        VC.smartSleepMinute = alarmClockSnooze;
    } else if (indexPath.row == 3) {
        if (alarmClockRepeats) {
            VC.selectedWeekArray = [NSMutableArray arrayWithArray:alarmClockRepeats];
        }
    }
    
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark - --UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self && _selectValueVC) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectValueVC.selectIndex inSection:0]];
        
        
        if (_selectValueVC.selectIndex == SmartClockTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d",_selectValueVC.alarmClockHour,_selectValueVC.alarmClockMinute];
            
            alarmClockHour = _selectValueVC.alarmClockHour;
            alarmClockMimute = _selectValueVC.alarmClockMinute;
            
        } else if (_selectValueVC.selectIndex == SmartClockSleepTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@",_selectValueVC.smartSleepMinute,NSLocalizedString(@"Minutes clock",nil)];
            
            alarmClockSnooze = _selectValueVC.smartSleepMinute;
            
        } else if (_selectValueVC.selectIndex == SmartClockRepeatCell) {
            NSString *str = [WMSRemindHelper descriptionOfRepeats:_selectValueVC.selectedWeekArray];
            cell.detailTextLabel.text = str;
            
            alarmClockRepeats = _selectValueVC.selectedWeekArray;
            
        }
        
        _selectValueVC = nil;
    }
}

@end
