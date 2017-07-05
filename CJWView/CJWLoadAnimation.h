//
//  CJWLoadAnimation.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/5.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CJWLoadAnimation : NSObject

+ (CALayer *)loadLayerCircle;       //圆形波纹
+ (CALayer *)loadLayerWave;         //缩放三点
+ (CALayer *)loadLayerTriangle;     //缩放三角
+ (CALayer *)loadLayerGrid;         //九宫格

@end
