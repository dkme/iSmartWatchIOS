//
//  WMSUpdateVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSUpdateVC.h"

#import "WMSNavBarView.h"

#import "WMSFileMacro.h"

@interface WMSUpdateVC ()

@end

@implementation WMSUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupNavBarView];
    [self setupTextView];
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

#pragma mark - setup UI
- (void)setupNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
    self.navBarView.labelTitle.text = self.navBarTitle;
    self.navBarView.labelTitle.font = Font_DINCondensed(20.0);
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setupTextView
{
    NSString *txt = [NSString stringWithFormat:@"%@:\n     %@",NSLocalizedString(@"更新说明",nil),_updateDescribe];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.text = txt;
    self.textView.editable = NO;
}
- (void)setupUI
{
    UIImage *image = [UIImage imageNamed:@"zq_public_green_btn_a.png"];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
    frame.origin.x = (ScreenWidth-frame.size.width)/2.0;
    frame.origin.y = ScreenHeight-frame.size.height-10.0;
    [self.buttonUpdate setFrame:frame];
    [self.buttonUpdate setBackgroundImage:image forState:UIControlStateNormal];
    [self.buttonUpdate setBackgroundImage:[UIImage imageNamed:@"zq_public_green_btn_b.png"] forState:UIControlStateSelected];
    [self.buttonUpdate setTitle:NSLocalizedString(@"立即更新", nil) forState:UIControlStateNormal];
    [self.buttonUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAction:(id)sender {
    NSFileHandle *inFile = [NSFileHandle fileHandleForReadingAtPath:FileTmpPath(FILE_TMP_FIRMWARE_UPDATE)];
    if (inFile) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            DEBUGLog(@"file data:{%@}",[inFile readDataToEndOfFile]);
        });
        return ;
    }
}
@end
