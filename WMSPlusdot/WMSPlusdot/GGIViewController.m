//
//  GGIViewController.m
//  Camera
//
//  Created by Sir on 14-9-27.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "GGIViewController.h"
#import "CameraImageHelper.h"
#import "UIImage+QuartzProc.h"
#import "MWPhotoBrowser.h"

#define ScreenWidth  ( [[UIScreen mainScreen] bounds].size.width )
#define ScreenHeight ( [[UIScreen mainScreen] bounds].size.height )


@interface GGIViewController () <AVHelperDelegate, MWPhotoBrowserDelegate>

@property(retain,nonatomic) CameraImageHelper *CameraHelper;

@property (strong,nonatomic) UIButton *buttonCamera;
@property (strong,nonatomic) UIButton *buttonFlashMode;
@property (strong,nonatomic) UIButton *buttonTakePhoto;
@property (strong,nonatomic) UIButton *buttonImageView;

@property (copy,   nonatomic) NSMutableArray *assets;
@property (copy,   nonatomic) NSMutableArray *photos;
@property (copy,   nonatomic) NSMutableArray *thumbs;
@property (strong, nonatomic) ALAssetsLibrary *ALAssetsLibrary;
@property (strong, nonatomic) MWPhotoBrowser *browser;

@end

@implementation GGIViewController
{
    BOOL isFrontCamera;//yes为前，no为后
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _liveView = [[UIView alloc] initWithFrame:CGRectMake(0,40,320,465)];
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-230)/2,10,230,30)];
    _textLabel.text = @"";
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = [UIColor whiteColor];
    
    UIImage *image = [UIImage imageNamed:@"close_cha_h.png"];
    CGSize size = image.size;//CGSizeMake(image.size.width/2, image.size.height/2);
    CGPoint or = CGPointMake((ScreenWidth-size.width)/2.0, ScreenHeight-size.height-15);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){or,size};
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    isFrontCamera = NO;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(ScreenWidth-30-15, 10, 30, 25);
    [button2 setBackgroundImage:[UIImage imageNamed:@"switch_camera.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(15, 10, 30, 25);
    [button3 setBackgroundImage:[UIImage imageNamed:@"flashing_auto.png"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(10, ScreenHeight-50-5, 50, 50);
    button4.layer.borderWidth = 0.5;
    button4.layer.borderColor = [UIColor whiteColor].CGColor;
    [button4 setBackgroundColor:[UIColor clearColor]];
    [button4 addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonImageView:button4];
    
    [self.view addSubview:_liveView];
    [self.view addSubview:_textLabel];
    [self.view addSubview:button];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
    [self.view addSubview:button4];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _CameraHelper = [[CameraImageHelper alloc] init];
    _CameraHelper.delegate = self;
    // 开始实时取景
    [_CameraHelper startRunning];
    [_CameraHelper embedPreviewInView:self.liveView];
//    [_CameraHelper switchCamera:NO];
//    [_CameraHelper switchFlashMode:CameraFlashModeAuto];

    [_CameraHelper changePreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)takePhoto
{
    [_CameraHelper CaptureStillImage];
}

#pragma mark - Action
- (void)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(GGIViewControllerDidClose:)]) {
            [self.delegate GGIViewControllerDidClose:self];
        }
    }];
}

- (void)switchCamera:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (isFrontCamera) {//切换至后摄像头
        [button setBackgroundImage:[UIImage imageNamed:@"switch_camera.png"] forState:UIControlStateNormal];
        isFrontCamera = NO;
        [_CameraHelper switchCamera:NO];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"switch_camera_h.png"] forState:UIControlStateNormal];
        isFrontCamera = YES;
        [_CameraHelper switchCamera:YES];
    }
    
    [self flip];
    
}

- (void)flip
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.liveView cache:YES];
    [UIView commitAnimations];
}

- (void)switchFlash:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([self.CameraHelper currentFlashMode] == CameraFlashModeAuto) {
        [button setBackgroundImage:[UIImage imageNamed:@"flashing_on.png"] forState:UIControlStateNormal];
        [_CameraHelper switchFlashMode:CameraFlashModeOn];
    } else if ([self.CameraHelper currentFlashMode] == CameraFlashModeOn)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"flashing_off.png"] forState:UIControlStateNormal];
        [_CameraHelper switchFlashMode:CameraFlashModeOff];
    } else if ([self.CameraHelper currentFlashMode] == CameraFlashModeOff)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"flashing_auto.png"] forState:UIControlStateNormal];
        [_CameraHelper switchFlashMode:CameraFlashModeAuto];
    }
}

- (void)clickImage:(id)sender
{
    UIImage *image = [(UIButton *)sender backgroundImageForState:UIControlStateNormal];
    if (image) {
//        if (self.delegate &&
//            [self.delegate respondsToSelector:@selector(GGIViewController:didClickImage:)])
//        {
//            [self.delegate GGIViewController:self didClickImage:image];
//        }
        if (!self.browser) {
            MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            photoBrowser.displayActionButton = NO;
            [photoBrowser setCurrentPhotoIndex:0];
            self.browser = photoBrowser;
        }
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
        
        [self loadAssets];
//        [self reloadData];
    }
}

- (void)reloadData
{
    NSMutableArray *photos = [NSMutableArray new];
    NSMutableArray *thumbs = [NSMutableArray new];
    @synchronized(_assets) {
        NSArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                [photos addObject:photo];
                MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                [thumbs addObject:thumb];
                if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                    photo.videoURL = asset.defaultRepresentation.url;
                    thumb.isVideo = true;
                }
            }
        }
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    [self.browser reloadData];
}

#pragma mark - AVHelperDelegate
- (void)didFinishedCapture:(UIImage*)_img
{
    UIImageWriteToSavedPhotosAlbum(_img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    CGSize toSize = CGSizeZero;
    CGSize targetSize = self.buttonImageView.bounds.size;
    toSize.width = targetSize.width*2;
    toSize.height = targetSize.height*2;
//    UIImage *newImage = [image resizeImageToSize:toSize resizeMode:quartzImageResizeAspectFill];
//    [self.buttonImageView setBackgroundImage:newImage forState:UIControlStateNormal];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,targetSize.width/2,targetSize.height/2}];
    imageView.center = self.buttonImageView.center;
    imageView.tag = 100;
    imageView.layer.borderWidth = 0.5;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.image = [image resizeImageToSize:toSize resizeMode:quartzImageResizeAspectFill];
    [self.view addSubview:imageView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:)];
    imageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    [UIView commitAnimations];
}

- (void)animationDidStop:(id)sender
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:100];
    [imageView removeFromSuperview];
    
    CGSize toSize = CGSizeZero;
    CGSize targetSize = self.buttonImageView.bounds.size;
    toSize.width = targetSize.width * 2;
    toSize.height = targetSize.height * 2;
    UIImage *newImage = [_CameraHelper.image resizeImageToSize:toSize resizeMode:quartzImageResizeAspectFill];
    [self.buttonImageView setBackgroundImage:newImage forState:UIControlStateNormal];
}

#pragma mark - Assets
- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
    } else {
        // Assets library
        [self performLoadAssets];
    }
}
- (void)performLoadAssets {
    // Initialise
    _assets = [NSMutableArray new];
    // Load
    if (NSClassFromString(@"PHAsset")) {
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
            if (fetchResults.count > 0) {
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        });
    } else {
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                      if (_assets.count == 1) {
                                                          // Added first asset so reload data
                                                          [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                                      }
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             DEBUGLog(@"operation was not successfull!");
                                         }];
                        
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              DEBUGLog(@"There is an error");
                                          }];
            
        });
        
    }
    
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    DEBUGLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup status bar appearance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
