//
//  TemperaBar.m
//  TemperaBar
//
//  Created by luyf on 13-2-28.
//  Copyright (c) 2013年 luyf. All rights reserved.
//

#import "TemperaBar.h"
#import "OBShapedButton.h"

#define CIRCLE_X                        (150.0f)
#define CIRCLE_Y                        (142.0f)
#define START_ANGLE                     (-42.0f)
#define END_ANGLE                       (222.0f)
#define CONTROL_CIRCLE_RADIUS           (109.5f)
//#define Tempera_CIRCLE_RADIUS            (66.0f)

#define DEGREES_TO_RADIANS(_degrees)    ((M_PI * (_degrees))/180)
#define RADIANS_TO_DEGREES(_radians)    ((_radians)*180)/M_PI

#pragma mark - CircleSlideDelegate
@class CircleSlide;
@protocol CircleSlideDelegate <NSObject>

@optional
- (void)circleSlide:(CircleSlide *)circleSlide withProgress:(float)progress;
-(void)finishSlide;
@end

#pragma mark - CircleSlide
@interface CircleSlide : UIImageView //<CircleSlideDelegate>
{
@private
    __weak id<CircleSlideDelegate> _delegate;
    CGPoint         _rotatePoint;  //圆点
    float           _radius;       //半径
    float           _startAngle;   //开始角度
    float           _endAngle;     //结束角度

    float           _progress;     //0~1
}

@property (nonatomic, weak) id<CircleSlideDelegate> delegate;
@property (nonatomic, readonly) float progress;

- (id)initWithImage:(UIImage *)image
        rotatePoint:(CGPoint)rotatePoint
             radius:(float)radius
         startAngle:(float)startAngle
           endAngle:(float)endAngle;
@end

@implementation CircleSlide
@synthesize delegate = _delegate;
@synthesize progress = _progress;

- (id)initWithImage:(UIImage *)image
        rotatePoint:(CGPoint)rotatePoint
             radius:(float)radius
         startAngle:(float)startAngle
           endAngle:(float)endAngle
{
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        _rotatePoint = rotatePoint;
        _radius = radius;
        _startAngle = startAngle;
        _endAngle = endAngle;
        _progress = 1;
        self.center = [self positionOfProgress:_progress];
    }
    return self;
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)setProgress:(float)progress
{
    if (progress >= 0 && progress <= 1.0f) {
        _progress = progress;
        self.center = [self positionOfProgress:_progress];
    }
}

- (float)progressOfAngle:(float)angle
{
    angle = MAX(angle, _startAngle);
    angle = MIN(angle, _endAngle);
    return (angle - _startAngle)/(_endAngle - _startAngle);
}

- (float)angleOfProgress:(float)progress
{
//    progress = MAX(progress, 0);
//    progress = MIN(progress, 1.0f);
    
    return _progress*(_endAngle - _startAngle)+_startAngle;
}

- (BOOL)samesign:(float)x y:(float)y
{
    return (x <= 0 && y <= 0) || (x >= 0 && y >= 0);
}

- (float)progressOfPosition:(CGPoint)position
{
    float x = position.x - _rotatePoint.x;
    float y = - (position.y - _rotatePoint.y);
    
    float angle = atanf(y/x);
    if (![self samesign:x y:cosf(angle)] || ![self samesign:y y:sinf(angle)]) {
        angle += M_PI;
    }
    
    return [self progressOfAngle:angle];
}

- (CGPoint)positionOfProgress:(float)progress
{
    float angle = [self angleOfProgress:_progress];
    
    CGPoint position = {_rotatePoint.x+cosf(angle)*_radius, _rotatePoint.y-sinf(angle)*_radius};
    return position;
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint ptCurr=[[touches anyObject] locationInView:(UIView *)_delegate];
    //float newProgress = [self progressOfPosition:ptCurr];
    
    /* 判断是否发生跳跃 */
    //if ((newProgress > _progress && (newProgress - _progress) < 0.5)|| (newProgress < _progress && (_progress - newProgress) < 0.5)) {
        _progress = [self progressOfPosition:ptCurr];
        self.center = [self positionOfProgress:_progress];
        
        if (_delegate && [_delegate respondsToSelector:@selector(circleSlide:withProgress:)]) {
            [_delegate circleSlide:self withProgress:_progress];
        }
    //}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(finishSlide)])
    {
        [_delegate finishSlide];
    }
}

@end

#pragma mark - TemperaBar
@interface TemperaBar ()<CircleSlideDelegate>
{
    UIImageView *       _backgroundView;
    CircleSlide *       _circleSlide;
    UIImageView *       _contentView;
    
    UIImage *           _contentImage;
    
    float               _progress;/* 1表示最小音量， 0表示最大音量 */
}
@end

@implementation TemperaBar
@dynamic currentTempera;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//有做修改
        [self setUserInteractionEnabled:YES];
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target_progress_bg.png"]];
        CGRect fm = _backgroundView.bounds;
        fm.size = (CGSize){fm.size.width/2,fm.size.height/2};
        //[_backgroundView setFrame:_backgroundView.bounds];
        [_backgroundView setFrame:fm];
        [_backgroundView setBounds:(CGRect){0,0,fm.size}];
        //DEBUGLog(@"ImageView:%f,%f,%f,%f",_backgroundView.frame.origin.x,_backgroundView.frame.origin.y,_backgroundView.frame.size.width,_backgroundView.frame.size.height);
        
        frame.size.width = _backgroundView.bounds.size.width;
        frame.size.height = _backgroundView.bounds.size.height;
        [self setFrame:frame];
        //DEBUGLog(@"frame:%f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
        [self setBackgroundColor:[UIColor clearColor]];
        //[self setBackgroundColor:[UIColor redColor]];
        [self addSubview:_backgroundView];
        
        //control 圆点
        CGPoint pt = _backgroundView.center;
        
//        _circleSlide = [[CircleSlide alloc] initWithImage:[UIImage imageNamed:@"zq_light_color_control.png"]
//                               rotatePoint:CGPointMake(CIRCLE_X, CIRCLE_Y)
//                                    radius:CONTROL_CIRCLE_RADIUS
//                                startAngle:DEGREES_TO_RADIANS(START_ANGLE)
//                                  endAngle:DEGREES_TO_RADIANS(END_ANGLE)];

        _circleSlide = [[CircleSlide alloc] initWithImage:[UIImage imageNamed:@"target_progress_btn.png"]
                                              rotatePoint:pt
                                                   radius:CONTROL_CIRCLE_RADIUS-12
                                               startAngle:DEGREES_TO_RADIANS(START_ANGLE)
                                                 endAngle:DEGREES_TO_RADIANS(END_ANGLE)];
        CGRect bounds = _circleSlide.bounds;
        _circleSlide.bounds = (CGRect){bounds.origin,bounds.size.width/2,bounds.size.height/2};
        _circleSlide.delegate = self;
        [self addSubview:_circleSlide];

        
        //content
//        _contentImage = [UIImage imageNamed:@"TemperaBar.bundle/vol_full.png"];
//        _contentView = [[UIImageView alloc] initWithFrame:_backgroundView.bounds];
//        [self addSubview:_contentView];
        _progress = 1;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame minimumTempera:(NSInteger)minimumTempera maximumTempera:(NSInteger)maximumTempera
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _minimumTempera = minimumTempera;
        _maximumTempera = maximumTempera;
    }
    return self;
}

- (void)dealloc
{
    _backgroundView = nil;
    _circleSlide = nil;
    _contentView = nil;
    _contentImage = nil;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    OBShapedButton *bt = [[OBShapedButton alloc]init];
    CGPoint ptCurr=[[touches anyObject] locationInView:self];
    if ([bt isAlphaVisibleAtPoint:ptCurr forImage:_backgroundView.image]) {
        //[_circleSlide touchesMoved:touches withEvent:event];
        _isInside = YES;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    OBShapedButton *bt = [[OBShapedButton alloc]init];
    CGPoint ptCurr=[[touches anyObject] locationInView:self];
    if ([bt isAlphaVisibleAtPoint:ptCurr forImage:_backgroundView.image]) {
        //[_circleSlide touchesMoved:touches withEvent:event];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    OBShapedButton *bt = [[OBShapedButton alloc]init];
    CGPoint ptCurr=[[touches anyObject] locationInView:self];
    if ([bt isAlphaVisibleAtPoint:ptCurr forImage:_backgroundView.image]||_isInside) {
        //[self finishSlide];
    }
    _isInside = NO;
}

- (void)drawRect:(CGRect)rect
{    
//    CGContextRef context = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, 4 * self.bounds.size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
//    
//    float endAngle = (END_ANGLE-START_ANGLE)*_progress+START_ANGLE;
//    endAngle = (_progress == 0)?(endAngle+0.1):endAngle;
//    
//    CGContextAddArc(context, CIRCLE_X, CIRCLE_Y, Tempera_CIRCLE_RADIUS, DEGREES_TO_RADIANS(START_ANGLE), DEGREES_TO_RADIANS(endAngle), YES);
//    CGContextAddArc(context, CIRCLE_X, CIRCLE_Y, 0, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(0), YES);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    CGContextDrawImage(context, self.bounds, _contentImage.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
//    CGImageRelease(imageMasked);
//    
//    [_contentView setImage:newImage];
    
    [_circleSlide setProgress:_progress];
}

- (NSInteger)currentTempera
{
    return _currentTempera;
}

- (void)setCurrentTempera:(NSInteger)currentTempera
{
    if (currentTempera >= _minimumTempera && currentTempera <= _maximumTempera) {
        _progress = 1.0f - (float)(currentTempera - _minimumTempera)/(_maximumTempera - _minimumTempera);
        _currentTempera = currentTempera;
        [self setNeedsDisplay];
    }
}

#pragma mark - CircleSlideDelegate
- (void)circleSlide:(CircleSlide *)circleSlide withProgress:(float)progress
{
    //[self sendActionsForControlEvents:UIControlEventValueChanged];
    _progress = progress;
    [self setNeedsDisplay];
    
    NSInteger Tempera = (_maximumTempera - _minimumTempera)*(1-_progress);
    
    if (_currentTempera != Tempera) {
        _currentTempera = Tempera+_minimumTempera;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)finishSlide
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
