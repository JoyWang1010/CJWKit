//
//  UIScrollView+CJWPlaceholder.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/5.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "UIScrollView+CJWPlaceholder.h"
#import <objc/runtime.h>

static const void *placeHolderViewKey = &placeHolderViewKey;
static const void *scrollWasEnabledKey = &scrollWasEnabledKey;

@interface UITableView ()

@property (nonatomic, assign) BOOL scrollWasEnabled;
@property (nonatomic, strong) UIView *placeHolderView;

@end

@implementation UIScrollView (CJWPlaceholder)
@dynamic cjw_reloadData;
@dynamic cjw_reloadDataWithView;

- (void(^)(void))cjw_reloadData {
    return ^{
        //判断传入类是否是UICollectionView或UITableView，不是不予执行下面的代码
        if ([self recognitionClass] == nil) {
            return;
        }
        [[self recognitionClass] reloadData];
        if (self.placeHolderView == nil) {
            self.placeHolderView = [self defaultPlaceholderView];
        }
        [self checkEmpty];
    };
}

- (void(^)(UIView *(^placeholder)(UIView *view)))cjw_reloadDataWithView {
    return ^(UIView *(^placeholder)(UIView *view)) {
        if (self.placeHolderView == nil) {
            self.placeHolderView = [[UIView alloc] initWithFrame:self.bounds];
            self.placeHolderView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        }
        self.placeHolderView = placeholder(self.placeHolderView);
    };
}

- (UIView *)defaultPlaceholderView {
    UIView * view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 100)/2, self.frame.size.width, 30)];
    tipsLabel.text = @"暂无内容";
    tipsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tipsLabel];
    return view;
}

- (id)recognitionClass {
    if ([self isMemberOfClass:[UICollectionView class]]) {
        return (UICollectionView *)self;
    }else if ([self isMemberOfClass:[UITableView class]]) {
        return (UITableView *)self;
    }else {
        return nil;
    }
}

- (void)checkEmpty {
    BOOL isEmpty = YES;
    if ([[self recognitionClass] isMemberOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        id<UICollectionViewDataSource> src = collectionView.dataSource;
        NSInteger section = 0;
        if ([src respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            section = [src numberOfSectionsInCollectionView:collectionView];
        }
        for (int i = 0; i < section; i++) {
            NSInteger rows = 0;
            if ([src respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
                rows = [src collectionView:collectionView numberOfItemsInSection:i];
            }
            if (rows) {
                isEmpty = NO;
            }
        }
    }else if ([[self recognitionClass] isMemberOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        id<UITableViewDataSource> src = tableView.dataSource;
        NSInteger section = 0;
        if ([src respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            section = [src numberOfSectionsInTableView:tableView];
        }
        for (int i = 0; i < section; i++) {
            NSInteger rows = 0;
            if ([src respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
                rows = [src tableView:tableView numberOfRowsInSection:i];
            }
            if (rows) {
                isEmpty = NO;
            }
        }
    }
    if (!isEmpty != !self.placeHolderView) {        //isempty为NO placeHolderView存在或者isempty为YES placeHolderView不存在
        //数据为空，需要展示placeholder
        if (isEmpty) {                              //没有placeholder，在view上添加一个
            self.scrollWasEnabled = self.scrollEnabled;//记录view的原滑动状态
            //把placehodler显示在headerview和footerview之外的位置
            if ([[self recognitionClass] isMemberOfClass:[UICollectionView class]]) {
                UICollectionView *collectionView = (UICollectionView *)self;
                UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
                CGSize headerViewSize = flowLayout.headerReferenceSize;
                self.placeHolderView.frame = CGRectMake(0, headerViewSize.height, self.frame.size.width, self.frame.size.height - headerViewSize.height);
                [self addSubview:self.placeHolderView];
            }else if ([[self recognitionClass] isMemberOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)self;
                self.placeHolderView.frame = CGRectMake(0, tableView.tableHeaderView.frame.size.height, self.frame.size.width, self.frame.size.height - tableView.tableHeaderView.frame.size.height - tableView.tableFooterView.frame.size.height);
                [self addSubview:self.placeHolderView];
            }
        }else {                                     //存在placeholder，已经加载出数据，需把placeholder移除
            self.scrollEnabled = self.scrollEnabled;//恢复原view的滑动状态
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView = nil;
        }
    }else if (isEmpty) {                            //isempty为YES placeHolderView存在
        //把placeholder置于最上层
        [self bringSubviewToFront:self.placeHolderView];
    }
}

- (void)setPlaceHolderView:(UIView *)placeHolderView {
    objc_setAssociatedObject(self, placeHolderViewKey, placeHolderView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)placeHolderView {
    return objc_getAssociatedObject(self, placeHolderViewKey);
}

- (void)setScrollWasEnabled:(BOOL)scrollWasEnabled {
    objc_setAssociatedObject(self, scrollWasEnabledKey, @(scrollWasEnabled), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)scrollWasEnabled {
    return objc_getAssociatedObject(self, scrollWasEnabledKey);
}

@end
