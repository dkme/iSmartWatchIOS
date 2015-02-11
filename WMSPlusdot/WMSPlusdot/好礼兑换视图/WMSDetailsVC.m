//
//  WMSDetailsVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDetailsVC.h"
#import "WMSExchangeVC.h"
#import "WMSHowGetBeanVC.h"
#import "UILabel+Attribute.h"
#import "UIImage+QuartzProc.h"

@interface WMSDetailsVC ()

@end

@implementation WMSDetailsVC

#pragma mark - Getter/Setter
- (void)setMyBean:(NSUInteger)bean
{
    NSString *format = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"我的能量豆: %d",nil)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format,bean] attributes:nil];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:@"plusdot_gift_bean_small.png"];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(2.0, -2.0, 15.0, 15.0);
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [str appendAttributedString:textAttachmentString];
    self.myBeanLabel.attributedText = str;
}
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - Setup
- (void)setupUI
{
    self.timeLabel.text = @"2014.12.20----2015.2.28";
    NSArray *attributes = @[@{NSUnderlineStyleAttributeName:
                                  @(NSUnderlineStyleSingle)}
                            ];
    [self.getBeanLabel setSegmentsText:NSLocalizedString(@"如何获取能量豆?", nil) separateMark:nil attributes:attributes];
    [self setMyBean:1000];
    self.ruleTextView.text = @"从即日起到范德萨范德萨发范德萨发生的范德萨发生的范德萨发生的范德萨发生范德萨发生范德萨发生范德萨发生范德萨发生的范德萨发生的范德萨的发的啥地方";
    //self.ruleTextView.lineBreakMode = 0;
    
}

#pragma mark - Actions
- (IBAction)bottomButtonAction:(id)sender {
    WMSExchangeVC *vc = [[WMSExchangeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)howToGetBeanAction:(id)sender {
    WMSHowGetBeanVC *vc = [[WMSHowGetBeanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
