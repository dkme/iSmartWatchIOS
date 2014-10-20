//
//  WMSMyAccessoryViewController.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-15.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMyAccessoryViewController.h"
#import "WMSNavBarView.h"
#import "WMSAppDelegate.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSMyAccessory.h"

#define SECTION_NUMBER  1
#define CELL_HIGHT      60
#define HEADER_HEIGHT   10

@interface WMSMyAccessoryViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic, strong) WMSNavBarView *navBarView;
@end

@implementation WMSMyAccessoryViewController

#pragma mark - Getter
- (WMSNavBarView *)navBarView
{
    if (!_navBarView) {
        _navBarView = [[WMSNavBarView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        _navBarView.backgroundColor = UIColorFromRGBAlpha(0x00D5E1, 1);
        _navBarView.labelTitle.text = NSLocalizedString(@"绑定的配件",nil);
        _navBarView.labelTitle.font = Font_DINCondensed(20.f);
    }
    return _navBarView;
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
    
    [self.view addSubview:self.navBarView];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setupControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupControl
{
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = self.navBarView.buttonLeft.frame;
    frame.origin.y -= 5;
    self.navBarView.buttonLeft.frame = frame;
}


#pragma mark - Other
- (void)showActionSheet
{
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"解除绑定", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//destructive
        //。。。。。。
        //。。。。。。
        [WMSMyAccessory unBindAccessory];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([WMSMyAccessory isBindAccessory] == NO) {
        return 0;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",@"plusdot",NSLocalizedString(@"手表", nil)];
    cell.textLabel.font = Font_DINCondensed(23.0);
    
    cell.detailTextLabel.text = @"    ";
    cell.detailTextLabel.font = Font_DINCondensed(15.0);
    
    CGRect frame = cell.textLabel.frame;
    frame.size.height += 10;
    cell.textLabel.frame = frame;
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aa"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showActionSheet];
}


@end
