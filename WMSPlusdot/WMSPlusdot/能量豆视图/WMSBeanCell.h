//
//  WMSBeanCell.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-6.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSBeanCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailContentLabel;

- (void)configureWithContent:(NSString *)content beans:(NSUInteger)beans;

@end
