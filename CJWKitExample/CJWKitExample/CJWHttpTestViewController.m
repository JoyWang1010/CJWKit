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
    
    N(@"http://www.baidu.com").post(^(NSData *responseData) {
        NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"dataString%@",dataString);
    },^(NSError *error){
        NSLog(@"error.description%@",error.description);
    });
}

@end
