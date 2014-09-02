//
//  WMSSmartClockViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSmartClockViewController.h"
#import "WMSSelectValueViewController.h"

#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

#define UISwitch_Frame  ( CGRectMake(260, 6, 51, 31) )

@interface WMSSmartClockViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
@property (strong,nonatomic) UISwitch *cellSwitch;
@property (strong,nonatomic) NSArray *textArray;

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


#pragma mark - Action
- (IBAction)backAction:(id)sender {
    self.navigationController.delegate = nil;//一定要加入这条语句
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)switchBtnValueChanged:(id)sender
{
    
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
    cell.detailTextLabel.text = @"";
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
    [self.navigationController pushViewController:VC animated:NO];
    
}


#pragma mark - --UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self && _selectValueVC) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectValueVC.selectIndex inSection:0]];
        
        
        if (_selectValueVC.selectIndex == SmartClockTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d",_selectValueVC.alarmClockHour,_selectValueVC.alarmClockMinute];
        } else if (_selectValueVC.selectIndex == SmartClockSleepTimeCell) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@",_selectValueVC.smartSleepMinute,NSLocalizedString(@"Minutes clock",nil)];
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
        }
        
        _selectValueVC = nil;
    }
}

@end
