//
//  WMSLocationViewController.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/15.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMSLocationViewControllerDelegate;

@interface WMSLocationViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITextField *cityText;

@property (weak, nonatomic) id<WMSLocationViewControllerDelegate> delegate;

@end


@protocol WMSLocationViewControllerDelegate <NSObject>

@optional
- (void)locationViewController:(WMSLocationViewController *)vc didGetLocation:(NSString *)locationName;

@end
