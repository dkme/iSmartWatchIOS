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
}
@end

@implementation TurntableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch=[touches anyObject];
    //在旋转的过程中self的坐标系会转动，到superview里面去找坐标点
    CGPoint prePoint=[touch previousLocationInView:self.superview];
    CGPoint curPoint=[touch locationInView:self.superview];
    float angle=[self getAngleWithOrginPoint:self.center PointX:prePoint PointY:curPoint];
    CATransform3D transform=self.layer.transform;
    if (prePoint.y<self.center.y) {
        transform=CATransform3DRotate(transform, angle, 0, 0, 1);
    }else
    {
        transform=CATransform3DRotate(transform, angle, 0, 0, -1);
    }
    self.layer.transform=transform;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(turntableViewDidRotate:byRotateDirection:)]) {
        RotateDirection direction = [self getRotateDirectionFromPointX:prePoint toPointY:curPoint];
        [self.delegate turntableViewDidRotate:self byRotateDirection:direction];
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
        return clockwise;
    }
    
    k1 = (pointX.y-vCenter.y) / (pointX.x-vCenter.x);
    k2 = (pointY.y-vCenter.y) / (pointY.x-vCenter.x);
    
    CGFloat tan = (k2 - k1) * (1.0 + k1 * k2);
    
    return tan > 0.0 ? clockwise : anticlockwise ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
