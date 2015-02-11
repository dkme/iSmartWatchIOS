//
//  WMSExchangeVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSExchangeVC.h"
#import "WMSHowGetBeanVC.h"
#import "UILabel+Attribute.h"

@interface WMSExchangeVC ()

@end

@implementation WMSExchangeVC

#pragma mark - Getter/Setter
- (void)setConsumeBean:(NSUInteger)bean
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"消耗能量豆: %d",bean] attributes:nil];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:@"plusdot_gift_bean_small.png"];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(2.0, -2.0, 15.0, 15.0);
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [str appendAttributedString:textAttachmentString];
    self.consumeBeanLabel.attributedText = str;
}
- (void)setExchangeCode:(NSString *)code
{
    NSString *format = NSLocalizedString(@"兑换码为: /%@/\n您可以在我的礼包中查看", nil);
    NSArray *attributes = @[@{NSForegroundColorAttributeName:
                                  [UIColor whiteColor]},
                            @{NSForegroundColorAttributeName:
                                  [UIColor yellowColor]},
                            @{NSForegroundColorAttributeName:
                                  [UIColor whiteColor]}
                            ];
    [self.codeLabel setSegmentsText:[NSString stringWithFormat:format,code] separateMark:@"/" attributes:attributes];
    self.codeLabel.numberOfLines = 2;
    self.codeLabel.adjustsFontSizeToFitWidth = YES;
    self.codeLabel.lineBreakMode = NSLineBreakByWordWrapping;
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

#pragma mark - setup
- (void)setupUI
{
    NSArray *attributes = @[@{NSUnderlineStyleAttributeName:
                                  @(NSUnderlineStyleSingle)}
                            ];
    [self.getBeanLabel setSegmentsText:NSLocalizedString(@"如何获取能量豆?", nil) separateMark:nil attributes:attributes];
    
    [self setExchangeCode:@"xxxx-xxxxx-xxxxx"];
    
    [self setConsumeBean:10];
}

#pragma mark - Actions
- (IBAction)copyCodeAction:(id)sender {
    DEBUGLog(@"%s",__FUNCTION__);
}
- (IBAction)shareAction:(id)sender {
    DEBUGLog(@"%s",__FUNCTION__);
}
- (IBAction)getBeanAction:(id)sender {
    WMSHowGetBeanVC *vc = [[WMSHowGetBeanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
