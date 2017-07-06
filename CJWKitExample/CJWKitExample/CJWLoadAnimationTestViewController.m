//
//  CJWLoadAnimationTestViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/6.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWLoadAnimationTestViewController.h"
#import "UIView+LoadView.h"

@interface CJWLoadAnimationTestViewController ()
{
    NSInteger repeatCount;
}
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CJWLoadAnimationTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.view.startLoad(AnimationTypeCiecle);

    repeatCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(changeAnimation) userInfo:nil repeats:YES];

}

- (void)changeAnimation {
    self.view.endLoad();
    repeatCount += 1;
    
    NSInteger animationType = repeatCount%4;
    self.view.startLoad(animationType);
}

@end
