//
//  WMSMyAccountViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMyAccountViewController.h"
#import "WMSNavBarView.h"

#define PickerViewHeight    216.f
#define DatePickerHeight    PickerViewHeight
#define ToolbarHeight       44.f

#define HeightViewIndex             100
#define BirthdayViewIndex           101
#define CurrentWeightViewIndex      102
#define TargetWeightViewIndex       103

#define HeightUnit      @"cm"
#define WeightUnit      @"kg"

#define COMPONENT_NUMBER 2
#define COMPONENT_WIDTH  50.f

@interface WMSMyAccountViewController ()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    //本地化
    __weak IBOutlet UILabel *labelTip2;
    __weak IBOutlet UILabel *labelShenGao;
    __weak IBOutlet UILabel *labelShengRi;
    __weak IBOutlet UILabel *labelTiZhong1;
    __weak IBOutlet UILabel *labelTiZhong2;
}

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *buttonMan;
@property (weak, nonatomic) IBOutlet UIButton *buttonWoman;
@property (weak, nonatomic) IBOutlet UILabel *labelSex;
@property (weak, nonatomic) IBOutlet UILabel *labelHeightValue;
@property (weak, nonatomic) IBOutlet UILabel *labelBirthdayMonth;
@property (weak, nonatomic) IBOutlet UILabel *labelBirthdayYear;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentWeight;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetWeight;

@property (strong, nonatomic) UIPickerView *myPickerView;
@property (strong, nonatomic) UIDatePicker *myDatePicker;
@property (strong, nonatomic) UIToolbar *myToolbar;
@property (strong, nonatomic) NSMutableArray *pickerViewComponent1Array;
@property (strong, nonatomic) NSArray *pickerViewComponent2Array;

@property (strong, nonatomic) NSMutableArray *heightArray;
@property (strong, nonatomic) NSMutableArray *weightArray;

//身高view，生日view，当前体重view，目标体重view，index分别为100，101，102，103
@property (nonatomic) int clickedViewIndex;
@end

@implementation WMSMyAccountViewController

#pragma mark - Getter
- (UIPickerView *)myPickerView
{
    if (!_myPickerView) {
        _myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, PickerViewHeight)];
        _myPickerView.backgroundColor = [UIColor whiteColor];
        //DEBUGLog(@"PickerView Height:%f",_myPickerView.bounds.size.height);
    }
    return _myPickerView;
}
- (UIDatePicker *)myDatePicker
{
    if (!_myDatePicker) {
        _myDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, DatePickerHeight)];
        _myDatePicker.datePickerMode = UIDatePickerModeDate;
        _myDatePicker.backgroundColor = [UIColor whiteColor];
    }
    return _myDatePicker;
}
- (UIToolbar *)myToolbar
{
    if (!_myToolbar) {
        _myToolbar = [[UIToolbar alloc] init];
        _myToolbar.frame = (CGRect){0,ScreenHeight,ScreenWidth,ToolbarHeight};
        _myToolbar.barTintColor = [UIColor whiteColor];
        _myToolbar.backgroundColor = [UIColor whiteColor];
        _myToolbar.alpha = 1.0;
        //_myToolbar.barStyle = UIBarStyleDefault;
        DEBUGLog(@"toolbar Height:%f,%f",_myToolbar.bounds.size.width,_myToolbar.bounds.size.height);
        
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Confirm",nil) style:UIBarButtonItemStyleDone target:self action:@selector(confirmClicked:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *buttons = @[leftBarButton,flexibleSpace,rightBarButton];
        
        [_myToolbar setItems:buttons animated:YES];
    }
    return _myToolbar;
}

//- (NSArray *)pickerViewComponent1
//{
//    if (!_pickerViewComponent1) {
//        _pickerViewComponent1 = @[];
//    }
//    return nil;
//}
- (NSMutableArray *)heightArray
{
    if (!_heightArray) {
        _heightArray = [[NSMutableArray alloc] init];
        for (int i=100; i<=240; i++) {
            [_heightArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _heightArray;
}
- (NSMutableArray *)weightArray
{
    if (!_weightArray) {
        _weightArray = [[NSMutableArray alloc] init];
        for (int i=35; i<=220; i++) {
            [_weightArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _weightArray;
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
    
    DEBUGLog(@"view height:%f",self.view.bounds.size.height);
    DEBUGLog(@"window height:%f",[[UIScreen mainScreen] bounds].size.height);
    
    self.navBarView.labelTitle.text = NSLocalizedString(@"Personal data",nil);
    self.navBarView.labelTitle.font = [UIFont fontWithName:@"DIN Condensed" size:20.f];
    
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.textFieldName.text = @"";
    self.textFieldName.placeholder = NSLocalizedString(@"Please enter a nickname", nil);
    self.textFieldName.font = [UIFont systemFontOfSize:25.f];
    self.textFieldName.delegate = self;
    
    self.myPickerView.dataSource = self;
    self.myPickerView.delegate = self;
    
    [self.view addSubview:self.myPickerView];
    [self.view addSubview:self.myDatePicker];
    [self.view addSubview:self.myToolbar];
    
    DEBUGLog(@"datePicker frame:%f,%f",self.myDatePicker.bounds.size.width,self.myDatePicker.bounds.size.height);
    
    
    _pickerViewComponent1Array = [NSMutableArray arrayWithArray:@[@"170",@"180",@"170",@"180"]];
    
    [self setupControl];
    
    [self localized];
}

- (void)dealloc
{
    DEBUGLog(@"WMSMyAccountViewController dealloc");
    self.textFieldName.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupControl
{
    [self.buttonMan setTitle:@"" forState:UIControlStateNormal];
    [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"select_man.png"] forState:UIControlStateNormal];
    [self.buttonMan addTarget:self action:@selector(buttonManClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonWoman setTitle:@"" forState:UIControlStateNormal];
    [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"select_woman.png"] forState:UIControlStateNormal];
    [self.buttonWoman addTarget:self action:@selector(buttonWomanClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)localized
{
    labelTip2.text = NSLocalizedString(@"Please enter the character signature",nil);
    labelShenGao.text = NSLocalizedString(@"Height",nil);
    labelShengRi.text = NSLocalizedString(@"Birthday",nil);
    labelTiZhong1.text = NSLocalizedString(@"Current weight",nil);
    labelTiZhong2.text = NSLocalizedString(@"Target weight",nil);
}

//判断self.myPickerView是否显示
- (BOOL)isShowPickerView
{
    if (self.myPickerView.frame.origin.y == ScreenHeight) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}
//显示或隐藏self.myPickerView
- (void)showPickerView:(BOOL)show
{
    CGPoint or = self.myPickerView.frame.origin;
    float offset = self.myPickerView.bounds.size.height;
    if (show) {
        if (or.y == ScreenHeight) {
            or.y -= offset;
            self.myPickerView.frame = (CGRect){or,self.myPickerView.bounds.size};
        }
    } else {
        if (or.y == ScreenHeight - offset) {
            or.y += offset;
            self.myPickerView.frame = (CGRect){or,self.myPickerView.bounds.size};
        }
    }
}
- (BOOL)isShowDatePicker
{
    if (self.myDatePicker.frame.origin.y == ScreenHeight) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}
- (void)showDatePicker:(BOOL)show
{
    CGPoint or = self.myDatePicker.frame.origin;
    float offset = self.myDatePicker.bounds.size.height;
    if (show) {
        if (or.y == ScreenHeight) {
            or.y -= offset;
            self.myDatePicker.frame = (CGRect){or,self.myDatePicker.bounds.size};
        }
    } else {
        if (or.y == ScreenHeight - offset) {
            or.y += offset;
            self.myDatePicker.frame = (CGRect){or,self.myDatePicker.bounds.size};
        }
    }
}
//判断self.myPickerView是否显示
- (BOOL)isShowToolbar
{
    if (self.myToolbar.frame.origin.y == ScreenHeight) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}
//显示或隐藏self.myToolbar
- (void)showToolbar:(BOOL)show
{
    CGPoint or = self.myToolbar.frame.origin;
    float offset = ToolbarHeight + PickerViewHeight;
    if (show) {
        if (or.y == ScreenHeight) {
            or.y -= offset;
            self.myToolbar.frame = (CGRect){or,self.myToolbar.bounds.size};
        }
    } else {
        if (or.y == ScreenHeight - offset) {
            or.y += offset;
            self.myToolbar.frame = (CGRect){or,self.myToolbar.bounds.size};
        }
    }
}
- (BOOL)isShowInputView
{
    if ([self isShowToolbar]) {
        return YES;
    } else {
        return NO;
    }
}
//显示或隐藏InputView
- (void)showInputView:(BOOL)show
{
    [self showToolbar:show];
    if (self.clickedViewIndex != BirthdayViewIndex) {
        [self showPickerView:show];
        return;
    }
    [self showDatePicker:show];
}

//使self.textFieldName失去第一响应者
- (void)textFieldNameResignFirstResponder
{
    if ([self.textFieldName isFirstResponder]) {
        [self.textFieldName resignFirstResponder];
    }

}

#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonManClicked:(id)sender
{
    self.labelSex.text = NSLocalizedString(@"Man",nil);
}

- (void)buttonWomanClicked:(id)sender
{
    self.labelSex.text = NSLocalizedString(@"Woman",nil);
}

//- (IBAction)resignResponse:(id)sender {
//    if ([self.textFieldName isFirstResponder]) {
//        [self.textFieldName resignFirstResponder];
//    }
//
//    if ([self isShowInputView]) {
//        [UIView animateWithDuration:0.5 animations:^{
//            //[self showPickerView:NO];
//            [self showInputView:NO];
//        }];
//    }
//}


- (IBAction)heightClicked:(id)sender {
    self.clickedViewIndex = HeightViewIndex;
    
    [self textFieldNameResignFirstResponder];
    
    if ([self isShowInputView]) {
        [UIView animateWithDuration:0.5 animations:^{
            [self showInputView:NO];
        }];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:YES];
    }];
    
    [self.myPickerView reloadAllComponents];
}

- (IBAction)birthdayClicked:(id)sender {
    self.clickedViewIndex = BirthdayViewIndex;
    
    [self textFieldNameResignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:YES];
    }];
}

- (IBAction)currentWeightClicked:(id)sender {
    self.clickedViewIndex = CurrentWeightViewIndex;
    
    [self textFieldNameResignFirstResponder];
    
    if ([self isShowInputView]) {
        [UIView animateWithDuration:0.5 animations:^{
            [self showInputView:NO];
        }];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:YES];
    }];
    
    [self.myPickerView reloadAllComponents];
}

- (IBAction)targetWeightClicked:(id)sender {
    self.clickedViewIndex = TargetWeightViewIndex;
    
    [self textFieldNameResignFirstResponder];
    
    if ([self isShowInputView]) {
        [UIView animateWithDuration:0.5 animations:^{
            [self showInputView:NO];
        }];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:YES];
    }];
    
    [self.myPickerView reloadAllComponents];
}

- (void)cancelClicked:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:NO];
    }];
}
- (void)confirmClicked:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:NO];
    }];
    
    NSInteger row = [self.myPickerView selectedRowInComponent:0];
    if (self.clickedViewIndex == HeightViewIndex) {
        self.labelHeightValue.text = [NSString stringWithFormat:@"%@%@",self.heightArray[row],NSLocalizedString(@"cm",nil)];
        return;
    }
    if (self.clickedViewIndex == CurrentWeightViewIndex) {
        self.labelCurrentWeight.text = [NSString stringWithFormat:@"%@%@",self.weightArray[row],NSLocalizedString(@"kg",nil)];
        return;
    }
    if (self.clickedViewIndex == TargetWeightViewIndex) {
        self.labelTargetWeight.text = [NSString stringWithFormat:@"%@%@",self.weightArray[row],NSLocalizedString(@"kg",nil)];
        return;
    }
    if (self.clickedViewIndex == BirthdayViewIndex) {
        DEBUGLog(@"Birthday:%@",self.myDatePicker.date);
        NSDate *date = self.myDatePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//@"yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.dateFormat = @"yyyy";
        NSString *strYear = [dateFormatter stringFromDate:date];
        dateFormatter.dateFormat = @"MM";
        NSString *strMonth = [dateFormatter stringFromDate:date];
        dateFormatter.dateFormat = @"dd";
        NSString *strDay = [dateFormatter stringFromDate:date];
        //DEBUGLog(@"Birthday year:%@,month:%@,day:%@",strYear,strMonth,strDay);
        self.labelBirthdayYear.text = [NSString stringWithFormat:@"%@%@",strYear,NSLocalizedString(@"Year",nil)];
        self.labelBirthdayMonth.text = [NSString stringWithFormat:@"%@%@%@%@",strMonth,NSLocalizedString(@"Month",nil),strDay,NSLocalizedString(@"Day",nil)];
        
        return;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self isShowInputView]) {
        [self showInputView:NO];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerViewDataSource
//返回有几个部分
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return COMPONENT_NUMBER;
}
//返回pickerView的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count = 0;
    if (self.clickedViewIndex == HeightViewIndex) {
        count = self.heightArray.count;
    } else if (self.clickedViewIndex == CurrentWeightViewIndex) {
        count = self.weightArray.count;
    } else if (self.clickedViewIndex == TargetWeightViewIndex) {
        count = self.weightArray.count;
    }
    
    if (component == 0) {
        return count;
    }
    return 1;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return COMPONENT_WIDTH;
    }
    return COMPONENT_WIDTH;
}

//返回值写入pickerView中
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //DEBUGLog(@"pickerView string");
    if (self.clickedViewIndex == HeightViewIndex) {
        if (component == 0) {
            return self.heightArray[row];
        }
        return HeightUnit;
        
    } else if (self.clickedViewIndex == CurrentWeightViewIndex ||
               self.clickedViewIndex == TargetWeightViewIndex) {
        if (component == 0) {
            return self.weightArray[row];
        }
        return WeightUnit;
    }
    
    return nil;
}

@end
