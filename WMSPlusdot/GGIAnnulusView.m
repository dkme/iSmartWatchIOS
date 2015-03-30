//
//  GGIAnnulusView.m
//  MyView
//
//  Created by Sir on 14-10-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "GGIAnnulusView.h"

#define PROGRESS_WIDTH      25.f
#define RADIUS              98.f
#define START_ANGLE         (-220.0)
#define END_ANGLE           (40.0)
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成弧度的方式
#define radiansToDegrees(x) (180.0*(x)/M_PI)

@implementation GGIAnnulusView
{
    CAShapeLayer *layer;
    CALayer *contain;
    
    NSUInteger mySleepMinute;
    NSUInteger myDeepSleepMinute;
    NSUInteger myLightSleepMinute;
    NSUInteger myWakeupMinute;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIBezierPath *path;
    path=[UIBezierPath bezierPath];
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [path addArcWithCenter:center radius:RADIUS startAngle:degreesToRadians(START_ANGLE) endAngle:degreesToRadians(END_ANGLE) clockwise:YES];
    
    //底色
    CAShapeLayer *underLayer = [CAShapeLayer layer];
    underLayer.strokeColor = [UIColor whiteColor].CGColor;//UIColorFromRGBAlpha(0x2EC4DD, 1.0).CGColor;
    underLayer.fillColor = [UIColor clearColor].CGColor;
    underLayer.frame = self.bounds;
    underLayer.lineWidth = PROGRESS_WIDTH;
    underLayer.path = path.CGPath;
    underLayer.strokeEnd = 1.0;
    [self.layer addSublayer:underLayer];
    
    //上层色
    layer=[CAShapeLayer layer];
    layer.strokeColor=[UIColor redColor].CGColor;
    layer.fillColor=[UIColor clearColor].CGColor;
    layer.frame=self.bounds;
    layer.lineWidth=PROGRESS_WIDTH;
    layer.path=path.CGPath;
    layer.strokeEnd=0;
    
    contain=[CALayer layer];
    contain.frame=self.bounds;
    contain.mask=layer;
    [self.layer addSublayer:contain];
}

-(UIImage*)getArcImageWithSize:(CGSize)size andCenter:(CGPoint)pt andRadius:(CGFloat)radius andColors:(NSArray*)colors andAngle:(NSArray*)angles
{
    CGSize sz = CGSizeZero;
    sz.width = size.width * 1.0f;
    sz.height = size.height * 1.0f;
    UIGraphicsBeginImageContextWithOptions(sz, NO, 0.0);
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextSaveGState(con);
    
    UIBezierPath *path;
    CGFloat startAngle,endAngle;
    
    //第一段弧
    startAngle=degreesToRadians(START_ANGLE);
    endAngle=startAngle+[(NSNumber*)angles[0] floatValue];
    path=[UIBezierPath bezierPath];
    [path addArcWithCenter:pt radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [(UIColor*)colors[0] set];
    path.lineCapStyle=kCGLineCapButt;
    path.lineWidth=PROGRESS_WIDTH;
    [path stroke];

    //第二段弧
    startAngle=endAngle;
    endAngle=startAngle+[(NSNumber*)angles[1] floatValue];
    path=[UIBezierPath bezierPath];
    [path addArcWithCenter:pt radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [(UIColor*)colors[1] set];
    path.lineCapStyle=kCGLineCapButt;
    path.lineWidth=PROGRESS_WIDTH;
    [path stroke];

    //第三段弧
    startAngle=endAngle;
    endAngle=startAngle+[(NSNumber*)angles[2] floatValue];
    path=[UIBezierPath bezierPath];
    [path addArcWithCenter:pt radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [(UIColor*)colors[2] set];
    path.lineCapStyle=kCGLineCapButt;
    path.lineWidth=PROGRESS_WIDTH;
    [path stroke];

    UIImage* im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return im;
}

#pragma mark - Public Methods
- (void)setAnnulusColors:(NSArray *)colors andAngle:(NSArray*)angles
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGSize size = self.bounds.size;
    UIImage *img=[self getArcImageWithSize:size andCenter:center andRadius:RADIUS andColors:colors andAngle:angles];
    contain.contents=(id)img.CGImage;
    
    
    layer.strokeEnd=1;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue=@(0);
    animation.toValue=@(1);
    
    animation.duration = 2.0;
    [layer addAnimation:animation forKey:@"strokeEnd"];
}

- (void)setAnnulusColors:(NSArray *)colors andPercents:(NSArray*)percents
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGSize size = self.bounds.size;
    
    NSMutableArray *angles = [NSMutableArray arrayWithCapacity:1];
    float total = degreesToRadians(END_ANGLE-START_ANGLE);
    for (NSNumber *number in percents) {
        float per= [number floatValue];
        [angles addObject:@(per*total)];
    }
    
    UIImage *img=[self getArcImageWithSize:size andCenter:center andRadius:RADIUS andColors:colors andAngle:angles];
    contain.contents=(id)img.CGImage;
    
    
    layer.strokeEnd=1;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue=@(0);
    animation.toValue=@(1);
    
    animation.duration = 1.0;
    [layer addAnimation:animation forKey:@"strokeEnd"];
}

@end
