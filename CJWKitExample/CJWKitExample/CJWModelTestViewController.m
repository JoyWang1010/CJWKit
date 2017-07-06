//
//  CJWModelTestViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/6.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWModelTestViewController.h"
#import "NSObject+CJWModel.h"
#import "TestModel.h"

@interface CJWModelTestViewController ()

@end

@implementation CJWModelTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *string = @"{\"code\":0,\"msg\":\"success\",\"data\":{\"key\":\"这是数据\"},\"extra\":{\"cache\":true,\"cacheTime\":60000}}";
    NSDictionary *dic = TestModel.modelFromJsonString(string);
    NSLog(@"dic --- %@",dic);
}

@end
