//
//  UIScrollView+CJWPlaceholder.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/7/5.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (CJWPlaceholder)

@property (nonatomic, copy) void(^cjw_reloadData)(void);
@property (nonatomic, copy) void(^cjw_reloadDataWithView)(UIView *(^placeholder)(UIView *view));

@end
