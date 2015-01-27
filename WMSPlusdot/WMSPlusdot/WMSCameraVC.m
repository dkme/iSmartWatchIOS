//
//  WMSCameraVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-23.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSCameraVC.h"

@interface WMSCameraVC ()
{
    BOOL hasLoadedCamera;
}

@end

@implementation WMSCameraVC

@synthesize imagePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //show camera...
    if (!hasLoadedCamera) {
        [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showcamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return ;
    }
    UIImagePickerControllerSourceType sourceType;
    sourceType=UIImagePickerControllerSourceTypeCamera;
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.sourceType = sourceType;
//    //设置图像选取控制器的类型为静态图像
//    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
//    picker.allowsEditing=NO;
//    picker.showsCameraControls = YES;
//    picker.delegate = self;
    
    imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    [imagePicker setAllowsEditing:YES];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
