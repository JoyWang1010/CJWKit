//
//  UITableView+CJWStaticTableView.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/29.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "UITableView+CJWStaticTableView.h"
#import <objc/runtime.h>

@interface CJWCellConfiguration ()

@end

@implementation CJWCellConfiguration

@end

@interface CJWSectionConfiguration ()

@property (nonatomic, strong) NSMutableArray *staticCellArray;              //存放所有的cell数据配置

@end

@implementation CJWSectionConfiguration

- (void(^)(void(^build)(CJWCellConfiguration *cellConfiguration)))cellConfiguration {
    return ^(void(^build)(CJWCellConfiguration *cellConfiguration)) {
        CJWCellConfiguration *cellConfiguration = [[CJWCellConfiguration alloc] init];
        build(cellConfiguration);
        [self.staticCellArray addObject:cellConfiguration];
    };
}

- (CJWCellConfiguration *)cellConfigurationWithRow:(NSInteger)row {
    //self.staticSectionArray装载了所有cell的对象
    if (self.staticCellArray[row] != nil) {
        return self.staticCellArray[row];
    }
    CJWCellConfiguration *cellConfiguration = [[CJWCellConfiguration alloc] init];
    cellConfiguration.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    cellConfiguration.cellHeight = 0.1f;
    cellConfiguration.accessoryType = UITableViewCellAccessoryNone;
    cellConfiguration.selectionStyle = UITableViewCellSelectionStyleNone;
    return cellConfiguration;
}

- (NSMutableArray *)staticCellArray {
    if (_staticCellArray == nil) {
        _staticCellArray = [NSMutableArray array];
    }
    return _staticCellArray;
}

@end

@interface CJWTableViewConfiguration () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,  strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *staticSectionArray;           //存放所有的section数据配置

@end

@implementation CJWTableViewConfiguration

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
    }
    return self;
}

- (void(^)(void(^build)(CJWSectionConfiguration *sectionConfiguration)))sectionConfiguration {
    return ^(void(^build)(CJWSectionConfiguration *sectionConfiguration)) {
        CJWSectionConfiguration *sectionConfiguration = [[CJWSectionConfiguration alloc] init];
        build(sectionConfiguration);
        [self.staticSectionArray addObject:sectionConfiguration];
    };
}

- (CJWSectionConfiguration *)sectionConfigurationWithSection:(NSInteger)section {
    //self.staticSectionArray装载了所有section的对象
    if (self.staticSectionArray[section] != nil) {
        CJWSectionConfiguration *sectionConfiguration = self.staticSectionArray[section];
        if (sectionConfiguration.headerViewHeight == 0) {
            sectionConfiguration.headerViewHeight = 0.01f;
        }
        if (sectionConfiguration.footerViewHeight == 0) {
            sectionConfiguration.footerViewHeight = 0.01f;
        }
        return sectionConfiguration;
    }
    CJWSectionConfiguration *sectionConfiguration = [[CJWSectionConfiguration alloc] init];
    sectionConfiguration.staticCellArray = [NSMutableArray array];
    sectionConfiguration.headerView = [[UIView alloc] initWithFrame:CGRectZero];
    sectionConfiguration.footerView = [[UIView alloc] initWithFrame:CGRectZero];
    sectionConfiguration.headerViewHeight = 0.01f;
    sectionConfiguration.footerViewHeight = 0.01f;
    return sectionConfiguration;
}

- (void)setTableViewHeaderView:(UIView *)tableViewHeaderView {
    self.tableView.tableHeaderView = tableViewHeaderView;
}

- (void)setTableViewFooterView:(UIView *)tableViewFooterView {
    self.tableView.tableFooterView = tableViewFooterView;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.tableView.backgroundColor = backgroundColor;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    self.tableView.separatorStyle = separatorStyle;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    _separatorInset = separatorInset;
    [self.tableView setSeparatorInset:separatorInset];
    [self.tableView setLayoutMargins:separatorInset];
}

- (NSMutableArray *)staticSectionArray {
    if (_staticSectionArray == nil) {
        _staticSectionArray = [NSMutableArray array];
    }
    return _staticSectionArray;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.staticSectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:section];
    return sectionConfiguration.staticCellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //静态cell，不重用
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:indexPath.section];
    CJWCellConfiguration *cellConfiguration = [sectionConfiguration cellConfigurationWithRow:indexPath.row];
    [cell.contentView addSubview:cellConfiguration.contentView];
    [cell setAccessoryType:cellConfiguration.accessoryType];
    [cell setSelectionStyle:cellConfiguration.selectionStyle];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.separatorInset.top) {
        [cell setSeparatorInset:self.separatorInset];
        [cell setLayoutMargins:self.separatorInset];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:indexPath.section];
    CJWCellConfiguration *cellConfiguration = [sectionConfiguration cellConfigurationWithRow:indexPath.row];
    return cellConfiguration.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:section];
    return sectionConfiguration.headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:section];
    return sectionConfiguration.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:section];
    return sectionConfiguration.footerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CJWSectionConfiguration *sectionConfiguration = [self sectionConfigurationWithSection:section];
    return sectionConfiguration.footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellDidSelected) {
        self.cellDidSelected();
    }
}

@end

static const void *configurationKey = &configurationKey;

@implementation UITableView (CJWStaticTableView)
@dynamic tableViewConfiguration;
@dynamic clear;
@dynamic build;

- (UITableView *(^)(void(^build)(CJWTableViewConfiguration *tableViewConfiguration))) tableViewConfiguration {
    return ^(void(^build)(CJWTableViewConfiguration *tableViewConfiguration)) {
        if (self.configuration == nil) {
            self.configuration = [[CJWTableViewConfiguration alloc] initWithTableView:self];
        }
        //在CJWTableViewConfiguration类中实现tableview的代理
        self.delegate = self.configuration;
        self.dataSource = self.configuration;
        build(self.configuration);
        return self;
    };
}

- (UITableView *(^)(void))clear {
    return ^{
        self.configuration = nil;
        self.configuration = [[CJWTableViewConfiguration alloc] initWithTableView:self];
        return self;
    };
}

- (void(^)(void))build {
    return ^{
        [self reloadData];
    };
}

- (CJWTableViewConfiguration *)configuration {
    return objc_getAssociatedObject(self, configurationKey);
}

- (void)setConfiguration:(CJWTableViewConfiguration *)configuration {
    objc_setAssociatedObject(self, configurationKey, configuration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
