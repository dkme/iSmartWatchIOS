//
//  WMSMyAccountViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMyAccountViewController.h"
#import "WMSNavBarView.h"
#import "WMSAppDelegate.h"
#import "WMSPersonModel.h"
#import "NSDate+Formatter.h"
#import "WMSMyAccessory.h"
#import "WMSBindingAccessoryViewController.h"
#import "MBProgressHUD.h"
#import "WMSLeftViewController.h"
#import "RESideMenu.h"
#import "UIImage+QuartzProc.h"

#define PickerViewHeight    216.f
#define DatePickerHeight    PickerViewHeight
#define ToolbarHeight       44.f

#define HeightViewIndex             100
#define BirthdayViewIndex           101
#define CurrentWeightViewIndex      102
#define TargetWeightViewIndex       103

#define HeightMinValue  100
#define HeightMaxValue  300
#define WeightMinValue  35
#define WeightMaxValue  220

#define HeightUnit      @"cm"
#define WeightUnit      @"kg"

#define COMPONENT_NUMBER 2
#define COMPONENT_WIDTH  50.f

#define StrideWithGender(gender,height) ( gender ? 0.415*height : 0.413*height )

#define ButtonSavaFrame ( CGRectMake((ScreenWidth-610/2.0)/2, (ScreenHeight-99/2.0-30), 610/2.0, 99/2.0) )

@interface WMSMyAccountViewController ()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
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
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserImage;
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
@property (strong, nonatomic) UIButton *buttonSava;

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
{
    int mySex;//1表示男，0表示女
    int myHeight;
    int myBirthdayYear;
    int myBirthdayMonth;
    int myBirthdayDay;
    int myCurrentWeight;
    int myTargetWeight;
    NSString *myName;
    UIImage *myImage;
}

#pragma mark - Getter
- (UIPickerView *)myPickerView
{
    if (!_myPickerView) {
        _myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, PickerViewHeight)];
        _myPickerView.backgroundColor = [UIColor whiteColor];
        //_myPickerView.alpha = 1.0;
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
        //NSDictionary *attributes = @{NSFontAttributeName:Font_DINCondensed(20)};
        //[leftBarButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
        //[rightBarButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        NSArray *buttons = @[leftBarButton,flexibleSpace,rightBarButton];
        
        [_myToolbar setItems:buttons animated:YES];
    }
    return _myToolbar;
}

- (UIButton *)buttonSava
{
    if (!_buttonSava) {
        _buttonSava = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonSava.backgroundColor = [UIColor clearColor];
        _buttonSava.frame = ButtonSavaFrame;
        [_buttonSava setTitle:@"保存信息" forState:UIControlStateNormal];
        [_buttonSava setBackgroundImage:[UIImage imageNamed:@"sava_info_btn_a.png"] forState:UIControlStateNormal];
        [_buttonSava setBackgroundImage:[UIImage imageNamed:@"sava_info_btn_b.png"] forState:UIControlStateHighlighted];
        [_buttonSava addTarget:self action:@selector(savaInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _buttonSava;
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
        for (int i=HeightMinValue; i<=HeightMaxValue; i++) {
            [_heightArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _heightArray;
}
- (NSMutableArray *)weightArray
{
    if (!_weightArray) {
        _weightArray = [[NSMutableArray alloc] init];
        for (int i=WeightMinValue; i<=WeightMaxValue; i++) {
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
    
//    if (!self.isModifyAccount) {
//        [self.view addSubview:self.buttonSava];
//    }
    if (self.isNewUser) {
        self.navBarView.buttonLeft.hidden = YES;
        [self.view addSubview:self.buttonSava];
    } else {
        self.navBarView.buttonLeft.hidden = NO;
    }
    
    [self.view addSubview:self.myPickerView];
    [self.view addSubview:self.myDatePicker];
    [self.view addSubview:self.myToolbar];
    
    
    DEBUGLog(@"datePicker frame:%f,%f",self.myDatePicker.bounds.size.width,self.myDatePicker.bounds.size.height);
    
    
    _pickerViewComponent1Array = [NSMutableArray arrayWithArray:@[@"170",@"180",@"170",@"180"]];
    
    [self setupControl];
    
    [self localized];
    
    [self loadData];
    [self updateViews];
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
    [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"unselect_man.png"] forState:UIControlStateNormal];
    [self.buttonMan addTarget:self action:@selector(buttonManClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.buttonWoman setTitle:@"" forState:UIControlStateNormal];
    [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"unselect_woman.png"] forState:UIControlStateNormal];
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

//更新对应的视图
- (void)updateViews
{
    self.textFieldName.text = myName;
    if (myImage) {
        self.imageViewUserImage.image = myImage;
    }
    
    if (mySex == 1) {
        self.labelSex.text = NSLocalizedString(@"Male",nil);
        [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"select_man.png"] forState:UIControlStateNormal];
        [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"unselect_woman.png"] forState:UIControlStateNormal];
    } else if (mySex == 0) {
        self.labelSex.text = NSLocalizedString(@"Female",nil);
        [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"select_woman.png"] forState:UIControlStateNormal];
        [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"unselect_man.png"] forState:UIControlStateNormal];
    }
    
    self.labelHeightValue.text = [NSString stringWithFormat:@"%d%@",myHeight,NSLocalizedString(@"cm",nil)];
    self.labelCurrentWeight.text = [NSString stringWithFormat:@"%d%@",myCurrentWeight,NSLocalizedString(@"kg",nil)];
    self.labelTargetWeight.text = [NSString stringWithFormat:@"%d%@",myTargetWeight,NSLocalizedString(@"kg",nil)];
    
    self.labelBirthdayYear.text = [NSString stringWithFormat:@"%d%@",myBirthdayYear,NSLocalizedString(@"Year",nil)];
    self.labelBirthdayMonth.text = [NSString stringWithFormat:@"%d%@%d%@",myBirthdayMonth,NSLocalizedString(@"Month",nil),myBirthdayDay,NSLocalizedString(@"Day",nil)];
}

#pragma mark - Data
//加载初始数据
- (void)loadData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    myName = [userDefaults stringForKey:@"name"];
    if (!myName || [myName isEqualToString:@""]) {//若为@""，则使用登陆时的用户名
        NSDictionary *readData =  [NSDictionary dictionaryWithContentsOfFile:FilePath(UserInfoFile)];
        myName = [readData objectForKey:@"userName"];
    }
    myImage = [UIImage imageWithData:[userDefaults dataForKey:@"image"]];
    NSDate *birthday = [userDefaults valueForKey:@"birthday"];
    mySex = [userDefaults integerForKey:@"gender"];
    myHeight = [userDefaults integerForKey:@"height"];
    myCurrentWeight = [userDefaults integerForKey:@"currentWeight"];
    myTargetWeight = [userDefaults integerForKey:@"targetWeight"];
    
    myBirthdayYear = [NSDate yearOfDate:birthday];
    myBirthdayMonth = [NSDate monthOfDate:birthday];
    myBirthdayDay = [NSDate dayOfDate:birthday];
    
    if (myHeight <= 0) {
        myHeight = 170;
    }
    if (myCurrentWeight <= 0) {
        myCurrentWeight = 60;
    }
    if (myTargetWeight <= 0) {
        myTargetWeight = 60;
    }
    if (myBirthdayYear <= 0) {
        myBirthdayYear = 1970;
    }
    if (myBirthdayMonth <= 0) {
        myBirthdayMonth = 1;
    }
    if (myBirthdayDay <= 0) {
        myBirthdayDay = 1;
    }
}
//保存用户信息
- (void)savaPersonInfoBirthday:(NSDate *)birthday stride:(NSUInteger)stride
{
    WMSPersonModel *personModel = [[WMSPersonModel alloc] initWithName:myName image:myImage birthday:birthday gender:mySex height:myHeight currentWeight:myCurrentWeight targetWeight:myTargetWeight stride:stride];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:personModel.name forKey:@"name"];
    [userDefaults setObject:UIImagePNGRepresentation(personModel.image) forKey:@"image"];
    [userDefaults setObject:personModel.birthday forKey:@"birthday"];
    [userDefaults setInteger:personModel.gender forKey:@"gender"];
    [userDefaults setInteger:personModel.height forKey:@"height"];
    [userDefaults setInteger:personModel.currentWeight forKey:@"currentWeight"];
    [userDefaults setInteger:personModel.targetWeight forKey:@"targetWeight"];
    [userDefaults setInteger:personModel.stride forKey:@"stride"];
}


#pragma mark - 隐藏与显示输入视图
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
    myName = self.textFieldName.text;
}

//校验昵称是否为空
- (BOOL)checkUserName
{
    if (myName == nil || [@"" isEqualToString:myName]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        //hud.labelFont = Font_DINCondensed(10.0);
        hud.labelText = NSLocalizedString(@"个性签名不能为空", nil);
        hud.mode = MBProgressHUDModeText;
        hud.minSize = CGSizeMake(250, 60);
        //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
        hud.yOffset = ScreenHeight/2.0-60;
        hud.xOffset = 0;
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [hud removeFromSuperview];
        }];
        
        return NO;
    }
    return YES;
}

#pragma mark - 相机，相片库
- (void)openCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return ;
    }
    UIImagePickerControllerSourceType sourceType;
    sourceType=UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    //设置图像选取控制器的类型为静态图像
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    picker.allowsEditing=YES;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)openPhotoLibrary
{
    UIImagePickerControllerSourceType sourceType;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return ;
    }
    
    sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing=YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
//    if (self.isModifyAccount) {
//        WMSLeftViewController *leftVC = (WMSLeftViewController *)((RESideMenu *)self.presentingViewController).leftMenuViewController;
//        [leftVC setUserImage:myImage];
//        [leftVC setUserNickname:myName];
//        
//        [self savaInfoAction:nil];
//        return;
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
    WMSLeftViewController *leftVC = (WMSLeftViewController *)((RESideMenu *)self.presentingViewController).leftMenuViewController;
    [leftVC setUserImage:myImage];
    [leftVC setUserNickname:myName];
    
    [self savaInfoAction:nil];
}

- (void)buttonManClicked:(id)sender
{
    self.labelSex.text = NSLocalizedString(@"Man",nil);
    mySex = 1;
    [self updateViews];
}

- (void)buttonWomanClicked:(id)sender
{
    self.labelSex.text = NSLocalizedString(@"Woman",nil);
    mySex = 0;
    [self updateViews];
}

- (IBAction)imageViewClicked:(id)sender {
    DEBUGLog(@"选取头像");
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil),NSLocalizedString(@"选取照片", nil), nil];//没有红色按钮
    [actionSheet showInView:self.view];
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
    [self.myPickerView selectRow:(myHeight-HeightMinValue) inComponent:0 animated:NO];
}

- (IBAction)birthdayClicked:(id)sender {
    self.clickedViewIndex = BirthdayViewIndex;
    
    [self textFieldNameResignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:YES];
    }];
    
    NSString *datestring = [NSString stringWithFormat:@"%04d-%02d-%02d",
                            myBirthdayYear,myBirthdayMonth,myBirthdayDay];
    NSDateFormatter *dm = [[NSDateFormatter alloc]init];
    dm.dateFormat = @"yyyy-MM-dd";
    NSDate *newdate = [dm dateFromString:datestring];
    [self.myDatePicker setDate:newdate animated:NO];
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
    [self.myPickerView selectRow:(myCurrentWeight-WeightMinValue) inComponent:0 animated:NO];
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
    [self.myPickerView selectRow:(myTargetWeight-WeightMinValue) inComponent:0 animated:NO];
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
        
        myHeight = [self.heightArray[row] intValue];
        
        return;
    }
    if (self.clickedViewIndex == CurrentWeightViewIndex) {
        self.labelCurrentWeight.text = [NSString stringWithFormat:@"%@%@",self.weightArray[row],NSLocalizedString(@"kg",nil)];
        
        myCurrentWeight = [self.weightArray[row] intValue];
        
        return;
    }
    if (self.clickedViewIndex == TargetWeightViewIndex) {
        myTargetWeight = [self.weightArray[row] intValue];
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
        
        myBirthdayYear = [strYear intValue];
        myBirthdayMonth = [strMonth intValue];
        myBirthdayDay = [strDay intValue];
        
        return;
    }
}

- (void)savaInfoAction:(id)sender
{
    //校验姓名是否为空
    if ([self checkUserName] == NO) {
        return;
    }
    
    NSString *strBirthday = [NSString stringWithFormat:@"%04d-%02d-%02d",
                             myBirthdayYear,myBirthdayMonth,myBirthdayDay];
    float floatStride = StrideWithGender(mySex, myHeight);
    int stride = Rounded(floatStride);
    NSDate *birthday = [NSDate dateFromString:strBirthday format:@"yyyy-MM-dd"];
    
    [self savaPersonInfoBirthday:birthday stride:stride];
    
//    if (self.isModifyAccount) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    } else {
//        WMSBindingAccessoryViewController *vc = (WMSBindingAccessoryViewController *)self.presentingViewController;
//        vc.isSavaUserInfo = YES;
//        [self dismissViewControllerAnimated:YES completion:^{
//            //DEBUGLog(@"bind VC:%@",vc);
//            [vc dismissVC];
//        }];
//    }
    
    if (self.isNewUser) {
        [WMSAppDelegate appDelegate].window.rootViewController = (UIViewController *)[WMSAppDelegate appDelegate].reSideMenu;
        [WMSAppDelegate appDelegate].loginNavigationCtrl = nil;
        [[WMSAppDelegate appDelegate].window makeKeyAndVisible];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];//获取用户编辑之后的图像
        //UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //将该图像保存到媒体库中
        //UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        
        //显示用户image
        CGSize toSize = CGSizeZero;
        toSize.width = self.imageViewUserImage.bounds.size.width*2;
        toSize.height = self.imageViewUserImage.bounds.size.height*2;
        self.imageViewUserImage.image = [image resizeImageToSize:toSize resizeMode:quartzImageResizeAspectFit];
        myImage = self.imageViewUserImage.image;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DEBUGLog(@"actionSheet buttonIndex:%d",buttonIndex);
    if (buttonIndex == 0) {//拍照
        [self openCamera];
    } else if (buttonIndex == 1) {//选取照片
        [self openPhotoLibrary];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ;
    } else if (buttonIndex == 1) {//保存数据，关闭视图
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
        
        NSString *strBirthday = [NSString stringWithFormat:@"%04d-%02d-%02d",
                                myBirthdayYear,myBirthdayMonth,myBirthdayDay];
        float floatStride = StrideWithGender(mySex, myHeight);
        int stride = Rounded(floatStride);
        
        
        [bleControl.settingProfile setPersonInfoWithWeight:myCurrentWeight withHeight:myHeight withGender:mySex withBirthday:strBirthday withDateFormat:@"yyyy-MM-dd" withStride:stride withMetric:LengthUnitTypeMetricSystem withCompletion:^(BOOL success)
        {
            DEBUGLog(@"设置个人信息%@",success?@"成功":@"失败");
            
            NSDate *birthday = [NSDate dateFromString:strBirthday format:@"yyyy-MM-dd"];
            
            [self savaPersonInfoBirthday:birthday stride:stride];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self textFieldNameResignFirstResponder];
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
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
//          forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    mycom1 = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
//    
//    NSString *imgstr1 = [[NSString alloc] initWithFormat:@"%d", row];
//    mycom1.text = imgstr1;
//    [mycom1 setFont:[UIFont boldSystemFontOfSize:30]];
//    mycom1.backgroundColor = [UIColor clearColor];
//    CFShow(mycom1);
//    [imgstr1 release];
//    
//    return mycom1;
//}

@end
