//
//  WMSMyAccountViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSMyAccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserImage;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *buttonMan;
@property (weak, nonatomic) IBOutlet UIButton *buttonWoman;
@property (weak, nonatomic) IBOutlet UILabel *labelSex;
@property (weak, nonatomic) IBOutlet UILabel *labelHeightValue;
@property (weak, nonatomic) IBOutlet UILabel *labelBirthdayMonth;
@property (weak, nonatomic) IBOutlet UILabel *labelBirthdayYear;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentWeight;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetWeight;


@property (nonatomic, assign) BOOL isModifyAccount;
@property (nonatomic, assign) BOOL isNewUser;//若是从注册界面进入该界面，设置为YES，否则为NO

@end
