//
//  CJWLoadAnimation.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/5.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWLoadAnimation.h"

@implementation CJWLoadAnimation

//圆形波纹
+ (CALayer *)loadLayerCircle {
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, 100, 100);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)].CGPath;
    shape.fillColor = [UIColor colorWithRed:26/255.0f green:176/255.0 blue:98/255.0 alpha:1].CGColor;
    shape.opacity = 0.0;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[[CJWLoadAnimation alphaAnimation],[CJWLoadAnimation scaleAnimation]];
    animationGroup.duration = 4.0;
    animationGroup.autoreverses = NO;
    animationGroup.repeatCount = HUGE;
    [shape addAnimation:animationGroup forKey:@"animationGroup"];
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, 100, 100);
    replicatorLayer.instanceDelay = 0.5;
    replicatorLayer.instanceCount = 8;
    [replicatorLayer addSublayer:shape];
    return replicatorLayer;
}

//缩放三点
+ (CALayer *)loadLayerWave {
    CGFloat between = 3.0;
    CGFloat radius = (90-2*between)/3;
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, (90 - radius)/2, radius, radius);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    shape.fillColor = [UIColor colorWithRed:26/255.0f green:176/255.0 blue:98/255.0 alpha:1].CGColor;
    [shape addAnimation:[CJWLoadAnimation scaleAnimation1] forKey:@"scaleAnimation"];
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, 90, 90);
    replicatorLayer.instanceDelay = 0.2;
    replicatorLayer.instanceCount = 3;
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(between*2+radius, 0, 0);
    [replicatorLayer addSublayer:shape];
    return replicatorLayer;
}

//缩放三角
+ (CALayer *)loadLayerTriangle {
    CGFloat radius = 100/4;
    CGFloat transX = 100 - radius;
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, radius, radius);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    shape.strokeColor = [UIColor colorWithRed:26/255.0f green:176/255.0 blue:98/255.0 alpha:1].CGColor;
    shape.fillColor = [UIColor colorWithRed:26/255.0f green:176/255.0 blue:98/255.0 alpha:1].CGColor;
    shape.lineWidth = 1;
    [shape addAnimation:[CJWLoadAnimation rotationAnimation:transX] forKey:@"ratateAnimation"];
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, radius, radius);
    replicatorLayer.instanceDelay = 0.0;
    replicatorLayer.instanceCount = 3;
    CATransform3D trans3D = CATransform3DIdentity;
    trans3D = CATransform3DTranslate(trans3D, transX, 0, 0);
    trans3D = CATransform3DRotate(trans3D, 120.0*M_PI/180.0, 0.0, 0.0, 1.0);
    replicatorLayer.instanceTransform = trans3D;
    [replicatorLayer addSublayer:shape];
    return replicatorLayer;
}

//九宫格
+ (CALayer *)loadLayerGrid {
    NSInteger column = 3;
    CGFloat between = 5.0;
    CGFloat radius = (100 - between * (column - 1))/column;
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, radius, radius);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    shape.fillColor = [UIColor colorWithRed:26/255.0f green:176/255.0 blue:98/255.0 alpha:1].CGColor;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[[CJWLoadAnimation scaleAnimation1], [CJWLoadAnimation alphaAnimation1]];
    animationGroup.duration = 1.0;
    animationGroup.autoreverses = YES;
    animationGroup.repeatCount = HUGE;
    [shape addAnimation:animationGroup forKey:@"groupAnimation"];
    
    CAReplicatorLayer *replicatorLayerX = [CAReplicatorLayer layer];
    replicatorLayerX.frame = CGRectMake(0, 0, 100, 100);
    replicatorLayerX.instanceDelay = 0.3;
    replicatorLayerX.instanceCount = column;
    replicatorLayerX.instanceTransform = CATransform3DTranslate(CATransform3DIdentity, radius + between, 0, 0);
    [replicatorLayerX addSublayer:shape];
    
    CAReplicatorLayer *replicatorLayerY = [CAReplicatorLayer layer];
    replicatorLayerY.frame = CGRectMake(0, 0, 100, 100);
    replicatorLayerY.instanceDelay = 0.3;
    replicatorLayerY.instanceCount = column;
    replicatorLayerY.instanceTransform = CATransform3DTranslate(CATransform3DIdentity, 0, radius + between, 0);
    [replicatorLayerY addSublayer:replicatorLayerX];
    return replicatorLayerY;
}

+ (CABasicAnimation *)alphaAnimation {
    CABasicAnimation *alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha.fromValue = @(1.0);
    alpha.toValue = @(0.0);
    return alpha;
}

+ (CABasicAnimation *)alphaAnimation1 {
    CABasicAnimation *alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha.fromValue = @(1.0);
    alpha.toValue = @(0.0);
    alpha.duration = 0.5;
    alpha.autoreverses = YES;
    return alpha;
}

+ (CABasicAnimation *)scaleAnimation {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity,0.0,0.0,0.0);
    scale.fromValue = [NSValue valueWithCATransform3D:transform];
    transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.0);
    scale.toValue = [NSValue valueWithCATransform3D:transform];
    return scale;
}

+ (CABasicAnimation *)scaleAnimation1 {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.0);
    scale.fromValue = [NSValue valueWithCATransform3D:transform];
    transform = CATransform3DScale(CATransform3DIdentity, 0.2, 0.2, 0.0);
    scale.toValue = [NSValue valueWithCATransform3D:transform];
    scale.autoreverses = YES;
    scale.repeatCount = HUGE;
    scale.duration = 0.5;
    return scale;
}

+ (CABasicAnimation *)rotationAnimation:(CGFloat)transX {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DRotate(CATransform3DIdentity, 0.0, 0.0, 0.0, 0.0);
    scale.fromValue = [NSValue valueWithCATransform3D:transform];
    CATransform3D toValue = CATransform3DTranslate(CATransform3DIdentity, transX, 0.0, 0.0);
    toValue = CATransform3DRotate(toValue, 120.0*M_PI/180.0, 0.0, 0.0, 1.0);
    scale.toValue = [NSValue valueWithCATransform3D:toValue];
    scale.autoreverses = NO;
    scale.repeatCount = HUGE;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scale.duration = 0.8;
    return scale;
}

@end
