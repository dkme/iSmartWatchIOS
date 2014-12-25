//
//  WMSAntiLostVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAntiLostVC.h"

#import "WMSNavBarView.h"

@interface WMSAntiLostVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *textArray;
@end

@implementation WMSAntiLostVC

#pragma mark - Getter/Setter
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = @[NSLocalizedString(@"", nil),
                       ];
    }
    return _textArray;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    self.tableView.backgroundColor = [UIColor clearColor];
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
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
}

@end
