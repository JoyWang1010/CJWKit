//
//  CJWRunLoopTestViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2021/12/20.
//  Copyright © 2021 JoyWang. All rights reserved.
//

#import "CJWRunLoopTestViewController.h"
#import "CJWThread.h"

@interface CJWRunLoopTestViewController ()
@property (strong, nonatomic) CJWThread *thread;
@end

@implementation CJWRunLoopTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 20)];
    label.text = @"请看Debug信息";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18.0f];
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    
    self.thread = [[CJWThread alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.thread executeTask:^{
        NSLog(@"执行任务 - %@", [NSThread currentThread]);
    }];
}

- (IBAction)stop {
    [self.thread stop];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
