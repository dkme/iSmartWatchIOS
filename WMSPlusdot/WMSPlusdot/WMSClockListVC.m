//
//  WMSClockListVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-9.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSClockListVC.h"
#import "WMSContent1ViewController.h"
#import "WMSSmartClockViewController.h"
#import "UIViewController+Tip.h"
#import "WMSAppDelegate.h"
#import "WMSClockCell.h"
#import "WMSAlarmClockModel.h"
#import "WMSDataManager.h"
#import "WMSMyAccessory.h"
#import "WMSRemindHelper.h"
#import "WMSConstants.h"

#define CELL_HEIGHT                     75.f
#define MAX_NUMBER_CLOCK                1

@interface WMSClockListVC ()<UINavigationControllerDelegate,UIAlertViewDelegate,WMSClockCellDelegage>
{
    WMSSmartClockViewController *_detailClockVC;
    WMSAlarmClockModel *_editClockModel;//nil表示新增，no-nil表示编辑
    NSMutableArray *_oldClocks, *_newClocks;
    NSUInteger _clockID;
}
@property (nonatomic,strong) NSMutableArray *clockArray;
@end

@implementation WMSClockListVC

#pragma mark - Getter/Setter

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupValue];
    [self setupNavigationBar];
    [self setupTableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    RESideMenu *menu = [WMSAppDelegate appDelegate].reSideMenu;
    menu.panGestureEnabled = YES;
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - Setup
- (void)setupNavigationBar
{
    self.title = NSLocalizedString(@"Smart alarm clock", nil);
    self.navigationController.delegate = self;
    
    UIBarButtonItem *leftItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
    UIBarButtonItem *item1 = [UIBarButtonItem itemWithTitle:NSLocalizedString(@"同步", nil) size:SYNC_BUTTON_SIZE target:self action:@selector(syncAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = item1;
}
- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}
- (void)setupValue
{
    NSArray *clocks = [WMSDataManager loadAlarmClocks];
    _oldClocks = [NSMutableArray arrayWithArray:clocks];
    _newClocks = [NSMutableArray arrayWithArray:clocks];
    if (clocks.count <=0) {
        self.clockArray = nil;
    } else {
        _clockArray = [NSMutableArray arrayWithArray:clocks];
    }
    
    RESideMenu *menu = [WMSAppDelegate appDelegate].reSideMenu;
    menu.panGestureEnabled = NO;
}

#pragma mark - Other
- (void)startSettingClock
{
    _clockID = 1;
    WMSAlarmClockModel *clock = _newClocks[_clockID-1];
    NSArray *array = [WMSRemindHelper repeatsWithArray:clock.repeats];
    Byte repeats[7] = {0};
    NSUInteger length = 7;
    for (int i=0; i<[array count]; i++) {
        Byte b = (Byte)[array[i] intValue];
        if (i < length) {
            repeats[i] = b;
        }
    }
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
//    [bleControl.settingProfile setAlarmClockWithId:_clockID withHour:clock.startHour withMinute:clock.startMinute withStatus:clock.status withRepeat:repeats withLength:length withSnoozeMinute:clock.snoozeMinute withCompletion:^(BOOL success)
//     {
//         DEBUGLog(@"设置闹钟[%d]%@",_clockID,success?@"成功":@"失败");
//         [self continueSettingClock];
//     }];
}
- (void)continueSettingClock
{
    _clockID ++;
    if (_clockID-1 >= [_newClocks count]) {
        [self showTip:NSLocalizedString(@"设置闹钟成功", nil)];
        BOOL res=[WMSDataManager savaAlarmClocks:self.clockArray];
        DEBUGLog(@"保存数据%d",res);
        [self settingClockSuccess];
        return ;
    }
    WMSAlarmClockModel *clock = _newClocks[_clockID-1];
    NSArray *array = [WMSRemindHelper repeatsWithArray:clock.repeats];
    Byte repeats[7] = {0};
    NSUInteger length = 7;
    for (int i=0; i<[array count]; i++) {
        Byte b = (Byte)array[i];
        if (i < length) {
            repeats[i] = b;
        }
    }
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
//    [bleControl.settingProfile setAlarmClockWithId:_clockID withHour:clock.startHour withMinute:clock.startMinute withStatus:clock.status withRepeat:repeats withLength:length withSnoozeMinute:clock.snoozeMinute withCompletion:^(BOOL success)
//     {
//         DEBUGLog(@"设置闹钟[%d]%@",_clockID,success?@"成功":@"失败");
//         [self continueSettingClock];
//     }];
}
- (void)settingClockSuccess
{
    [_newClocks removeAllObjects];
    [_newClocks addObjectsFromArray:self.clockArray];
    [_oldClocks removeAllObjects];
    [_oldClocks addObjectsFromArray:self.clockArray];
}

#pragma mark - 界面切换
- (void)pushToDetailClockVC:(WMSAlarmClockModel *)model
{
    _detailClockVC = [[WMSSmartClockViewController alloc] init];
    _editClockModel = model;
    _detailClockVC.title = self.title;
    _detailClockVC.clockModel = _editClockModel;
    [self.navigationController pushViewController:_detailClockVC animated:YES];
}

#pragma mark - Action
- (IBAction)addClockAction:(id)sender
{
    if ([self.clockArray count] >= MAX_NUMBER_CLOCK) {
        NSString *title = NSLocalizedString(@"提示", nil);
        NSString *format = NSLocalizedString(@"只能添加%d个闹钟", nil);
        NSString *message = [NSString stringWithFormat:format,MAX_NUMBER_CLOCK];
        NSString *cancelBtn = NSLocalizedString(@"知道了", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelBtn otherButtonTitles:nil];
        [alert show];
    } else {
        [self pushToDetailClockVC:nil];
    }
}
- (void)backAction:(id)sender
{
    if ([_oldClocks isEqualToArray:_newClocks])
    {
        //没有任何修改
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSString *message = NSLocalizedString(@"您的闹钟已修改，尚未同步到手表，是否同步?", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        [alert show];
    }
}
- (void)syncAction:(id)sender
{
    WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    BOOL isBind = [WMSMyAccessory isBindAccessory];
    BOOL isConnected = [bleControl isConnected];
    BOOL result = [self checkoutWithIsBind:isBind isConnected:isConnected];
    if (result == NO) {
        return ;
    }
    
    if (!self.clockArray) {
        //还没有设置闹钟
        [self showTip:NSLocalizedString(@"您还没有添加闹钟", nil)];
        return ;
    }
    
    if ([_oldClocks isEqualToArray:_newClocks] || (_newClocks.count <=0))
    {
        //没有任何修改
        [self showTip:NSLocalizedString(@"设置闹钟成功", nil)];
        [self settingClockSuccess];
        return ;
    }
    [self startSettingClock];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//NO
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self syncAction:nil];
    }
}
#pragma mark - WMSClockCellDelegage
- (void)clockCell:(WMSClockCell *)clockCell didClickSwitch:(UISwitch *)sw
{
    if (sw.on) {
        clockCell.backgroundColor = [UIColor whiteColor];
    } else {
        clockCell.backgroundColor = UIColorFromRGBAlpha(0xF3F2F5, 1.0);
    }
    NSInteger row = [[self.tableView indexPathForCell:clockCell] row];
    WMSAlarmClockModel *clock = self.clockArray[row];
    WMSAlarmClockModel *newClock = [[WMSAlarmClockModel alloc] initWithStatus:clock.status startHour:clock.startHour startMinute:clock.startMinute snoozeMinute:clock.snoozeMinute repeats:clock.repeats];
    newClock.status = sw.on;
    self.clockArray[row] = newClock;
    _newClocks[row] = newClock;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.clockArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    UINib *cellNib = [UINib nibWithNibName:@"WMSClockCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    WMSClockCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    WMSAlarmClockModel *model = self.clockArray[indexPath.row];
    cell.myTextLabel.text = [NSString stringWithFormat:@"%02d:%02d",model.startHour,model.startMinute];
    cell.myDetailTextLabel.text = [NSString stringWithFormat:@" %@",[WMSRemindHelper description2OfRepeats:model.repeats]];
    cell.myTextLabel.textColor = UICOLOR_DEFAULT;
    cell.myTextLabel.font = Font_System(35.f);
    cell.myDetailTextLabel.font = Font_System(15.f);
    cell.mySwitch.on = model.status;
    cell.delegate = self;
    if (cell.mySwitch.on) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = UIColorFromRGBAlpha(0xF3F2F5, 1.0);
    }
    if (tableView.isEditing) {
        cell.mySwitch.hidden = YES;
    } else {
        cell.mySwitch.hidden = NO;
    }
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WMSAlarmClockModel *clock = _newClocks[indexPath.row];
        WMSAlarmClockModel *newClock = [[WMSAlarmClockModel alloc] initWithStatus:clock.status startHour:clock.startHour startMinute:clock.startMinute snoozeMinute:clock.snoozeMinute repeats:clock.repeats];
        if (newClock.status && _oldClocks.count > 0) {
            newClock.status = NO;
            _newClocks[indexPath.row] = newClock;
        } else {
            [_newClocks removeObjectAtIndex:indexPath.row];
            //[_oldClocks removeObjectAtIndex:indexPath.row];
        }
        
        [self.clockArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _editClockModel = self.clockArray[indexPath.row];
    [self pushToDetailClockVC:_editClockModel];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self && _detailClockVC) {
        if (!_clockArray) {
            _clockArray = [[NSMutableArray alloc] initWithCapacity:10];
        }
        WMSAlarmClockModel *model = _detailClockVC.clockModel;
        if (model && !_editClockModel) {
            [self.clockArray addObject:model];
            [_newClocks addObject:model];
            [self.tableView reloadData];
        } else if (_editClockModel && ![_editClockModel isEqual:model]) {
            NSUInteger index = [self.clockArray indexOfObject:_editClockModel];
            if (index < [self.clockArray count]) {
                [self.clockArray replaceObjectAtIndex:index withObject:model];
                [_newClocks replaceObjectAtIndex:index withObject:model];
                [self.tableView reloadData];
            }
        } else{};
        _detailClockVC = nil;
    } else{};
}

@end
