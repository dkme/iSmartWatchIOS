//
//  WMSUpdateVC.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSNavBarView;

/*
 *切换升级模式成功时的通知
 */
extern NSString *const WMSUpdateVCStartDFU;
/*
 *结束升级模式时的通知
 */
extern NSString *const WMSUpdateVCEndDFU;

@interface WMSUpdateVC : UIViewController

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextView *textViewState;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpdate;

@property (strong, nonatomic) NSString *navBarTitle;
@property (strong, nonatomic) NSString *updateDescribe;
@property (strong, nonatomic) NSString *updateStrURL;

- (IBAction)updateAction:(id)sender;

@end
