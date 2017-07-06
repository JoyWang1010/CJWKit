//
//  CJWDBTestViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/6.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWDBTestViewController.h"
#import "StudentModel.h"
#import "CJWDB.h"

@interface CJWDBTestViewController ()

@end

@implementation CJWDBTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 20)];
    label.text = @"请看Debug信息";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18.0f];
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];

    //增
    StudentModel *stu = [[StudentModel alloc] init];
    stu.myName = @"JoyWang";
    stu.myNumber = 123;
    stu.array = @[@"123"];
    stu.dict = @{@"123":@"123"};
    stu.right = YES;
    M([StudentModel class]).insert(stu);

    //增
    stu.myName = @"王建国";
    stu.myNumber = 456;
    stu.array = @[@"456"];
    stu.dict = @{@"456":@"456"};
    stu.right = NO;
    M([StudentModel class]).insert(stu);

    //删
    M([StudentModel class]).delete(^CJWQueue *(CJWQueue *condition) {
        return condition.where(@"myName = 'JoyWang'");
    });

    //查
    NSArray *arr = M([StudentModel class]).select(^CJWQueue *(CJWQueue *condition) {
        return condition.where(@"myName = '王建国'");
    });
    for (StudentModel *stu in arr) {
        NSLog(@"stu.myName --- %@,stu.myNumber --- %ld,stu.array --- %@,stu.dict --- %@,stu.right --- %d",stu.myName,(long)stu.myNumber,stu.array,stu.dict,stu.right);
    }
    
    //改
    M([StudentModel class]).update(^CJWQueue *(CJWQueue *condition) {
        condition.updateWhere(@"myName = 'JoyWang'");
        StudentModel *stu = [[StudentModel alloc] init];
        stu.myName = @"JoyWang";
        stu.myNumber = 789;
        stu.right = YES;
        condition.updateMdel = stu;
        return condition;
    });
}

@end
