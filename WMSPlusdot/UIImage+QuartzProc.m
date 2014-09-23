//
//  UIImage.m
//  QuartzDemo
//
//  Created by macbook pro on 13-12-11.
//  Copyright (c) 2013年 zq liu. All rights reserved.
//

#import "UIImage+QuartzProc.h"

@implementation UIImage (QuartzProc)

-(UIImage*)rotateImageWithRadian:(CGFloat)radian processMode:(QuartzImageRotationProcessMode)procMode
{
    CGSize imgSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    CGSize outputSize = imgSize;
    if (procMode == quartzImageRotationProcessExpand) {
        CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(radian));
        outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    UIGraphicsBeginImageContext(outputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, radian);
    CGContextTranslateCTM(context, -imgSize.width / 2, -imgSize.height / 2);
    
    [self drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)cropImageWithRect:(CGRect)cropRect
{
    CGRect drawRect = CGRectMake(-cropRect.origin.x , -cropRect.origin.y, self.size.width * self.scale, self.size.height * self.scale);
    
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
    
    [self drawInRect:drawRect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)cropImageWithPath:(NSArray*)pointArr
{
    if (pointArr.count == 0) {
        return nil;
    }
    
    CGPoint *points = malloc(sizeof(CGPoint) * pointArr.count);
    for (int i = 0; i < pointArr.count; ++i) {
        points[i] = [[pointArr objectAtIndex:i] CGPointValue];
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * self.scale, self.size.height * self.scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextAddLines(context, points, pointArr.count);
    CGContextClosePath(context);
    CGRect boundsRect = CGContextGetPathBoundingBox(context);
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(boundsRect.size);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, boundsRect.size.width, boundsRect.size.height));
    
    CGMutablePathRef  path = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-boundsRect.origin.x, -boundsRect.origin.y);
    CGPathAddLines(path, &transform, points, pointArr.count);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    [self drawInRect:CGRectMake(-boundsRect.origin.x, -boundsRect.origin.y, self.size.width * self.scale, self.size.height * self.scale)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGPathRelease(path);
    free(points);
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(quartzImageResizeMode)resizeMode
{
    CGRect drawRect = [self caculateDrawRect:newSize resizeMode:resizeMode];

    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
    
    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
    
    [self drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(CGRect)caculateDrawRect:(CGSize)newSize resizeMode:(quartzImageResizeMode)resizeMode
{
    CGRect drawRect = CGRectMake(0, 0, newSize.width, newSize.height);
    CGFloat imageRatio = self.size.width / self.size.height;
    CGFloat newSizeRatio = newSize.width / newSize.height;
    
    switch (resizeMode) {
        case quartzImageResizeScale:
        {
            break;
        }
        case quartzImageResizeAspectFit:
        {
            CGFloat newHeight = 0;
            CGFloat newWidth = 0;
            if (newSizeRatio >= imageRatio) {
                newHeight = newSize.height;
                newWidth = newHeight * imageRatio;
            }
            else {
                newWidth = newSize.width;
                newHeight = newWidth / imageRatio;
            }
            drawRect.size.width = newWidth;
            drawRect.size.height = newHeight;
            
            drawRect.origin.x = newSize.width / 2 - newWidth / 2;
            drawRect.origin.y = newSize.height / 2 - newHeight / 2;
            break;
        }
        case quartzImageResizeAspectFill:
        {
            CGFloat newHeight = 0;
            CGFloat newWidth = 0;
            if (newSizeRatio >= imageRatio) {
                newWidth = newSize.width;
                newHeight = newWidth / imageRatio;
            }
            else {
                newHeight = newSize.height;
                newWidth = newHeight * imageRatio;
            }
            drawRect.size.width = newWidth;
            drawRect.size.height = newHeight;
            
            drawRect.origin.x = newSize.width / 2 - newWidth / 2;
            drawRect.origin.y = newSize.height / 2 - newHeight / 2;
            break;
        }
        default:
            break;
    }
    
    return drawRect;
}

-(BOOL)getImageData:(void**)data width:(NSInteger*)width height:(NSInteger*)height alphaInfo:(CGImageAlphaInfo*)alphaInfo
{
    int imgWidth = self.size.width * self.scale;
    int imgHegiht = self.size.height * self.scale;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    if (colorspace == NULL) {
        NSLog(@"Create Colorspace Error!");
        return NO;
    }
    
    void *imgData = NULL;
    imgData = malloc(imgWidth * imgHegiht * 4);
    if (imgData == NULL) {
        NSLog(@"Memory Error!");
        CGColorSpaceRelease(colorspace);
        return NO;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    #define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
    #define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif
    CGContextRef bmpContext = CGBitmapContextCreate(imgData, imgWidth, imgHegiht, 8, imgWidth * 4, colorspace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(bmpContext, CGRectMake(0, 0, imgWidth, imgHegiht), self.CGImage);
    
    *data = CGBitmapContextGetData(bmpContext);
    *width = imgWidth;
    *height = imgHegiht;
    *alphaInfo = kCGImageAlphaLast;
    
    CGColorSpaceRelease(colorspace);
    CGContextRelease(bmpContext);
    
    return YES;
}

+(UIImage*)createImageWithData:(Byte*)data width:(NSInteger)width height:(NSInteger)height alphaInfo:(CGImageAlphaInfo)alphaInfo
{
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if (!colorSpaceRef) {
        NSLog(@"Create ColorSpace Error!");
    }
    CGContextRef bitmapContext = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    if (!bitmapContext) {
        NSLog(@"Create Bitmap context Error!");
        CGColorSpaceRelease(colorSpaceRef);
        return nil;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(bitmapContext);
    
    return image;
}

@end
