//
//  DialView.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/5/22.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "DialView.h"

const static float THRESHOLD      = 1.0;

/*最大转动速度*/
static float MAX_SPEED = 1.0;

/*最小转动速度*/
float MIN_SPEED=0.05;

/*控制微动画的时间*/
float SMALL_ROTATE_DURATION=0.05;

/*
 常量命名:kMinSpeedInXXXKey
 static MIN_SPEED
 VIEW_CONTROLLER_MIN_SPEED
 
 ViewControllerDidRotateNotification
 
 ivar命名加下划线
 属性不用
 
 注意常量是否static
 */

/*控制定时器调用指定方法的时间*/
float TIMER_INVAL=0.05;

@implementation DialView
{
    
    __weak NSTimer *_timer ;
    
    /*转动方向
     CLOCK顺时针
     ANTICLOCK逆时针
     */
    enum RotateDirection{
        CLOCK,
        ANTICLOCK} ;
    //counter-clock
    /*当前view的转动速度*/
    float currentSpeed ;
    
    /*d当前转动的方向*/
    enum RotateDirection currentRotateDirection;
    
    NSDate *now;
    NSDate *toucheBeginTime;
    
    CGPoint touchStartPoint , touchEndPoint ;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
        [self setupBackgroundImage];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self setup];
//        [self setupBackgroundImage];
    }
    return self;
}

- (void)setup
{
//    _direction = clockwise;
//    [self startRotate];
}
- (void)setupBackgroundImage
{
//    _backgroundImage= [[UIImageView alloc] initWithFrame:self.bounds];
//    [self addSubview:_backgroundImage];
}

#pragma mark - Private methods
- (void)rotate:(CGFloat)angle
{
    CGAffineTransform originTransform=self.transform ;
    self.transform = CGAffineTransformRotate(originTransform, angle);
}

-(void)rotateWithSpeed:(float)speed
{
    CGFloat angle = speed*M_PI ;
    
    if(currentRotateDirection == ANTICLOCK)
    {
        angle=-angle;
    }
    [UIView animateWithDuration:SMALL_ROTATE_DURATION
                     animations:
     ^{
         [self rotate:angle];
     }
     
     ];
}

- (void)startRotate
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INVAL target:self selector:@selector(timerThread) userInfo:nil repeats:YES] ;
}

- (void)stopRotate
{
    [_timer invalidate];
}

- (void)timerThread
{
    if(currentSpeed > MIN_SPEED)
    {
        currentSpeed -= 0.05 ;
    }
    
    if(currentSpeed < MIN_SPEED)
    {
        currentSpeed = MIN_SPEED;
    }
    
    [self rotateWithSpeed:currentSpeed];
}


- (CGFloat)calculateAngle:(CGPoint)begin endPoint:(CGPoint)end
{
    CGFloat k1,k2 ;
    CGPoint vCenter= [self center];
    
    if(begin.x-vCenter.x==0 ||end.x-vCenter.x == 0)
    {
        return 0.0;
    }
    
    k1= (begin.y-vCenter.y)/(begin.x-vCenter.x) ;
    k2= (end.y-vCenter.y)/(end.x-vCenter.x);
    
    CGFloat tan0= (k2-k1)/(1.0+k1*k2);
    
    if(tan0<0)
    {
        tan0=-tan0;
    }
    
    
    return atan(tan0) ;
}

- (enum RotateDirection)getRotateDirectionByPoints:(CGPoint)s end:(CGPoint)e
{
    CGFloat k1,k2 ;
    CGPoint vCenter= [self center];
    
    if(s.x-vCenter.x==0 || e.x-vCenter.x==0)
    {
        return CLOCK;
    }
    
    k1= (s.y-vCenter.y)/(s.x-vCenter.x) ;
    k2= (e.y-vCenter.y)/(e.x-vCenter.x);
    
    CGFloat tan0= (k2-k1)*(1.0+k1*k2);
    
    if(tan0>0.0)
    {
        return CLOCK;
    }
    else
    {
        return ANTICLOCK;
    }
    
}

- (float)calculateSpeedByPoints:(CGPoint)s end:(CGPoint)e
{
    NSTimeInterval timeInterval = [toucheBeginTime timeIntervalSinceNow] ;
    
    double seconds = timeInterval;
    
    if(seconds < 0)
    {
        seconds=-seconds;
    }
    
    double distance = [self getDistance:touchStartPoint end:touchEndPoint];
    double speed=distance/seconds;
    
    NSString *str1=[NSString stringWithFormat:@"speed:%lf",speed];
//    [self.textFiled1 setText:str1];
    NSLog(@"%@",str1);
    
    if(speed > 40.0)
    {
        speed = MAX_SPEED;
    }
    else
    {
        speed = MIN_SPEED;
    }
    return speed;
}

- (void)dragRotate:(CGPoint)s end:(CGPoint)e
{
    CGFloat angle = [self calculateAngle:touchStartPoint endPoint:touchEndPoint];
    
    currentRotateDirection=[self getRotateDirectionByPoints:s end:e];
    
    currentSpeed=[self calculateSpeedByPoints:s end:e];
    
    if(currentRotateDirection==ANTICLOCK)
    {
//        angle=-angle ;
    }
    
    [self rotate:angle];
}

- (CGPoint) getLocationFromTouches:(NSSet*)touches
{
    UITouch *touch;
    
    for(UITouch *t in touches)
    {
        touch=t;
    }
    return [touch locationInView:self];
}

- (CGFloat) getDistance:(CGPoint)s end:(CGPoint)e
{
    return sqrt((s.x-e.x)*(s.x-e.x) + (s.y-e.y)*(s.y-e.y));
}



/*覆盖touch event的事件处理*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopRotate];
    touchStartPoint = [self getLocationFromTouches:touches];
    
    toucheBeginTime = [NSDate date] ;
    
    NSLog(@"............fdsa;jdfl;jsdl;afj;a");
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchEndPoint = [self getLocationFromTouches:touches];
    
    CGFloat distance = [self getDistance:touchStartPoint end:touchEndPoint];
    
    if(distance > 1.0)
    {
        [self dragRotate:touchStartPoint end:touchEndPoint];
        
        touchStartPoint = touchEndPoint ;
    }
    NSLog(@"............fdsa;jdfl;jsdl;afj;ahdsofhjklhsdafklhdsaflksad");
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    now = [NSDate date];

	[self touchesMoved:touches withEvent:nil];
//    [self startRotate];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    now = [NSDate date];

    [self touchesMoved:touches withEvent:nil];
//	[self startRotate];
}



@end
