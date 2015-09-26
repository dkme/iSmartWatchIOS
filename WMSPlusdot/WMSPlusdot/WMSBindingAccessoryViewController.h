//
//  WMSBindingAccessoryViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-23.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSBindingAccessoryViewController : UIViewController

@property (assign, nonatomic) int generation;//第一款为1，第二款为2

#warning 将UITextView改为UILabel，因为xib中有UITextView加载会很慢
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;///在xib中设置为可以显示多行文字:设置行数为0(任意行),设置换行模式

@end
