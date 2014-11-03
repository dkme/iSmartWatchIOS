//
//  WMSSleepHistoryViewController.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-27.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSleepHistoryViewController.h"

#import "WMSNavBarView.h"
#import "PNBarChartView.h"
#import "PNBar.h"
#import "WMSSleepDatabase.h"
#import "WMSSleepModel.h"
#import "NSDate+Formatter.h"

#define LEFT_INTERVAL   35.f
#define BOTTOM_INTERVAL 30.f
#define POINTER_INTERVAL (77.f)
#define LEVEL_LINE_NUMBER 6

#define Y_MAX_DEFAULT     180

#define OneDayTimeInterval    (24*60*60)
#define DateFormat            @"yyyy/MM/dd"

@interface WMSSleepHistoryViewController ()
@property (nonatomic, strong) PNBar *pnBar;
@end

@implementation WMSSleepHistoryViewController

#pragma mark - Getter
- (PNBar *)pnBar
{
    if (!_pnBar) {
        _pnBar = [[PNBar alloc] init];
        _pnBar.barColors = @[[UIColor greenColor],
                             [UIColor orangeColor],
                             [UIColor yellowColor]];
        _pnBar.barWidth = 50.f;
    }
    return _pnBar;
}

#pragma mark - Set
- (void)setLabelDateText:(NSDate *)date
{
    self.showDate = date;
    
    self.labelDate.text = [self stringWithDate:date andFormart:DateFormat];
}

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initNavBarView];
    [self initChartView];
    [self setupControl];
    [self setLabelDateText:self.showDate];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%@ dealloc",[self class]);
}

- (void)initNavBarView
{
    self.navBarView.backgroundColor = [UIColor clearColor];
    self.navBarView.labelTitle.text = NSLocalizedString(@"睡眠记录",nil);
    self.navBarView.labelTitle.font = Font_DINCondensed(20.f);
    
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)initChartView
{
    self.barChartView.min = 0;
    [self setChartViewYmax:Y_MAX_DEFAULT];
    self.barChartView.numberOfVerticalElements = LEVEL_LINE_NUMBER;
    self.barChartView.horizontalLineInterval = self.barChartView.bounds.size.height/(LEVEL_LINE_NUMBER+1) - 1;
    
    NSArray *xAxisValues = @[NSLocalizedString(@"Deep sleep", nil),
                             NSLocalizedString(@"Light sleep", nil),
                             NSLocalizedString(@"Wake up", nil)];
    self.barChartView.xAxisValues = xAxisValues;
    self.barChartView.axisLeftLineWidth = LEFT_INTERVAL;
    self.barChartView.axisBottomLinetHeight = BOTTOM_INTERVAL;
    self.barChartView.pointerInterval = POINTER_INTERVAL;
    self.barChartView.axisLineWidth = 1.0;
    self.barChartView.xAxisFontColor = [UIColor whiteColor];
    self.barChartView.horizontalLinesColor = [UIColor whiteColor];
    self.barChartView.backgroundColor = [UIColor clearColor];
    
    [self updateView:self.showDate];
}
- (void)setChartViewYmax:(float)max
{
    if (max > Y_MAX_DEFAULT) {
        self.barChartView.max = max;
    } else {
        self.barChartView.max = Y_MAX_DEFAULT;
    }
    self.barChartView.interval = (self.barChartView.max-self.barChartView.min)/LEVEL_LINE_NUMBER;
    NSMutableArray *yAxisValues = [NSMutableArray arrayWithCapacity:1];
    for (int i=0; i<LEVEL_LINE_NUMBER+1; i++) {
        NSString *str = [NSString stringWithFormat:@"%f", self.barChartView.min+self.barChartView.interval*i];
        [yAxisValues addObject:str];
    }
    self.barChartView.yAxisValues = yAxisValues;
    self.barChartView.floatNumberFormatterString = @"%.0f";
}

- (void)setupControl
{
    [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_a.png"] forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonNext setTitle:@"" forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_a.png"] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_b.png"] forState:UIControlStateHighlighted];
}


- (NSString *)stringWithDate:(NSDate *)date andFormart:(NSString *)formart
{
    switch ([NSDate compareDate:date]) {
        case NSDateModeToday:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeYesterday:
            return NSLocalizedString(@"Yesterday",nil);
        case NSDateModeTomorrow:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeUnknown:
            return [NSDate formatDate:date withFormat:formart];
        default:
            return nil;
    }
    return nil;
}

- (void)updateChartViewWithSportModel:(WMSSleepModel *)model
{
    NSArray *values = @[@(model.deepSleepMinute),
                        @(model.lightSleepMinute),
                        @(model.sleepMinute-model.deepSleepMinute-model.lightSleepMinute)];
    NSUInteger max = 0;
    if (max < model.deepSleepMinute) {
        max = model.deepSleepMinute;
    }
    if (max < model.lightSleepMinute) {
        max = model.lightSleepMinute;
    }
    if (max < (model.sleepMinute-model.deepSleepMinute-model.lightSleepMinute)) {
        max = model.sleepMinute-model.deepSleepMinute-model.lightSleepMinute;
    }
    
    
    [self.barChartView.plots removeAllObjects];
    [self.pnBar setPlottingValues:values];
    [self.barChartView addPlot:self.pnBar];
    [self setChartViewYmax:max];
    
}

- (void)updateView:(NSDate *)date
{
    WMSSleepDatabase *db = [WMSSleepDatabase sleepDatabase];
    NSArray *sleepModels = [db querySleepData:date];
    WMSSleepModel *model = nil;
    if ([sleepModels count] > 0) {
        model = [sleepModels objectAtIndex:0];
    }
    
    [self updateChartViewWithSportModel:model];
    [self.barChartView update];
}


#pragma mark - Action
- (IBAction)prevDateAction:(id)sender {
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
    [self setLabelDateText:date];
    
    [self updateView:self.showDate];
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    [self setLabelDateText:date];
    
    [self updateView:self.showDate];
}

- (void)buttonLeftClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
