//
//  WMSSyncDataView.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSyncDataView.h"

#define Cell_Height     10
#define Cell_Width      30
#define Cell_tuber      3

#define MAX_ElectricQuantity    100.0

#define Cell_Left_Point ( CGPointMake(self.labelTip.frame.origin.x+self.labelTip.frame.size.width+10, (self.frame.size.height-Cell_Height)/2-2) )

@interface WMSSyncDataView ()
@property (strong,nonatomic) CAShapeLayer *underLayer;
@property (strong,nonatomic) CAShapeLayer *headLayer;
@property (strong,nonatomic) CAShapeLayer *cellLayer;

@property (strong,nonatomic) UILabel *labelElectricQuantity;
@property (nonatomic) NSUInteger electricQuantity;
@end

@implementation WMSSyncDataView

#pragma mark - Getter
- (CAShapeLayer *)underLayer
{
    if (!_underLayer) {
        _underLayer = [CAShapeLayer layer];
        _underLayer.frame = self.bounds;
        _underLayer.fillColor = [[UIColor clearColor] CGColor];
        _underLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _underLayer.opacity = 1;
        _underLayer.lineCap = kCALineCapRound;
        _underLayer.lineWidth = 1;
    }
    return _underLayer;
}
- (CAShapeLayer *)headLayer
{
    if (!_headLayer) {
        _headLayer = [CAShapeLayer layer];
        _headLayer.frame = self.bounds;
        _headLayer.fillColor = [[UIColor whiteColor] CGColor];
        _headLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _headLayer.opacity = 1;
        _headLayer.lineCap = kCALineCapRound;
        _headLayer.lineWidth = 1;
    }
    return _headLayer;
}
- (CAShapeLayer *)cellLayer
{
    if (!_cellLayer) {
        _cellLayer = [CAShapeLayer layer];
        _cellLayer.frame = self.bounds;
        _cellLayer.fillColor = [[UIColor whiteColor] CGColor];
        _cellLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _cellLayer.opacity = 1;
        _cellLayer.lineCap = kCALineCapRound;
        _cellLayer.lineWidth = 1;
    }
    return _cellLayer;
}

- (UILabel *)labelElectricQuantity
{
    if (!_labelElectricQuantity) {
        CGSize labelSize = CGSizeMake(50, 30);
        _labelElectricQuantity = [[UILabel alloc] initWithFrame:
                                  CGRectMake(Cell_Left_Point.x+Cell_Width+10, (self.frame.size.height-labelSize.height)/2, labelSize.width, labelSize.height)];
        _labelElectricQuantity.textColor = [UIColor whiteColor];
        _labelElectricQuantity.font = Font_DINCondensed(12.0);
    }
    return _labelElectricQuantity;
}

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}
- (void)setup
{
    _labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-30)/2.0, self.frame.size.width/2.0-10, 30)];
    _labelTip.textColor = [UIColor whiteColor];
    _labelTip.textAlignment = NSTextAlignmentRight;
    
    CGPoint or = CGPointZero;
    or.x = _labelTip.frame.origin.x+_labelTip.frame.size.width + 2;
    or.y = _labelTip.frame.origin.y+2;
    UIView *intervalView = [[UIView alloc] initWithFrame:CGRectMake(or.x, or.y, 1, 20)];
    intervalView.backgroundColor = [UIColor whiteColor];
    
    _buttonSync = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize size = CGSizeMake(70, 30);
    CGPoint point = CGPointMake(self.frame.size.width-size.width-15, (self.frame.size.height-size.height)/2);
    _buttonSync.frame = (CGRect){point,size};
    
    point = CGPointMake(point.x-10, point.y);
    _imageView = [[UIImageView alloc] initWithFrame:(CGRect){point,size}];
    
    
    [self addSubview:_labelTip];
    [self addSubview:intervalView];
    [self addSubview:_imageView];
    [self addSubview:_buttonSync];
    [self addSubview:self.labelElectricQuantity];
    
    [self.layer addSublayer:self.underLayer];
    [self.layer addSublayer:self.headLayer];
    [self.layer addSublayer:self.cellLayer];
    
    
    [self setCellElectricQuantity:100];
}

#pragma mark - Public
- (void)setCellElectricQuantity:(NSUInteger)quantity
{
    if (MAX_ElectricQuantity > quantity) {
        self.electricQuantity = quantity;
    } else {
        self.electricQuantity = MAX_ElectricQuantity;
    }
    
    self.labelElectricQuantity.text = [NSString stringWithFormat:@"%d%%",self.electricQuantity];
    
    [self setNeedsDisplay];
}

- (void)startAnimating
{
    //DEBUGLog(@"[self.imageView.layer animationKeys]:%@",[self.imageView.layer animationKeys]) ;
    //[self.imageView.layer removeAnimationForKey:@"rotationAnimation"];
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 10.0;
    rotationAnimation.speed = 8.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    
    [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimating
{
    [self.imageView.layer removeAnimationForKey:@"rotationAnimation"];
}


#pragma mark - Draw
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self drawUnderLayer];
    [self drawHeadLayer];
    
    [self drawCellLayer];
}

- (void)drawUnderLayer
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:(CGRect){Cell_Left_Point,Cell_Width,Cell_Height}];
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    
    self.underLayer.path = [path CGPath];
    
    [path stroke];
}
- (void)drawHeadLayer
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.0;
    
    [path moveToPoint:(CGPoint){Cell_Left_Point.x+Cell_Width,
                                Cell_Left_Point.y+Cell_Height/2-2}];
    [path addQuadCurveToPoint:CGPointMake(Cell_Left_Point.x+Cell_Width, Cell_Left_Point.y+Cell_Height/2+2) controlPoint:CGPointMake(Cell_Left_Point.x+Cell_Width+3, Cell_Left_Point.y+Cell_Height/2)];

    
    self.headLayer.path = [path CGPath];
    
    [path stroke];
}

- (void)drawCellLayer
{
    CGFloat cellWidth = 0;
    if (self.electricQuantity >= 3) {
        cellWidth = Cell_Width*(self.electricQuantity/MAX_ElectricQuantity)-3;
    } else {
        cellWidth = Cell_Width*(self.electricQuantity/MAX_ElectricQuantity);
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:(CGRect){Cell_Left_Point.x+1.5,Cell_Left_Point.y+1.5, cellWidth,Cell_Height-3}];
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    
    self.cellLayer.path = [path CGPath];
    
    [path stroke];
}

@end
