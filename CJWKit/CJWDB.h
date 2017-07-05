//
//  CJWDB.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/21.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#define M(class) [CJWDB manager].databaseWithModelClass(class)
#define FILE_NAME [NSString stringWithFormat:@"%@.sqlite",SQLITE_NAME]
#define SQLITE_NAME @"Database"

#import <Foundation/Foundation.h>

@class CJWQueue;

typedef CJWQueue *(^CJWQueueChainStringBlock)(NSString *condititon);

//查询condition
@interface CJWQueue : NSObject

@property (nonatomic, copy) NSString *condition;
@property (nonatomic, strong) id updateMdel;
@property (nonatomic, copy) CJWQueueChainStringBlock where;
@property (nonatomic, copy) CJWQueueChainStringBlock order;
@property (nonatomic, copy) CJWQueueChainStringBlock updateWhere;

@end

@class CJWDB;

typedef CJWDB *(^CJWDBChainInstanceBlock)(Class modelClass);
typedef BOOL(^CJWDBChainModelBlock)(id model);
typedef BOOL(^CJWDBChainBoolBlock)(CJWQueue *(^queueWithCondition)(CJWQueue *condition));
typedef BOOL(^CJWDBChainModelQueueBlock)(id(^queueWithCondition)(CJWQueue *condition));
typedef NSArray *(^CJWDBChainArrayBlock)(CJWQueue *(^queueWithCondition)(CJWQueue *condition));

@interface CJWDB : NSObject

@property (nonatomic, copy) CJWDBChainInstanceBlock databaseWithModelClass;
@property (nonatomic, copy) CJWDBChainModelBlock create;
@property (nonatomic, copy) CJWDBChainBoolBlock delete;
@property (nonatomic, copy) CJWDBChainModelQueueBlock update;
@property (nonatomic, copy) CJWDBChainArrayBlock select;

+ (instancetype)manager;

- (CJWDBChainInstanceBlock)databaseWithModelClass;

- (CJWDBChainModelBlock)insert;

- (CJWDBChainBoolBlock)delete;

- (CJWDBChainModelQueueBlock)update;

- (CJWDBChainArrayBlock)select;

+ (NSArray *)propertiesForClass:(Class)cls;

@end
