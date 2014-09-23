//
//  UIImage.h
//  QuartzDemo
//
//  Created by macbook pro on 13-12-11.
//  Copyright (c) 2013年 zq liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <QuartzCore/QuartzCore.h>

enum {
    quartzImageRotationProcessClip,   // 原图尺寸，超出边界部分截掉
    quartzImageRotationProcessExpand   // 扩展原图尺寸，容纳超出原边界部分
};
typedef NSInteger QuartzImageRotationProcessMode;

enum {
    quartzImageResizeScale,            // 充满目标尺寸
    quartzImageResizeAspectFit,        // 按比例适应目标尺寸
    quartzImageResizeAspectFill,       // 按比例充满目标尺寸
};
typedef NSInteger quartzImageResizeMode;

@interface UIImage (QuartzProc)

-(UIImage*)rotateImageWithRadian:(CGFloat)radian processMode:(QuartzImageRotationProcessMode)procMode;
-(UIImage*)cropImageWithRect:(CGRect)cropRect;
-(UIImage*)cropImageWithPath:(NSArray*)pointArr;
-(UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(quartzImageResizeMode)resizeMode;
-(BOOL)getImageData:(void**)data width:(NSInteger*)width height:(NSInteger*)height alphaInfo:(CGImageAlphaInfo*)alphaInfo;

+(UIImage*)createImageWithData:(Byte*)data width:(NSInteger)width height:(NSInteger)height alphaInfo:(CGImageAlphaInfo)alphaInfo;

@end
