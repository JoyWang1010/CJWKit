//
//  NSObject+CJWModel.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/21.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CJWModel)

- (id(^)(NSDictionary *jsonDictionary))modelFromJsonDict;
- (id(^)(NSArray *jsonArray))modelArrayFromJsonArray;
- (id(^)(NSString *jsonString))modelFromJsonString;

@end
