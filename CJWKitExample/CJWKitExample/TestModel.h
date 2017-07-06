//
//  TestModel.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/6.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *extra;

@end
