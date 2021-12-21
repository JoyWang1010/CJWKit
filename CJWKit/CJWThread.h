//
//  CJWThread.h
//  CJWKitExample
//
//  Created by JoyWang on 2021/12/20.
//  Copyright © 2021 JoyWang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CJWThreadTask)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CJWThread : UIViewController

/**
 开启线程
 */
//- (void)run;

/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(CJWThreadTask)task;

/**
 结束线程
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
