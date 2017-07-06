//
//  CJWHttpTestViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/6.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWHttpTestViewController.h"
#import "CJWHttp.h"

@interface CJWHttpTestViewController ()

@end

@implementation CJWHttpTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 20)];
    label.text = @"请看Debug信息";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18.0f];
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    
    N(@"http://www.baidu.com").post(^(NSData *responseData) {
        NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"dataString%@",dataString);
    },^(NSError *error){
        NSLog(@"error.description%@",error.description);
    });
}

@end
