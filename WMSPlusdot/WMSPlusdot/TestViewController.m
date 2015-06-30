//
//  TestViewController.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/9.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "TestViewController.h"
#import "WMSBluetooth.h"
#import "WMSAppDelegate.h"

@interface TestViewController ()

@property (nonatomic, strong) WMSBleControl *bleControl;

@property (nonatomic, strong) NSArray *devices;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickScan:(id)sender {
    WeakObj(self, weakSelf);
    [self.bleControl scanForPeripheralsByInterval:10.0 completion:^(NSArray *peripherals) {
        StrongObj(weakSelf, strongSelf);
        strongSelf.devices = peripherals;
        [strongSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.devices count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    LGPeripheral *pObj = self.devices[indexPath.row];
    cell.textLabel.text = pObj.cbPeripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"services count:%d", (int)pObj.services.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LGPeripheral *pObj = self.devices[indexPath.row];
    [self.bleControl connect:pObj];
}



- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接成功");
}

- (void)handleScanPeripheralFinish:(NSNotification *)notification
{
    DEBUGLog(@"扫描结束");
}

@end
