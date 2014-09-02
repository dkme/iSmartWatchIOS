//
//  WMSAccountViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAccountViewController.h"

#define LABEL_MAX_WIDTH 150.f
#define LABEL_MAX_HEIGHT    1
#define SECTION_NUMBER  1
#define SECTION_FOOTER_HEIGHT   1

@interface WMSAccountViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *textArray;
@end

@implementation WMSAccountViewController

#pragma mark - Getter
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = @[NSLocalizedString(@"Change password",nil),
                       NSLocalizedString(@"Forget password",nil),
                       NSLocalizedString(@"About Plusdot",nil),
                       ];
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
    
    self.labelTitle.text = NSLocalizedString(@"My account",nil);
    self.labelDescribe.text = [NSString stringWithFormat:NSLocalizedString(@"%@ watches",nil), @"xxx"];

    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    
    [self setupControl];
    
}
- (void)dealloc
{
    DEBUGLog(@"WMSAccountViewController dealloc");
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupControl
{
    [self.buttonBack setTitle:@"" forState:UIControlStateNormal];
    [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonEdit setTitle:@"" forState:UIControlStateNormal];
    [self.buttonEdit setBackgroundImage:[UIImage imageNamed:@"account_edit_icon.png"] forState:UIControlStateNormal];
    [self.buttonEdit setBackgroundImage:[UIImage imageNamed:@"account_edit_icon.png"] forState:UIControlStateHighlighted];
    
    [self.buttonExit setTitle:NSLocalizedString(@"Exit",nil) forState:UIControlStateNormal];
    [self.buttonExit setBackgroundImage:[UIImage imageNamed:@"exit_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonExit setBackgroundImage:[UIImage imageNamed:@"exit_btn_b.png"] forState:UIControlStateHighlighted];
}

- (void)setDescribeLabelText:(NSString *)text
{
    self.labelDescribe.lineBreakMode = NSLineBreakByTruncatingTail;
    UIFont *font = self.labelDescribe.font;
    
    //label可设置的最大高度和宽度
    CGSize size = CGSizeMake(LABEL_MAX_WIDTH, self.labelDescribe.bounds.size.height);
    
    //获取当前文本的属性
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    //ios7方法，获取文本需要的size，限制宽度
    CGSize actualsize =[@"" boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    CGRect frame = self.labelDescribe.frame;
    frame.size = actualsize;
    self.labelDescribe.frame = frame;
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    DEBUGLog(@"backAction");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editAction:(id)sender {
}

- (IBAction)exitAction:(id)sender {
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.textArray objectAtIndex:indexPath.row];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
//        UIViewController *vc = [[UIViewController alloc] init];
//        vc.view.backgroundColor = [UIColor greenColor];
//        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
