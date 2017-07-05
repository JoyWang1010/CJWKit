//
//  UITableView+CJWStaticTableView.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/29.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <UIKit/UIKit.h>

//cell的属性
@interface CJWCellConfiguration : NSObject

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

@end

//储存section的属性及tableview每个section的cell的configuration对象
@interface CJWSectionConfiguration : NSObject

@property (nonatomic, copy) void(^cellConfiguration)(void(^build)(CJWCellConfiguration *cellConfiguration));
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat footerViewHeight;

@end

//储存tableview的属性及tableview每个section的configuration对象
@interface CJWTableViewConfiguration : NSObject

@property (nonatomic, copy) void(^sectionConfiguration)(void(^build)(CJWSectionConfiguration *sectionConfiguration));
@property (nonatomic, strong) UIView *tableViewHeaderView;
@property (nonatomic, strong) UIView *tableViewFooterView;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) UITableViewCellSeparatorStyle separatorStyle;
@property (nonatomic, assign) UIEdgeInsets separatorInset;
@property (nonatomic, copy) void(^cellDidSelected)(void);

@end

@interface UITableView (CJWStaticTableView)

@property (nonatomic, strong) CJWTableViewConfiguration *configuration;
@property (nonatomic, copy) UITableView *(^tableViewConfiguration)(void(^build)(CJWTableViewConfiguration *tableViewConfiguration));
@property (nonatomic, copy) UITableView *(^clear)(void);
@property (nonatomic, copy) void(^build)(void);

@end
