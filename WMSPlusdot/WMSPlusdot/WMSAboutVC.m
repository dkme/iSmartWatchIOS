//
//  WMSAboutVC.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/12.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSAboutVC.h"

@interface WMSAboutVC ()

@end

@implementation WMSAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    self.appVersionLabel.text = [NSString stringWithFormat:@"v%@",currentVersion];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
