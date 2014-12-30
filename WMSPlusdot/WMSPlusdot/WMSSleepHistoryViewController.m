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

#import "WMSConstants.h"
#import "WMSAdaptiveMacro.h"
#import "WMSHistoryVCHelper.h"

#define Y_MAX_DEFAULT       300

#define BOTTOM_VIEW_LABEL_TAG   2000

#define OneDayTimeInterval    (24*60*60)
#define DateFormat            @"yyyy/MM/dd"

@interface WMSSleepHistoryViewController ()<PNBarChartViewDelegate>
@property (nonatomic, strong) PNBar *pnBar;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) WMSSleepDatabase *dataBase;
@property (nonatomic, strong) NSDate *earliestDate;
@end

@implementation WMSSleepHistoryViewController

#pragma mark - Getter
- (PNBar *)pnBar
{
    if (!_pnBar) {
        _pnBar = [[PNBar alloc] init];
        _pnBar.barWidth = PNBAR_WIDTH;
        _pnBar.barColor = UICOLOR_DEFAULT;
        _pnBar.selectedBarColor = [UIColor orangeColor];
        _pnBar.barDefaultHeight = BAR_DEFAULT_HEIGHT;
    }
    return _pnBar;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        CGFloat originY = _barChartView.frame.origin.y+_barChartView.frame.size.height;
        CGRect viewFrame = CGRectMake(0, originY, ScreenWidth, ScreenHeight-originY);
        _bottomView = [[UIView alloc] initWithFrame:viewFrame];
        _bottomView.backgroundColor = [UIColor clearColor];
        
        CGRect labelFrame = CGRectMake(0, (viewFrame.size.height-40)/2.0-20, ScreenWidth, 40);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.textColor = [UIColor darkGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = BOTTOM_VIEW_LABEL_TAG;
        
        [_bottomView addSubview:label];
    }
    return _bottomView;
}

#pragma mark - Set
- (void)setLabelDateText:(NSDate *)date
{
    self.showDate = date;
    
    self.labelDate.text = [self stringWithDate:date andFormart:DateFormat];
}

- (void)setBottomViewLabelText:(NSUInteger)sleepMinute
{
    NSString *describe = NSLocalizedString(@"平均每日睡眠", nil);
    NSString *hour = [NSString stringWithFormat:@"%u",sleepMinute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",sleepMinute%60];
    NSString *hourLbl = NSLocalizedString(@"时",nil);
    NSString *muLbl = NSLocalizedString(@"分",nil);
    if (sleepMinute/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@",describe,hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = describe.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    [text addAttribute:NSForegroundColorAttributeName value:UICOLOR_DEFAULT range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    [text addAttribute:NSForegroundColorAttributeName value:UICOLOR_DEFAULT range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:BOTTOM_VIEW_LABEL_TAG];
    label.attributedText = text;
    label.adjustsFontSizeToFitWidth = YES;
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
    
    self.dataBase = [WMSSleepDatabase sleepDatabase];
    self.earliestDate = [self.dataBase queryEarliestDate];
    self.view.backgroundColor = [UIColor whiteColor];
    //[self analogData];
    [self.view addSubview:self.bottomView];
    [self setupControl];
    [self adaptiveIphone4];
    [self initNavBarView];
    [self initChartView];
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

- (void)setupControl
{
    [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_a.png"] forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonNext setTitle:@"" forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_a.png"] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_b.png"] forState:UIControlStateHighlighted];
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.barChartView.frame;
    frame.size.height -= BAR_CHART_VIEW_REDUCE_HEIGHT;
    self.barChartView.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y -= BOTTOM_VIEW_UP_MOVE_HEIGHT;
    self.bottomView.frame = frame;
}

- (void)initNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
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
    self.barChartView.axisLeftLineWidth = LEFT_INTERVAL;
    self.barChartView.axisBottomLinetHeight = BOTTOM_INTERVAL;
    self.barChartView.pointerInterval = POINTER_INTERVAL;
    self.barChartView.axisLineWidth = 1.0;
    self.barChartView.xAxisFontColor = [UIColor darkGrayColor];
    self.barChartView.xAxisColor = [UIColor grayColor];
    self.barChartView.horizontalLinesColor = [UIColor clearColor];
    self.barChartView.yAxisFontColor = [UIColor clearColor];
    self.barChartView.backgroundColor = [UIColor clearColor];
    
    //[self updateView:self.showDate];
    
    self.barChartView.xAxisValues = [WMSHistoryVCHelper xAxisValuesFromEarliestDate:self.earliestDate currentDate:[NSDate systemDate]];
    self.barChartView.chartIntervalToYAxis = CHART_INTERVAL_TO_YAXIS;
    self.barChartView.delegate = self;
    
    [self drawChart];
}

- (void)drawChart
{
    NSArray *values = [self plottingValues];
    NSArray *tags = [WMSHistoryVCHelper xAxisShowMonthsFromEarliestDate:self.earliestDate currentDate:[NSDate systemDate]];
    NSInteger selectedMonth = [NSDate monthOfDate:[NSDate systemDate]];
    long max = [self yAxisMaxValueFromValues:values];
    [self setChartViewYmax:max];
    [self.pnBar setPlottingValues:values];
    [self.pnBar setBarTags:tags];
    [self.pnBar setBarSelectedTag:selectedMonth];
    [self.barChartView clearPlot];
    [self.barChartView addPlot:self.pnBar];
}

- (NSArray *)plottingValues
{    
    NSDate *startDate =[WMSHistoryVCHelper chartStartDateFromEarliestDate:self.earliestDate currentDate:[NSDate systemDate]];
    NSDate *endDate = [NSDate systemDate];
    NSUInteger currentYear = [NSDate yearOfDate:[NSDate systemDate]];
    NSMutableArray *yAxisValues = [NSMutableArray arrayWithCapacity:12];
    for (int i=(int)[NSDate monthOfDate:startDate]; i<=(int)[NSDate monthOfDate:endDate]; i++)
    {
        long avg_sleepMin = Rounded( [self.dataBase avgSleepTimeFromYear:currentYear month:i] );
        [yAxisValues addObject:@(avg_sleepMin)];
    }
    return yAxisValues;
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

- (long)yAxisMaxValueFromValues:(NSArray *)values
{
    long max = 0;
    for (NSNumber *obj in values) {
        long value = [obj longValue];
        if (max < value) {
            max = value;
        }
    }
    return max;
}

- (void)updateChartViewWithSportModel:(WMSSleepModel *)model
{
//    NSArray *values = @[@(model.deepSleepMinute),
//                        @(model.lightSleepMinute),
//                        @(model.sleepMinute-model.deepSleepMinute-model.lightSleepMinute)];
    model.deepSleepMinute = 120;
    model.lightSleepMinute = 100;
    model.sleepMinute = 300;
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
            return [NSDate stringFromDate:date format:formart];
        default:
            return nil;
    }
    return nil;
}

- (void)updateView:(NSDate *)date
{
    WMSSleepDatabase *db = [WMSSleepDatabase sleepDatabase];
    NSArray *sleepModels = [db querySleepData:date];
    WMSSleepModel *model = nil;
    if ([sleepModels count] > 0) {
        model = [sleepModels objectAtIndex:0];
    }
    model = [[WMSSleepModel alloc] init];
    [self updateChartViewWithSportModel:model];
    [self.barChartView update];
}

- (void)analogData
{
    [self.dataBase deleteAllSleepData];
    UInt16 startedMinutes[5] = {10,50,80,100,120};
    UInt8 startedStatus[5] = {0,1,1,2,2};
    UInt8 statusDurations[5] = {10,40,30,20,20};
    NSString *path = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"plist"];
    NSArray *readData = [NSArray arrayWithContentsOfFile:path];
    //DEBUGLog(@"readData:%@",readData);
    
    for (NSDictionary *dic in readData) {
        NSDate *date = [dic objectForKey:@"date"];
        int endHour = [[dic objectForKey:@"endHour"] intValue];
        int endMinute = [[dic objectForKey:@"endMinute"] intValue];
        int sleepMinute = [[dic objectForKey:@"sleepMinute"] intValue];
        int asleepMinute = [[dic objectForKey:@"asleepMinute"] intValue];
        int awake = [[dic objectForKey:@"awakeCount"] intValue];
        int deep = [[dic objectForKey:@"deep"] intValue];
        int light = [[dic objectForKey:@"light"] intValue];
        
        WMSSleepModel *model = [[WMSSleepModel alloc] initWithSleepDate:date sleepEndHour:endHour sleepEndMinute:endMinute sleepMinute:sleepMinute asleepMinute:asleepMinute awakeCount:awake deepSleepMinute:deep lightSleepMinute:light startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:5];
        
        [self.dataBase insertSleepData:model];
    }
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


#pragma mark - PNBarChartViewDelegate
- (void)barChartView:(PNBarChartView *)chartView didSelectBarTag:(NSInteger)barTag atPNBar:(PNBar *)pnBar
{
    if (chartView != self.barChartView) {
        return;
    }
    int index = 0;
    for (int i=0; i<[pnBar.barTags count]; i++) {
        if (barTag == [pnBar.barTags[i] integerValue]) {
            index = i;
            break;
        }
    }
    if (index < [pnBar.plottingValues count]) {
        long value = [pnBar.plottingValues[index] longValue];
        [self setBottomViewLabelText:value];
    }
}

@end
