//
//  StudentModel.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/22.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StudentModel : NSObject

@property (nonatomic, copy) NSString *myName;
@property (nonatomic, assign) NSInteger myNumber;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, copy) NSMutableArray *mutableArray;
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic, strong) NSMutableDictionary *mutableDict;
@property (nonatomic, assign) BOOL right;
@property (nonatomic, setter=setLastname:) NSString *myLastName;
@property (nonatomic, assign) NSInteger myInteger;
@property (nonatomic, assign) int myInt;
@property (nonatomic, assign) unsigned int myUnsignInt;
@property (nonatomic, assign) float myFloat;
@property (nonatomic, assign) double myDouble;
@property (nonatomic, assign) long myLong;

@end
