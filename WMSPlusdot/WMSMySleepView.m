//
//  WMSMySleepView.m
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMySleepView.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)    //角度转弧度
#define PROGRESS_WIDTH      25.f
#define ARC_RADIUS          98.f
#define START_ANGLE         (-220.0)
#define END_ANGLE           (40.0)

@interface WMSMySleepView ()
@property (strong,nonatomic) CAShapeLayer *trackUnderLayer;
@property (strong,nonatomic) CAShapeLayer *trackLayer1;//深睡
@property (strong,nonatomic) CAShapeLayer *trackLayer2;//浅睡
@property (strong,nonatomic) CAShapeLayer *trackLayer3;//唤醒

@property (nonatomic) int mySleepMinute;
@property (nonatomic) int myDeepSleepMinute;
@property (nonatomic) int myLightSleepMinute;
@property (nonatomic) int myWakeupMinute;
@end

@implementation WMSMySleepView

#pragma mark - Property Getter Method
- (CAShapeLayer *)trackUnderLayer
{
    if (!_trackUnderLayer) {
        _trackUnderLayer = [CAShapeLayer layer];
        _trackUnderLayer.frame = self.bounds;
        _trackUnderLayer.fillColor = [[UIColor clearColor] CGColor];
        _trackUnderLayer.strokeColor = UIColorFromRGBAlpha(0x2EC4DD, 1.0).CGColor;
        _trackUnderLayer.opacity = 1;
        _trackUnderLayer.lineCap = kCALineCapRound;
        _trackUnderLayer.lineWidth = PROGRESS_WIDTH;
    }
    return _trackUnderLayer;
}
- (CAShapeLayer *)trackLayer1
{
    if (!_trackLayer1) {
        _trackLayer1 = [CAShapeLayer layer];
        _trackLayer1.frame = self.bounds;
        _trackLayer1.fillColor = [[UIColor clearColor] CGColor];
        _trackLayer1.strokeColor = [UIColor greenColor].CGColor;
        _trackLayer1.opacity = 1.0;
        //_trackLayer1.cornerRadius = 0;
        _trackLayer1.lineCap = kCALineCapRound;
        _trackLayer1.lineWidth = PROGRESS_WIDTH;
    }
    return _trackLayer1;
}
- (CAShapeLayer *)trackLayer2
{
    if (!_trackLayer2) {
        _trackLayer2 = [CAShapeLayer layer];
        _trackLayer2.frame = self.bounds;
        _trackLayer2.fillColor = [[UIColor clearColor] CGColor];
        _trackLayer2.strokeColor = [UIColor orangeColor].CGColor;
        _trackLayer2.opacity = 1.0;
        _trackLayer2.lineCap = kCALineCapRound;
        _trackLayer2.lineWidth = PROGRESS_WIDTH;
    }
    return _trackLayer2;
}
- (CAShapeLayer *)trackLayer3
{
    if (!_trackLayer3) {
        _trackLayer3 = [CAShapeLayer layer];
        _trackLayer3.frame = self.bounds;
        _trackLayer3.fillColor = [[UIColor clearColor] CGColor];
        _trackLayer3.strokeColor = [UIColor yellowColor].CGColor;
        _trackLayer3.opacity = 1.0;
        _trackLayer3.lineCap = kCALineCapRound;
        _trackLayer3.lineWidth = PROGRESS_WIDTH;
    }
    return _trackLayer3;
}

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)addSubLayers
{
    if (self.layer != [self.trackUnderLayer superlayer]) {
        //DEBUGLog(@"MySleepView addSublayer");
        [self.layer addSublayer:self.trackUnderLayer];
    }
    if (self.layer != [self.trackLayer1 superlayer]) {
        //DEBUGLog(@"MySportView addSublayer2");
        [self.layer addSublayer:self.trackLayer1];
    }
    if (self.layer != [self.trackLayer2 superlayer]) {
        //DEBUGLog(@"MySleepView addSublayer");
        [self.layer addSublayer:self.trackLayer2];
    }
    if (self.layer != [self.trackLayer3 superlayer]) {
        //DEBUGLog(@"MySportView addSublayer2");
        [self.layer addSublayer:self.trackLayer3];
    }
}

#pragma mark - Public Method
- (void)setSleepMinute:(NSUInteger)sleepMinute
       deepSleepMinute:(NSUInteger)deepSleepMinute
      lightSleepMinute:(NSUInteger)lightSleepMinute
{
    [self setSleepTime:sleepMinute];
    [self setDeepSleepTime:deepSleepMinute andLightSleepTime:lightSleepMinute];
    [self setNeedsDisplay];
}


#pragma mark - Private Methods
- (BOOL)setDeepSleepTime:(int)deepSleepMinute andLightSleepTime:(int)lightSleepMinute andWakeupTime:(int)wakeupMinute
{
    if (deepSleepMinute+lightSleepMinute+wakeupMinute != self.mySleepMinute) {
        return NO;
    }
    if (deepSleepMinute <= self.mySleepMinute) {
        self.myDeepSleepMinute = deepSleepMinute;
    }
    if (lightSleepMinute <= self.mySleepMinute) {
        self.myLightSleepMinute = lightSleepMinute;
    }
    if (wakeupMinute <= self.mySleepMinute) {
        self.myWakeupMinute = wakeupMinute;
    }
    
    [self setNeedsDisplay];
    
    return YES;
}

- (void)setDeepSleepTime:(NSUInteger)deepSleepMinute andLightSleepTime:(NSUInteger)lightSleepMinute
{    
    if (deepSleepMinute <= self.mySleepMinute) {
        self.myDeepSleepMinute = deepSleepMinute;
    } else {
        self.myDeepSleepMinute = self.mySleepMinute;
    }
    
    
    if (lightSleepMinute <= self.mySleepMinute-self.myDeepSleepMinute) {
        self.myLightSleepMinute = lightSleepMinute;
    } else {
        self.myLightSleepMinute = self.mySleepMinute-self.myDeepSleepMinute;
    }
    
    //[self setNeedsDisplay];
}
- (void)setSleepTime:(int)minute
{
    self.mySleepMinute = minute;
    //[self setNeedsDisplay];
}
//- (void)setDeepSleepTime:(int)minute
//{
//    if (minute <= self.mySleepMinute) {
//        self.myDeepSleepMinute = minute;
//    }
//    
//    [self setNeedsDisplay];
//}
//- (void)setLightSleepTime:(int)minute
//{
//    if (minute <= self.myLightSleepMinute) {
//        self.myLightSleepMinute = minute;
//    }
//    
//    [self setNeedsDisplay];
//}
//- (void)setWakeupTime:(int)minute
//{
//    if (minute <= self.myWakeupMinute) {
//        self.myWakeupMinute = minute;
//    }
//    
//    [self setNeedsDisplay];
//}


#pragma mark - Draw
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    float factor = 0;
    if (self.mySleepMinute > 0) {
        float a = END_ANGLE - START_ANGLE;
        factor = a / (float)self.mySleepMinute;//一分钟等价于多少角度
    }

    [self addSubLayers];
    
    [self drawUnderLayerTrack];
    
    CGFloat startAngle = START_ANGLE;
    CGFloat endAngle = self.myDeepSleepMinute * factor + startAngle;
    [self drawTrackLayer:self.trackLayer1 andStartAngle:startAngle andEndAngle:endAngle];
    
    startAngle = endAngle;
    endAngle = self.myLightSleepMinute * factor +startAngle;
    [self drawTrackLayer:self.trackLayer2 andStartAngle:startAngle andEndAngle:endAngle];
    
    startAngle = endAngle;
    //endAngle = self.myWakeupMinute * factor +startAngle;
    endAngle = (self.mySleepMinute-self.myDeepSleepMinute-self.myLightSleepMinute) * factor +startAngle;
    [self drawTrackLayer:self.trackLayer3 andStartAngle:startAngle andEndAngle:endAngle];
    
}

- (void)drawUnderLayerTrack
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:ARC_RADIUS startAngle:degreesToRadians(START_ANGLE) endAngle:degreesToRadians(END_ANGLE) clockwise:YES];
    
    self.trackUnderLayer.path = [path CGPath];
    
    [path stroke];
}

- (void)drawTrackLayer:(CAShapeLayer *)layer andStartAngle:(CGFloat)startAngle andEndAngle:(CGFloat)endAngle
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:ARC_RADIUS startAngle:degreesToRadians(startAngle) endAngle:degreesToRadians(endAngle) clockwise:YES];
    //path.lineJoinStyle = kCGLineJoinBevel;
    
    layer.path = [path CGPath];
    
    [path stroke];
    
    //[self drawLineAnimation:layer];
}

- (void)drawLineAnimation:(CALayer *)layer
{
    float beginTime = 0;
    float duration = 1.0f;
    if (self.trackLayer1 == layer) {
        beginTime = 0;
    } else if (self.trackLayer2 == layer) {
        beginTime = 1.0;
    } else if (self.trackLayer3 == layer) {
        beginTime = 2.0;
    }
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.beginTime=CACurrentMediaTime()+beginTime;
    bas.duration=duration;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"strokeEnd"];
}

@end
