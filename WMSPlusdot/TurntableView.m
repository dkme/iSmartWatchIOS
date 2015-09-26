//
//  TurntableVIew.m
//  CoreAnimationDemo
//
//  Created by avcon on 13-1-17.
//  Copyright (c) 2013年 avcon. All rights reserved.
//

#import "TurntableView.h"

@interface TurntableView()
{
    CGPoint startPoint;
    CGPoint endPoint;
    
    BOOL isNeedChangeStartPoint;
}

@end

@implementation TurntableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _previousRotateDirection = unknowDirection;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch * touch=[touches anyObject];
    startPoint = [touch previousLocationInView:self.superview];
    
    isNeedChangeStartPoint = YES;
    _previousRotateDirection = unknowDirection;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch * touch=[touches anyObject];
    //在旋转的过程中self的坐标系会转动，到superview里面去找坐标点
    CGPoint prePoint=[touch previousLocationInView:self.superview];
    CGPoint curPoint=[touch locationInView:self.superview];
    float angle=[self getAngleWithOrginPoint:self.center PointX:prePoint PointY:curPoint];
    
    ///转动view
    CATransform3D transform=self.layer.transform;
    if (prePoint.y<self.center.y) {
        transform=CATransform3DRotate(transform, angle, 0, 0, 1);
    }else
    {
        transform=CATransform3DRotate(transform, angle, 0, 0, -1);
    }
    self.layer.transform=transform;
    
    
    RotateDirection direction = [self getRotateDirectionFromPointX:prePoint toPointY:curPoint];///获取旋转方向
    
    if (direction != self.previousRotateDirection) {
        if (self.previousRotateDirection != unknowDirection && isNeedChangeStartPoint) {
            startPoint = prePoint;
            isNeedChangeStartPoint = NO;
            DEBUGLog(@"Change start point");
        }
        float radian = [self getAngleWithOrginPoint:self.center PointX:curPoint PointY:startPoint];
        DEBUGLog(@"angle: %f", fabs(radian));
        if (fabs(radian) >= 10*M_PI/180.0) {///判断旋转的角度是否大于等于3°（小于3°忽略）
            DEBUGLog(@"callback...");
            if (self.delegate && [self.delegate respondsToSelector:@selector(turntableView:didChangeRotateDirection:)]) {
                [self.delegate turntableView:self didChangeRotateDirection:direction];
            }
            _previousRotateDirection = direction;
            isNeedChangeStartPoint = YES;
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [super touchesEnded:touches withEvent:event];
//    
//    UITouch * touch=[touches anyObject];
//    endPoint = [touch previousLocationInView:self.superview];
    
    

    if (self.delegate && [self.delegate respondsToSelector:@selector(turntableViewDidStopRotate:)]) {
        [self.delegate turntableViewDidStopRotate:self];
    }
}

//用反余弦函数求角
-(float)getAngleWithOrginPoint:(CGPoint)aOrginPoint PointX:(CGPoint)aPointX PointY:(CGPoint)aPointY
{
    //得到pointX到原点的距离
    float xToOrgin=[self getDistanceFromPointX:aPointX toPointY:aOrginPoint];
    //得到pointX到原点的水平距离
    float xDistanceOnX=aPointX.x-aOrginPoint.x;
    //用反余弦函数得到pointX与水平线的夹角
    float xAngle=acos(xDistanceOnX/xToOrgin);
    
    
    //用同样的方法得到pointY与水平线的夹角
    float yToOrgin=[self getDistanceFromPointX:aPointY toPointY:aOrginPoint];
    float yDistanceOnX=aPointY.x-aOrginPoint.x;
    float yAngle=acos(yDistanceOnX/yToOrgin);
    
    
    float angle=xAngle-yAngle;

    return angle;
}

//求两个点之间的距离
-(float)getDistanceFromPointX:(CGPoint)PointX toPointY:(CGPoint)PointY
{
    float xDis=PointX.x-PointY.x;
    float yDis=PointX.y-PointY.y;
    float distance=sqrtf(xDis*xDis+yDis*yDis);
    return distance;
}

//求旋转的方向
-(RotateDirection)getRotateDirectionFromPointX:(CGPoint)pointX toPointY:(CGPoint)pointY
{
    CGFloat k1, k2 ;
    CGPoint vCenter = self.center;
    
    if(pointX.x - vCenter.x == 0 || pointY.x - vCenter.x == 0) {
        return unknowDirection;
    }
    
    k1 = (pointX.y-vCenter.y) / (pointX.x-vCenter.x);
    k2 = (pointY.y-vCenter.y) / (pointY.x-vCenter.x);
    
    CGFloat tan = (k2 - k1) * (1.0 + k1 * k2);
    
    return tan > 0.0 ? clockwise : anticlockwise ;
}

@end
