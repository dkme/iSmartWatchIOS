//
//  WMSEnergyBeanVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-28.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSEnergyBeanVC.h"
#import "WMSAppDelegate.h"
#import "WMSBeanCell.h"
#import "ArrayDataSource.h"

@interface WMSEnergyBeanVC ()
@property (nonatomic, strong) ArrayDataSource *arrayDataSource;
@end

@implementation WMSEnergyBeanVC

#pragma mark - Getter/Setter
- (void)setMyBean:(NSUInteger)bean
{
    NSString *format = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"我的能量豆: %d",nil)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format,bean] attributes:nil];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:@"plusdot_gift_bean_small.png"];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(2.0, -2.0, 15.0, 15.0);
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [str appendAttributedString:textAttachmentString];
    self.myBeanLabel.attributedText = str;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[self setupValue];
    [self setupUI];
    [self setupNavigationBar];
    [self setupTableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - Setup
- (void)setupUI
{
    self.title = NSLocalizedString(@"能量豆", nil);
    [self setMyBean:1000];
}
- (void)setupNavigationBar
{
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"main_menu_icon_a.png" highImageName:@"main_menu_icon_b.png" target:self action:@selector(backAction:)];
}
- (void)setupTableView
{
    if (!self.arrayDataSource) {
        __weak __typeof(self) weakSelf = self;
        TableViewConfigureBlock configure = ^id(UITableView *tableView, NSIndexPath *indexPath, NSArray *datas) {
            NSString *CellIdentifier = [NSString stringWithFormat:@"WMSBeanCell"];
            WMSBeanCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WMSBeanCell" owner:weakSelf options:nil] lastObject];
            }
            [cell configureWithContent:datas[indexPath.row]];
            return cell;
        };
        NSArray *items = @[@"完成10000步",@"完成20000步"];
        _arrayDataSource = [[ArrayDataSource alloc] initWithItems:items configureTableViewBlock:configure];
    }
    self.tableView.dataSource = self.arrayDataSource;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 44.f;
    self.tableView.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
}

#pragma mark - Actions
- (void)backAction:(id)sender
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)bottomButtonAction:(id)sender {
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
