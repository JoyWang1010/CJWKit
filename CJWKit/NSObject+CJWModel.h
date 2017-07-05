//
//  NSObject+CJWModel.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/21.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^CJWModelChainDictionaryBlock)(NSDictionary *dictionary);
typedef id(^CJWModelChainArrayBlock)(NSArray *array);

@interface NSObject (CJWModel)

- (CJWModelChainDictionaryBlock)modelFromJsonDict;
- (CJWModelChainArrayBlock)modelArrayFromJsonArray;

@end
