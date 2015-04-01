//
//  WMSDetailsVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDetailsVC.h"
#import "WMSExchangeVC.h"
#import "UIViewController+Tip.h"
#import "WMSHowGetBeanVC.h"
#import "UILabel+Attribute.h"
#import "UIImage+QuartzProc.h"
#import "Activity.h"
#import "ActivityRule.h"
#import "WMSRequestTool.h"
#import "CacheClass.h"
#import "WMSMyAccessory.h"

NSString* const WMSGetNewGiftBag = @"com.guogee.plusdot.WMSGetNewGiftBag";

static const int TextViewLine1                  = 16;
static const int TextViewLine2                  = TextViewLine1+24;
static const int TextViewLine3                  = TextViewLine2+20;

@interface WMSDetailsVC ()
{
    NSUInteger _currentMyBeans;
    NSUInteger _consumeBeans;
}

@end

@implementation WMSDetailsVC

#pragma mark - Getter/Setter
- (void)setMyBean:(NSUInteger)bean
{
    _currentMyBeans = bean;
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
- (void)setmultiplierBean:(NSUInteger)bean
{
    _consumeBeans = bean;
    self.multiplierLabel.text = [NSString stringWithFormat:@"x %d",(int)bean];
}
- (void)setTimeLabelText:(NSString *)text
{
    
}
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self loadDataFromServer];
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
    self.title = self.activity.actName;
    self.view.backgroundColor = UICOLOR_DEFAULT;
    
//    [self.bottomButton setBackgroundImage:nil forState:UIControlStateNormal];
//    [self.bottomButton setBackgroundImage:nil forState:UIControlStateHighlighted];
//    [self.bottomButton setBackgroundColor:UICOLOR_DEFAULT];
//    [self.bottomButton.layer setCornerRadius:10.0];
    self.bottomButton.enabled = NO;
    self.bottomButton.alpha = 0.7;
    NSString *begin = [NSDate stringFromDate:self.activity.beginDate format:@"yyyy.MM.dd"];
    NSString *end = [NSDate stringFromDate:self.activity.endDate format:@"yyyy.MM.dd"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@----%@",begin,end];
    
    NSArray *attributes = @[@{NSUnderlineStyleAttributeName:
                                  @(NSUnderlineStyleSingle)}
                            ];
    [self.getBeanLabel setSegmentsText:NSLocalizedString(@"如何获取能量豆?", nil) separateMark:nil attributes:attributes];
    self.ruleTextView.editable = NO;
    NSMutableString *mutiStr = [[NSMutableString alloc] initWithString:self.activity.actMemo];
    if (TextViewLine1 < mutiStr.length) {
        [mutiStr insertString:@"\n" atIndex:TextViewLine1];
    }else{}
    if (TextViewLine2 < mutiStr.length) {
        [mutiStr insertString:@"\n" atIndex:TextViewLine2];
    }else{}
    if (TextViewLine3 < mutiStr.length) {
        [mutiStr insertString:@"\n" atIndex:TextViewLine3];
    }else{}
    self.ruleTextView.text = mutiStr;
    
    [self.iconImageView setClipsToBounds:YES];
    [self.iconImageView.layer setCornerRadius:self.iconImageView.bounds.size.width/2];
    [self.iconImageView.layer setBorderWidth:0];
    [self.iconImageView.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.iconImageView setImage:self.icon];
    
    [self setmultiplierBean:self.activity.consumeBeans];
    
}
- (void)updateView:(NSArray *)ruleList
{
    NSString *begin = [NSDate stringFromDate:self.activity.beginDate format:@"yyyy.MM.dd"];
    NSString *end = [NSDate stringFromDate:self.activity.endDate format:@"yyyy.MM.dd"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@----%@",begin,end];
    //    [self.iconImageView setImageWithURL:[NSURL URLWithString:self.activity.logo] placeholderImage:nil];
    
    NSMutableString *describe = [[NSMutableString alloc] initWithCapacity:10];
    NSArray *cycleUnits = @[@"小时",@"天",@"周"];
    NSArray *ruleTypes = @[@"运动",@"睡眠"];
    NSArray *countUnits = @[@"步",@"小时"];
    NSString *strCycle = @"";
    NSString *strRuleType = @"";
    NSString *strCountUnit = @"";
    int count,beans,cycleCount;
    count = beans = cycleCount = 0;
    for (ActivityRule *rule in ruleList) {;
        if (rule.cycleType <= ActivityRuleCycleTypeWeek) {
            strCycle = cycleUnits[rule.cycleType];
            cycleCount = rule.cycleCount;
        }else{}
        if (rule.ruleType <= ActivityRuleTypeSleep) {
            strRuleType = ruleTypes[rule.ruleType-1];
            strCountUnit = countUnits[rule.ruleType-1];
            count = rule.count;
        }else{}
        if (rule.ruleType == ActivityRuleTypeBean) {
            beans = rule.count;
        }else{}
    }
    [describe appendString:[NSString stringWithFormat:@"每%d%@累计%@%d%@,\n",cycleCount,strCycle,strRuleType,count,strCountUnit]];
    [describe appendString:[NSString stringWithFormat:@"即可%d个能量豆兑换%@大礼包1个,\n礼包可在%@激活获得游戏道具",beans,self.activity.actName,@"**"]];//少1个字段？？？？
    self.ruleTextView.text = self.activity.actMemo;
    //    self.ruleTextView.text = describe;
    //[self setmultiplierBean:beans];
}
- (void)updateMyBeans:(void(^)())aCallback
{
    NSUInteger beans = _currentMyBeans - _consumeBeans;
    [self setMyBean:beans];
    [CacheClass cacheMyBeans:beans mac:[WMSMyAccessory macForBindAccessory]];
    [WMSRequestTool requestGetBeanWithUserKey:[WMSMyAccessory macForBindAccessory] beanNumber:beans secretKey:SECRET_KEY completion:^(BOOL result, int beans) {
        if (result) {
            if (aCallback) {
                aCallback();
            }else{}
        }else{}
    }];
}

- (void)loadDataFromServer
{
    //load my beans
    int beans = [CacheClass cachedBeansForMac:[WMSMyAccessory macForBindAccessory]];
    if (beans <= 0) {
        [WMSRequestTool requestUserBeansWithUserKey:[WMSMyAccessory macForBindAccessory] completion:^(BOOL result, int beans,NSError *error)
         {
             if (result) {
                 [self setMyBean:beans];
                 [CacheClass cacheMyBeans:beans mac:[WMSMyAccessory macForBindAccessory]];
                 self.bottomButton.enabled = YES;
                 self.bottomButton.alpha = 1.0;
             }else{}
         }];
    } else {
        [self setMyBean:beans];
        self.bottomButton.enabled = YES;
        self.bottomButton.alpha = 1.0;
    }
    
    //load rult lists
//    [WMSRequestTool requestActivityDetailsWithActivityID:self.activity.actID completion:^(BOOL result, NSArray *rultList) {
//        if (result) {
//            [self updateView:rultList];
//            self.bottomButton.enabled = YES;
//            self.bottomButton.alpha = 1.0;
//        }else{
//            self.bottomButton.enabled = NO;
//            self.bottomButton.alpha = 0.7;
//        }
//    }];
}

#pragma mark - Actions
- (IBAction)bottomButtonAction:(id)sender {
    if (_currentMyBeans >= _consumeBeans && _currentMyBeans>0) {
        [self showHUDAtViewCenter:nil];
        [WMSRequestTool requestGetGiftBagWithUserKey:[WMSMyAccessory macForBindAccessory] activityID:self.activity.actID secretKey:SECRET_KEY completion:^(BOOL result, NSString *exchangeCode, NSError *error) {
            if (result) {
                [self hideHUDAtViewCenter];
                if (!exchangeCode) {
                    //[self showTip:@"该活动的礼包已被领取完了"];
                    [self showTip:@"您已兑换过礼包,每天只能兑换一次"];
                    return ;
                }
                [self updateMyBeans:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:WMSGetNewGiftBag object:nil userInfo:nil];//发送通知
                }];
                WMSExchangeVC *vc = [[WMSExchangeVC alloc] init];
                vc.exchangeCode = exchangeCode;
                vc.consumeBeans = (int)_consumeBeans;
                vc.title = self.title;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self hideHUDAtViewCenter];
                [self showTip:@"兑换失败"];
            }
        }];
    } else {
        [self showTip:@"您的能量豆不足，快去运动吧！"];
    }
}
- (IBAction)howToGetBeanAction:(id)sender {
    WMSHowGetBeanVC *vc = [[WMSHowGetBeanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
