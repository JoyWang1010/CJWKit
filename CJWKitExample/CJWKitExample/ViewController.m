//
//  ViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/19.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "ViewController.h"
#import "CJWDBTestViewController.h"
#import "CJWHttpTestViewController.h"
#import "CJWModelTestViewController.h"
#import "CJWLoadAnimationTestViewController.h"
#import "CJWStaticTableViewTestViewController.h"
#import "CJWTableViewPlaceholderTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *kitArr = @[@"数据库读写",@"网络请求",@"json转model",@"加载动画",@"静态tableView",@"tableView和collectionView的空数据视图"];
    for (int i = 0; i < kitArr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, 100 + 50*i, self.view.frame.size.width - 40, 44);
        button.tag = i;
        button.backgroundColor = [UIColor redColor];
        [button setTitle:kitArr[i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [button.titleLabel setTintColor:[UIColor lightTextColor]];
        [button addTarget:self action:@selector(goFunctionPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)goFunctionPage:(UIButton *)button {
    UIViewController *vc;
    switch (button.tag) {
        case 0:
            vc = [[CJWDBTestViewController alloc] init];
            break;
        case 1:
            vc = [[CJWHttpTestViewController alloc] init];
            break;
        case 2:
            vc = [[CJWModelTestViewController alloc] init];
            break;
        case 3:
            vc = [[CJWLoadAnimationTestViewController alloc] init];
            break;
        case 4:
            vc = [[CJWStaticTableViewTestViewController alloc] init];
            break;
        case 5:
            vc = [[CJWTableViewPlaceholderTestViewController alloc] init];
            break;
        default:
            break;
    }
    if (vc != nil) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
