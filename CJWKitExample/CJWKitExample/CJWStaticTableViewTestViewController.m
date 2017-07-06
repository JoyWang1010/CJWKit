//
//  CJWStaticTableViewTestViewController.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/6.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWStaticTableViewTestViewController.h"
#import "UITableView+CJWStaticTableView.h"

@interface CJWStaticTableViewTestViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;

@end

@implementation CJWStaticTableViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.clear().tableViewConfiguration(^(CJWTableViewConfiguration *tableViewConfiguration) {
        tableViewConfiguration.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableViewConfiguration.backgroundColor = [UIColor whiteColor];
        tableViewConfiguration.tableViewHeaderView = self.headerView;
        for (int i = 0; i < 3 ; i ++) {
            tableViewConfiguration.sectionConfiguration(^(CJWSectionConfiguration *sectionConfiguration) {
                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
                footerView.backgroundColor = [UIColor blueColor];
                sectionConfiguration.headerView = footerView;
                sectionConfiguration.headerViewHeight = 50;
                for (int j = 0; j < 5; j++) {
                    sectionConfiguration.cellConfiguration(^(CJWCellConfiguration *cellConfiguration) {
                        cellConfiguration.cellHeight = 60;
                        cellConfiguration.accessoryType = UITableViewCellAccessoryCheckmark;
                        cellConfiguration.selectionStyle = UITableViewCellSelectionStyleNone;
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
                        view.backgroundColor = [UIColor greenColor];
                        cellConfiguration.contentView = view;

                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
                        label.text = [NSString stringWithFormat:@"这是第%d个section，第%d个cell",i,j];
                        label.font = [UIFont systemFontOfSize:17.0];
                        label.textAlignment = NSTextAlignmentCenter;
                        [view addSubview:label];
                    });
                }
            });
        }
    }).build();
    [self.view addSubview:self.tableView];

    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    self.tableView.build();

}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        _headerView.backgroundColor = [UIColor cyanColor];
    }
    return _headerView;
}

@end
