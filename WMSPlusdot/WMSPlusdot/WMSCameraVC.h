//
//  WMSCameraVC.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-23.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSCameraVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end
