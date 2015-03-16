//
//  WMSMySportView.m
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMySportView.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)    //角度转弧度
#define PROGRESS_WIDTH      25.f
#define ARC_RADIUS          98.f
#define START_ANGLE         (-220.0)
#define END_ANGLE           (40.0)

@interface WMSMySportView ()
@property (strong,nonatomic) CAShapeLayer *trackUnderLayer;
@property (strong,nonatomic) CAShapeLayer *trackUpperLayer;

@property (nonatomic) int myTargetSetps;
@property (nonatomic) int mySportSetps;
@end

@implementation WMSMySportView

#pragma mark - Property Getter Method
- (CAShapeLayer *)trackUnderLayer
{
    if (!_trackUnderLayer) {
        _trackUnderLayer = [CAShapeLayer layer];
        _trackUnderLayer.frame = self.bounds;
        _trackUnderLayer.fillColor = [[UIColor clearColor] CGColor];
        _trackUnderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _trackUnderLayer.opacity = 1.0;
        _trackUnderLayer.lineWidth = PROGRESS_WIDTH;
    }
    return _trackUnderLayer;
}
- (CAShapeLayer *)trackUpperLayer
{
    if (!_trackUpperLayer) {
        _trackUpperLayer = [CAShapeLayer layer];
        _trackUpperLayer.frame = self.bounds;
        _trackUpperLayer.fillColor = [[UIColor clearColor] CGColor];
        _trackUpperLayer.strokeColor = UICOLOR_DEFAULT.CGColor;//UIColorFromRGBAlpha(0xDFE88D, 1.0).CGColor;
        _trackUpperLayer.opacity = 1.0;
        _trackUpperLayer.lineWidth = PROGRESS_WIDTH;
    }
    return _trackUpperLayer;
}


#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    [self.layer addSublayer:self.trackUnderLayer];
    [self.layer addSublayer:self.trackUpperLayer];
}

#pragma mark - Public Method
- (void)setTargetSetps:(int)steps
{
    self.myTargetSetps = steps;
    [self setNeedsDisplay];
}
- (void)setSportSteps:(int)steps
{
    if (steps <= self.myTargetSetps) {
        self.mySportSetps = steps;
    } else {
        self.mySportSetps = self.myTargetSetps;
    }
    [self setNeedsDisplay];
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float factor = 0;
    if (self.myTargetSetps > 0) {
        float a = END_ANGLE - START_ANGLE;
        factor = a / (float)self.myTargetSetps;//一步等价于多少角度
    }
    [self drawUnderLayerTrack];
    [self drawUpperLayerTrack:(self.mySportSetps * factor + START_ANGLE)];
}

- (void)drawUnderLayerTrack
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:ARC_RADIUS startAngle:degreesToRadians(START_ANGLE) endAngle:degreesToRadians(END_ANGLE) clockwise:YES];
    path.lineCapStyle = kCGLineCapButt;
    
    self.trackUnderLayer.path = [path CGPath];
    
    [path stroke];
}
- (void)drawUpperLayerTrack:(CGFloat)endAngle
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:ARC_RADIUS startAngle:degreesToRadians(START_ANGLE) endAngle:degreesToRadians(endAngle) clockwise:YES];
    path.lineCapStyle = kCGLineCapButt;
    
    self.trackUpperLayer.path = [path CGPath];
    
    [path stroke];
    
    [self drawLineAnimation:self.trackUpperLayer];
}
-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=1.0f;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}


@end
