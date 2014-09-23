//
//  WMSLeftViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-21.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSLeftViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *contentVCArray;

- (void)setUserImage:(UIImage *)image;

- (void)setUserNickname:(NSString *)nickname;

@end
