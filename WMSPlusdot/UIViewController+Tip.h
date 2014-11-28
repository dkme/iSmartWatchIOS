//
//  UIViewController+Tip.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Tip)

- (BOOL)checkoutWithIsBind:(BOOL)bindYesOrNo
               isConnected:(BOOL)connectedYesOrNo;

- (void)showOperationSuccessTip:(NSString *)tip;

- (void)showTip:(NSString *)tip;


- (void)showHUDAtViewCenter:(NSString *)text;

- (void)hideHUDAtViewCenter;

@end
