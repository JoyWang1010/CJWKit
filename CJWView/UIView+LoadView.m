//
//  UIView+LoadView.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/30.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "UIView+LoadView.h"
#import <objc/runtime.h>
#import "CJWLoadAnimation.h"

static const void *justOnceLoadKey = &justOnceLoadKey;
static const void *alreadlyAppearLoadViewKey = &alreadlyAppearLoadViewKey;
static const void *loadAnimationKey = &loadAnimationKey;
static const void *loadViewKey = &loadViewKey;

@interface UIView ()

@property (nonatomic, assign) BOOL justOnceLoad;
@property (nonatomic, assign) BOOL alreadlyAppearLoadView;
@property (nonatomic, retain) CJWLoadAnimation *loadAnimation;
@property (nonatomic, retain) UIView *loadView;

@end

@implementation UIView (LoadView)
@dynamic justOnce;
@dynamic startLoad;
@dynamic startLoadWithView;
@dynamic endLoad;

- (UIView *(^)(void))justOnce {
    return ^{
        self.justOnceLoad = YES;
        return self;
    };
}

- (void(^)(AnimationType animationType))startLoad {
    return ^(AnimationType animationType){
        if (self.justOnceLoad && self.alreadlyAppearLoadView) {
            return ;
        }
        self.alreadlyAppearLoadView = YES;
        
        if (self.loadView == nil) {
            self.loadView = [[UIView alloc] initWithFrame:self.bounds];
            self.loadView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
            [self addSubview:self.loadView];
        }
        
        UIView *animationView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 100)/2, (self.frame.size.height - 100)/2, 100, 100)];
        animationView.tag = 100;
        [self.loadView addSubview:animationView];
        
        switch (animationType) {
            case AnimationTypeCiecle:
            {
                [animationView.layer addSublayer:[CJWLoadAnimation loadLayerCircle]];
            }
                break;
            case AnimationTypeWave:
            {
                [animationView.layer addSublayer:[CJWLoadAnimation loadLayerWave]];
            }
                break;case AnimationTypeTriangle:
            {
                [animationView.layer addSublayer:[CJWLoadAnimation loadLayerTriangle]];
            }
                break;case AnimationTypeGrid:
            {
                [animationView.layer addSublayer:[CJWLoadAnimation loadLayerGrid]];
            }
                break;
            default:
                break;
        }
    };
}

- (void(^)(UIView *loadView))startLoadWithView {
    return ^(UIView *loadView) {
        if (self.justOnceLoad && self.alreadlyAppearLoadView) {
            return ;
        }
        self.alreadlyAppearLoadView = YES;

        if (self.loadView == nil) {
            self.loadView = [[UIView alloc] initWithFrame:self.bounds];
            self.loadView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
            [self addSubview:self.loadView];
        }
        
        loadView.tag = 100;
        [self.loadView addSubview:loadView];
    };
}

- (void(^)(void))endLoad {
    return ^{
        UIView *animationView = [self.loadView viewWithTag:100];
        if (animationView != nil) {
            [animationView removeFromSuperview];
        }
    };
}

- (void)setJustOnceLoad:(BOOL)justOnceLoad {
    objc_setAssociatedObject(self, justOnceLoadKey, @(justOnceLoad), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)justOnceLoad {
    return objc_getAssociatedObject(self, justOnceLoadKey);
}

- (void)setAlreadlyAppearLoadView:(BOOL)alreadlyAppearLoadView {
    objc_setAssociatedObject(self, alreadlyAppearLoadViewKey, @(alreadlyAppearLoadView), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)alreadlyAppearLoadView {
    return objc_getAssociatedObject(self, alreadlyAppearLoadViewKey);
}

- (void)setLoadAnimation:(CJWLoadAnimation *)loadAnimation {
    objc_setAssociatedObject(self, loadAnimationKey, loadAnimation, OBJC_ASSOCIATION_RETAIN);
}

- (CJWLoadAnimation *)loadAnimation {
    return objc_getAssociatedObject(self, loadAnimationKey);
}

- (void)setLoadView:(UIView *)loadView {
    objc_setAssociatedObject(self, loadViewKey, loadView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)loadView {
    return objc_getAssociatedObject(self, loadViewKey);
}

@end
