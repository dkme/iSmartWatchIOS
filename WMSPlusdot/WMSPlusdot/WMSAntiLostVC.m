//
//  WMSAntiLostVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAntiLostVC.h"

#import "WMSNavBarView.h"
#import "WMSSwitchCell.h"

#define SECTION_NUMBER              1
#define SECTION0_HEADER_HEIGHT      40

@interface WMSAntiLostVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *textArray;
@end

@implementation WMSAntiLostVC

#pragma mark - Getter/Setter
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = @[NSLocalizedString(@"防丢", nil),
                       NSLocalizedString(@"Interval", nil)];
    }
    return _textArray;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavBarView];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup UI
- (void)setupNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
    self.navBarView.labelTitle.text = self.navBarTitle;
    self.navBarView.labelTitle.font = Font_DINCondensed(20.0);
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setupTableView
{
    CGRect frame = self.tableView.frame;
    frame.size.width = 305;
    frame.origin.x = (ScreenWidth-frame.size.width)/2.0;
    self.tableView.frame = frame;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.textArray count];
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
        {
            if (row == 0) {
                NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)section,(int)row];
                UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
                [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
                
                WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CGRect frame = cell.myLabelText.frame;
                frame.origin.x = 0.0;
                cell.myLabelText.frame = frame;
                cell.myLabelText.backgroundColor = [UIColor redColor];
                cell.myLabelText.text = [self.textArray objectAtIndex:row];
                //cell.myLabelText.textColor = [UIColor blackColor];
                cell.myLabelText.font = Font_DINCondensed(18);
                
                return cell;
            } else {
                NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)section,(int)row];
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                }
                cell.textLabel.text = [self.textArray objectAtIndex:row];
                cell.textLabel.font = Font_DINCondensed(18.0);
                //cell.detailTextLabel.text = [self.detailTextArray objectAtIndex:indexPath.row];
                cell.detailTextLabel.font = Font_DINCondensed(12.0);
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            
            break;
        }
            
        default:
            break;
    }
    
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
            break;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
    CGRect frame = CGRectMake(80, height-30, 200, 30);
    UIView *myView = [[UIView alloc] init];
    //myView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.font = Font_DINCondensed(18);
    //titleLabel.backgroundColor = [UIColor blackColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSString *title = NSLocalizedString(@"........", nil);
    
    [titleLabel setText:title];
    [myView addSubview:titleLabel];
    
    return myView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
