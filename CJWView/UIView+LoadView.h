//
//  UIView+LoadView.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/30.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypeCiecle = 0,
    AnimationTypeWave,
    AnimationTypeTriangle,
    AnimationTypeGrid
};

@interface UIView (LoadView)

@property (nonatomic, copy) UIView *(^justOnce)(void);
@property (nonatomic, copy) void(^startLoad)(AnimationType animationType);
@property (nonatomic, copy) void(^startLoadWithView)(UIView *loadView);
@property (nonatomic, copy) void(^endLoad)(void);

@end
