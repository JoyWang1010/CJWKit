//
//  CJWDB.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/21.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWDB.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@implementation CJWQueue

+ (instancetype)manager {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (CJWQueueChainStringBlock)where {
    return ^(NSString *condition) {
        if ([self.condition containsString:@"WHERE"]) {
            self.condition = [NSString stringWithFormat:@" AND %@", condition];
        }else {
            self.condition = [NSString stringWithFormat:@"%@ WHERE %@",self.condition,condition];
        }
        return self;
    };
}

- (CJWQueueChainStringBlock)order {
    return ^(NSString *condition) {
        if ([self.condition containsString:@"ORDER BY"]) {
            NSArray *tempStrArr = [condition componentsSeparatedByString:@"ORDER BY"];
            self.condition = [NSString stringWithFormat:@"%@ORDER BY%@",self.condition, tempStrArr[1]];
        }else {
            self.condition = [NSString stringWithFormat:@" ORDER BY %@",condition];
        }
        return self;
    };
}

- (CJWQueueChainStringBlock)updateWhere {
    return ^(NSString *updateCondition) {
        self.condition = updateCondition;
        return self;
    };
}

@end

@class CJWDB;

#pragma mark - sqlite3业务类
@interface CJWSQLiteTool : NSObject
{
    NSString            *_databasePath;
    NSString            *_databaseName;
    sqlite3             *_sql;                       //数据库全局变量
    NSTimeInterval      _maxBusyRetryTimeInterval;  //数据库繁忙重复次数
    NSTimeInterval      _startBusyRetryTime;        //数据库繁忙重复时间
}


@end

static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

@implementation CJWSQLiteTool

+ (instancetype)manager {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _databaseName = FILE_NAME;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryPath = [paths objectAtIndex:0];
        _databasePath = [libraryPath stringByAppendingPathComponent:_databaseName];
        NSLog(@"_databasePath %@",_databasePath);
//        //开发数据库，没有自动创建
//        int err = sqlite3_open([self sqlitePath], (sqlite3**)&_sql);
//        if (err != SQLITE_OK) {
//            NSLog(@"error opening!: %d", err);
//        }
        //设置数据库繁忙时，等待
        if (_maxBusyRetryTimeInterval > 0.0) {
            // set the handler
            [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
        }
    }
    return self;
}

/********** 数据库操作 **********/
//设置数据库繁忙时重复次数
- (void)setMaxBusyRetryTimeInterval:(NSTimeInterval)timeout {
    _maxBusyRetryTimeInterval = timeout;
    if (!_sql) {
        return;
    }
    if (timeout > 0) {
        sqlite3_busy_handler(_sql, &FMDBDatabaseBusyHandler, (__bridge void *)(self));
    }
    else {
        // turn it off otherwise
        sqlite3_busy_handler(_sql, nil, nil);
    }
}

//设置数据库繁忙时处理句柄，
static int FMDBDatabaseBusyHandler(void *f, int count) {
    CJWSQLiteTool *self = (__bridge CJWSQLiteTool*)f;
    if (count == 0) {
        self->_startBusyRetryTime = [NSDate timeIntervalSinceReferenceDate];
        return 1;
    }
    NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - (self->_startBusyRetryTime);
    if (delta < [self maxBusyRetryTimeInterval]) {
        int requestedSleepInMillseconds = (int) arc4random_uniform(50) + 50;
        int actualSleepInMilliseconds = sqlite3_sleep(requestedSleepInMillseconds);
        if (actualSleepInMilliseconds != requestedSleepInMillseconds) {
            NSLog(@"WARNING: Requested sleep of %i milliseconds, but SQLite returned %i. Maybe SQLite wasn't built with HAVE_USLEEP=1?", requestedSleepInMillseconds, actualSleepInMilliseconds);
        }
        return 1;
    }
    return 0;
}

- (NSTimeInterval)maxBusyRetryTimeInterval {
    return _maxBusyRetryTimeInterval;
}

//确定数据库存放地址：内存、临时数据库（用后删除）、沙盒数据库
- (const char*)sqlitePath {
    if (!_databasePath) {
        return ":memory:";
    }
    if ([_databasePath length] == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    return [_databasePath fileSystemRepresentation];
}

//打开数据库
- (BOOL)openDatabase {
    if (sqlite3_open([self sqlitePath], (sqlite3**)&_sql) == SQLITE_OK) {
        return YES;
    }else {
        NSLog(@"fail to open database");
        return NO;
    }
}

//检查table是否存在
- (BOOL)checkTableExistWithName:(NSString *)tableName {
    if (![self openDatabase]) {
        return NO;
    }
    //SQLite数据库中一个特殊的名叫 SQLITE_MASTER 上执行一个SELECT查询以获得所有表的索引
    NSMutableString *sqlStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT COUNT(*) AS 'count' From sqlite_master WHERE type='table' and name = '%@'",tableName]];
    char *error;
    const char *sql = [sqlStr UTF8String];
    int result = sqlite3_exec(_sql, sql, NULL, NULL, &error);
    sqlite3_close(_sql);
    //判断是否创建成功
    if (result != SQLITE_OK) {
        return NO;
    }
    return YES;

}

//根据属性和表名建表
- (BOOL)createDatabaseWithPropertiesArray:(NSArray *)propertiesArray tableName:(NSString *)tableName {
    if (![self openDatabase]) {
        return NO;
    }
    //生成sqlite语句
    NSMutableString *sqlStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (database_id integer primary key autoincrement,",tableName]];
    [propertiesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sqlStr appendString:obj[@"m_property_name"]];
        [sqlStr appendString:@" "];
        [sqlStr appendString:obj[@"m_property_type"]];
        if (idx != propertiesArray.count - 1) {
            [sqlStr appendString:@","];
        }
    }];
    [sqlStr appendString:@")"];
    //执行创建语句并接收
    char *error;
    const char *sql = [sqlStr UTF8String];
    //执行sql语句
    //第一个参数：SqLite3对象实例
    //第二个参数：要执行的sql语句
    //第三个参数：执行完成之后的回调方法，一般为null
    //第四个参数：回调方法的第一个参数
    //第五个参数：错误日志，类似于OC中的error
    int result = sqlite3_exec(_sql, sql, NULL, NULL, &error);
    sqlite3_close(_sql);
    //判断是否创建成功
    if (result != SQLITE_OK) {
        NSLog(@"fail to create database  %s",error);
        return NO;
    }else{
        return YES;
    }
}

//根据属性和model插入数据
- (BOOL)insertWithPropertiesArray:(NSArray *)propertiesArray model:(id)model {
    if (![self openDatabase]) {
        return NO;
    }
    BOOL success = NO; //标记操作是否成功
    //生成sqlite语句
    NSMutableString *sqlStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"INSERT INTO %@ (",NSStringFromClass(object_getClass(model))]];
    NSMutableArray *bindDataArray = [NSMutableArray array];
    [propertiesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sqlStr appendString:[NSString stringWithFormat:@"%@",obj[@"m_property_name"]]];
        if (idx != propertiesArray.count - 1) {
            [sqlStr appendString:@","];
        }
    }];
    [sqlStr appendString:@") VALUES ("];
    [propertiesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [sqlStr appendString:obj[@"m_property_name"]];
//        [sqlStr appendString:@" "];
        //处理OC的对象
        NSString *propertyType = [NSString stringWithFormat:@"%@",obj[@"m_property_type"]];
        if ([propertyType isEqualToString:@"INTEGER"]) {
            [sqlStr appendString:[NSString stringWithFormat:@"%@",[model valueForKey:obj[@"m_property_name"]]?:@0]];
        }else if ([propertyType isEqualToString:@"TEXT"]){
            [sqlStr appendString:[NSString stringWithFormat:@"'%@'",[model valueForKey:obj[@"m_property_name"]]!=nil?[model valueForKey:obj[@"m_property_name"]]:@"''"]];
        }else if ([propertyType isEqualToString:@"REAL"]){
            [sqlStr appendString:[NSString stringWithFormat:@"%@",[model valueForKey:obj[@"m_property_name"]]?:@(0.0)]];
        }else if ([propertyType isEqualToString:@"BLOB"]){
            [sqlStr appendString:@"?"];
            if ([model valueForKey:obj[@"m_property_name"]] == nil) {
                [bindDataArray addObject:[NSData data]];
            }else {
                NSData *data = [self handleObjectWithProperty:[model valueForKey:obj[@"m_property_name"]]];
                [bindDataArray addObject:data];
            }
        }else if ([propertyType isEqualToString:@"NULL"]){
            [sqlStr appendString:@"NULL"];
        }else{
            [sqlStr appendString:@"NULL"];
        }
        if (idx != propertiesArray.count - 1) {
            [sqlStr appendString:@","];
        }
    }];
    [sqlStr appendString:@")"];
    //声明statement实例
    //也可以叫伴随指针
    //在准备sql语句阶段用来指向sql语句，如果sql语句执行有问题，该指针就会被置为null
    //在语句执行没问题时，该指针用来指向记录所在的内存地址
    sqlite3_stmt *stament;
    //准备sql语句
    //准备阶段的五个参数
    //1.数据库实例
    //2.sql语句
    //3.要执行多少长度的sql语句，如果该值大于0，那么就会执行该值长度的sql语句，-1就是全部执行
    //4.sql语句执行有文件就null
    //5.保存没有执行的sql语句
    int result = sqlite3_prepare_v2(_sql, sqlStr.UTF8String, -1, &stament, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"fail to call function sqlite3_prepare_v2");
    }else {
        if (bindDataArray.count > 0) {
            [bindDataArray enumerateObjectsUsingBlock:^(NSData *data, NSUInteger idx, BOOL * _Nonnull stop) {
                //bind绑定   data转换类型
                // 第1个参数：是前面prepare得到的 sqlite3_stmt * 类型变量。
                // 第2个参数：?号的索引。前面prepare的sql语句里有一个?号，假如有多个?号怎么插入？方法就是改变 bind_blob 函数第2个参数。
                // 第3个参数：二进制数据起始指针。
                // 第4个参数：二进制数据的长度，以字节为单位,如果是二进制类型绝对不可以给-1，必须具体长度。
                // 第5个参数：是个析够回调函数，告诉sqlite当把数据处理完后调用此函数来析够你的数据。这个参数我还没有使用过，因此理解也不深刻。
                sqlite3_bind_blob(stament, (int)idx + 1, data.bytes, (int)data.length, NULL);
            }];
        }
        //执行插入sql语句如果不是查询语句，while改为if，SQLITE_ROW 改为 SQLite_DONE
        if (sqlite3_step(stament) == SQLITE_DONE) {
            success = YES;
        }else {
            NSLog(@"fail to call function sqlite3_step");
        }
    }
    sqlite3_close(_sql);
    sqlite3_finalize(stament);
    return success;
}

- (NSData *)handleObjectWithProperty:(id)property {
    return [NSJSONSerialization dataWithJSONObject:property options:0 error:nil];
}

//根据属性和model查询数据
- (NSArray *)selectWithCondition:(NSString *)condition modelClass:(Class)modelClass {
    if (![self openDatabase]) {
        return @[];
    }
    //设置存放model的数组
    NSMutableArray *modelArray = [NSMutableArray array];
    //生成sqlite语句
    NSMutableString *sqlStr = [[NSMutableString alloc] initWithString:condition];
    //伴随指针
    sqlite3_stmt *stament;
    int result = sqlite3_prepare_v2(_sql, sqlStr.UTF8String, -1, &stament, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"fail to call function sqlite3_prepare_v2");
    }else {
        //遍历取出每一天记录的完整信息，当step执行的返回值为SQLITE_ROW时，就说明后面还有数据
        while (sqlite3_step(stament) == SQLITE_ROW) {
            //动态获得字段的总数
            int sumCol = sqlite3_column_count(stament);
            //初始化可变字典用来存放一条记录的信息
            id model = [[modelClass alloc] init];
            //遍历所有字段取出对应的字段值存入可变字典
            for (int i = 0; i < sumCol; i++) {
                //确定字段类型
                int type = sqlite3_column_type(stament,i);
                //得到字段名称
                //分别取出该条记录每一列的值
                //第二个参数：第几列
                //返回一个无符号常量char*
                const char* colName = sqlite3_column_name(stament, i);
                //取出字段名称
                NSString *key = [NSString stringWithCString:colName encoding:NSUTF8StringEncoding];
                switch (type) {
                    case SQLITE_INTEGER:
                    {
                        if ([key isEqualToString:@"database_id"]) {
                            continue;
                        }
                        //得到值
                        int value = sqlite3_column_int(stament, i);
                        //设置model
                        [model setValue:@(value) forKey:key];
                    }
                        break;
                    case SQLITE_FLOAT:
                    {
                        //得到值
                        float value = sqlite3_column_double(stament, i);
                        //设置model
                        [model setValue:@(value) forKey:key];
                    }
                        break;
                    case SQLITE_BLOB:
                    {
                        //得到值
                        NSData *data = [NSData dataWithBytes:sqlite3_column_blob(stament, i) length:sqlite3_column_bytes(stament, i)];
                        NSError *error = nil;
                        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                        //设置model
                        if (error == nil) {
                            [model setValue:obj forKey:key];
                        }else {
                            [model setValue:[NSNull null] forKey:key];
                        }
                    }
                        break;
                    case SQLITE_NULL:
                    {
                        //设置model
                        [model setValue:[NSNull null] forKey:key];
                    }
                        break;
                    case SQLITE_TEXT:
                    {
                        //得到值
                        const unsigned char *strChar = sqlite3_column_text(stament, i);
                        NSString *str = [[NSString alloc] initWithUTF8String:strChar];
//                        NSData *data = [NSData dataWithBytes:sqlite3_column_text(stament, i) length:sqlite3_column_int(stament, i)];
//                        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        //设置model
                        [model setValue:str forKey:key];
                    }
                        break;
                    default:
                        break;
                }
            }
            //添加到数组
            [modelArray addObject:model];
        }
        sqlite3_close(_sql);
        sqlite3_finalize(stament);
    }
    return modelArray;
}

//根据属性和model更新数据
- (BOOL)updateWithCondition:(NSString *)condition model:(id)model {
    if (![self openDatabase]) {
        return NO;
    }
    //生成sql语句
    NSMutableString *sqlStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",NSStringFromClass(object_getClass(model)),condition]];
    NSArray *resultArr =  [self selectWithCondition:sqlStr modelClass:(object_getClass(model))];
    if (resultArr.count > 0) {
        //查询到结果 更新
        //生成sqlite语句
        sqlStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"UPDATE %@ SET ",NSStringFromClass(object_getClass(model))]];
        NSArray *propertiesArray = [CJWDB propertiesForClass:object_getClass(model)];
        NSMutableArray *bindDataArray = [NSMutableArray array];
        [propertiesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //拼接更新属性的key
            [sqlStr appendString:[NSString stringWithFormat:@"%@=",obj[@"m_property_name"]]];
            //处理OC的对象,拼接更新属性的value
            NSString *propertyType = [NSString stringWithFormat:@"%@",obj[@"m_property_type"]];
            if ([propertyType isEqualToString:@"INTEGER"]) {
                [sqlStr appendString:[NSString stringWithFormat:@"%@",[model valueForKey:obj[@"m_property_name"]]?:@0]];
            }else if ([propertyType isEqualToString:@"TEXT"]){
                [sqlStr appendString:[NSString stringWithFormat:@"'%@'",[model valueForKey:obj[@"m_property_name"]]!=nil?[model valueForKey:obj[@"m_property_name"]]:@"NULL"]];
            }else if ([propertyType isEqualToString:@"REAL"]){
                [sqlStr appendString:[NSString stringWithFormat:@"%@",[model valueForKey:obj[@"m_property_name"]]?:@(0.0)]];
            }else if ([propertyType isEqualToString:@"BLOB"]){
                [sqlStr appendString:@"?"];
                if ([model valueForKey:obj[@"m_property_name"]] == nil) {
                    [bindDataArray addObject:[NSData data]];
                }else {
                    NSData *data = [self handleObjectWithProperty:[model valueForKey:obj[@"m_property_name"]]];
                    [bindDataArray addObject:data];
                }
            }else if ([propertyType isEqualToString:@"NULL"]){
                [sqlStr appendString:@"NULL"];
            }else{
                [sqlStr appendString:@"NULL"];
            }
            if (idx != propertiesArray.count - 1) {
                [sqlStr appendString:@","];
            }
        }];
        [sqlStr appendString:[NSString stringWithFormat:@" WHERE %@",condition]];
        BOOL success = NO;
        //伴随指针
        sqlite3_stmt *stament;
        int result = sqlite3_prepare_v2(_sql, sqlStr.UTF8String, -1, &stament, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"update model failed in function sqlite3_prepare_v2");
        }else {
            if (bindDataArray.count > 0) {
                [bindDataArray enumerateObjectsUsingBlock:^(NSData *data, NSUInteger idx, BOOL * _Nonnull stop) {
                    //bind绑定   data转换类型
                    // 第1个参数：是前面prepare得到的 sqlite3_stmt * 类型变量。
                    // 第2个参数：?号的索引。前面prepare的sql语句里有一个?号，假如有多个?号怎么插入？方法就是改变 bind_blob 函数第2个参数。
                    // 第3个参数：二进制数据起始指针。
                    // 第4个参数：二进制数据的长度，以字节为单位,如果是二进制类型绝对不可以给-1，必须具体长度。
                    // 第5个参数：是个析够回调函数，告诉sqlite当把数据处理完后调用此函数来析够你的数据。这个参数我还没有使用过，因此理解也不深刻。
                    sqlite3_bind_blob(stament, (int)idx + 1, data.bytes, (int)data.length, NULL);
                }];
            }
            //执行准备语句
            if (sqlite3_step(stament) != SQLITE_DONE ) {
                NSLog(@"update model failed in function sqlite3_step");
            }else {
                success = YES;
            }
        }
        //释放指针，关闭数据库
        sqlite3_finalize(stament);
        sqlite3_close(_sql);
        return success;
    }else{
        //未查询到结果，插入
        if ([self insertWithPropertiesArray:[CJWDB propertiesForClass:object_getClass(model)] model:model]) {
            return YES;
        }else {
            NSLog(@"database have no this model, try to insert failed!");
            return NO;
        }
    }
    return NO;
}

//根据属性和model删除数据
- (BOOL)deleteWithCondition:(NSString *)condition modelClass:(Class)modelClass {
    if (![self openDatabase]) {
        return NO;
    }
    //生成sqlite语句
    NSMutableString *sqlStr = [[NSMutableString alloc] initWithString:condition];
    //执行sql
    char *error;
    int result = sqlite3_exec(_sql, sqlStr.UTF8String, NULL, NULL, &error);
    sqlite3_close(_sql);
    if (result != SQLITE_OK) {
        NSLog(@"failed to %@!", condition);
        return NO;
    }
    return YES;
}

/******************************/

@end

@interface CJWDB ()
{
    dispatch_queue_t    _queue;                     //使用多线程同步
    NSArray             *class_properties_array;    //存放model属性类型和名称的数组
    Class               modelClass;
}
@end

static CJWDB *_cjwdb = nil;
static const NSString *m_property_name = @"m_property_name";
static const NSString *m_property_type = @"m_property_type";
static NSMutableDictionary *class_properties_dict;              //存放所有调用数据库方法的model属性类型和名称的字典

@implementation CJWDB
/********** 创建单例 **********/
+ (instancetype)manager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cjwdb = [super allocWithZone:zone];
    });
    return _cjwdb;
}

- (instancetype)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assert(sqlite3_threadsafe());  //判断当前splite默认环境是否为多线程
        _cjwdb = [super init];
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    });
    return _cjwdb;
}

- (id)copyWithZone:(NSZone *)zone {
    return _cjwdb;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return _cjwdb;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _cjwdb;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return _cjwdb;
}
/******************************/


/********** 用户增删改查方法 **********/
//根据model建表
- (CJWDBChainInstanceBlock)databaseWithModelClass {
    return ^(Class class) {
        NSParameterAssert(class);
        modelClass = class;
        class_properties_array = [CJWDB propertiesForClass:class];  //获取model的属性类型及名称
        [[CJWSQLiteTool manager] createDatabaseWithPropertiesArray:class_properties_array tableName:NSStringFromClass([class class])];
        return self;
    };
}

- (CJWDBChainModelBlock)insert {
    return ^(id model) {
        [self checkModelClass:model];
        if (![self checkTableExistWithModel:model]) {
            return NO;
        }
        return [[CJWSQLiteTool manager] insertWithPropertiesArray:class_properties_array model:model];
    };
}

- (CJWDBChainBoolBlock)delete {
    return ^(CJWQueue *(^queueWithCondition)(CJWQueue *condition)) {
        CJWQueue *queueCondition = [CJWQueue manager];
        queueCondition.condition = [NSString stringWithFormat:@"DELETE FROM %@",NSStringFromClass([modelClass class])];
        queueCondition = queueWithCondition(queueCondition);
        return [[CJWSQLiteTool manager] deleteWithCondition:queueCondition.condition modelClass:modelClass];;
    };
}

- (CJWDBChainModelQueueBlock)update {
    return ^(id(^queueWithCondition)(CJWQueue *condition)) {
        CJWQueue *queueCondition = [CJWQueue manager];
        queueCondition = queueWithCondition(queueCondition);
        if ([object_getClass(queueCondition.updateMdel) isMemberOfClass:[modelClass class]]) {
            NSLog(@"failed to update because model is not matching modelclass ！");
            return NO;
        }
        return [[CJWSQLiteTool manager] updateWithCondition:queueCondition.condition model:queueCondition.updateMdel];
    };
}

- (CJWDBChainArrayBlock)select {
    return ^(CJWQueue *(^queueWithCondition)(CJWQueue *condition)) {
        CJWQueue *queueCondition = [CJWQueue manager];
        queueCondition.condition = [NSString stringWithFormat:@"SELECT * FROM %@",NSStringFromClass([modelClass class])];
        queueCondition = queueWithCondition(queueCondition);
        return [[CJWSQLiteTool manager] selectWithCondition:queueCondition.condition modelClass:modelClass];
    };
}
/******************************/
#pragma mark - 列出model的所有属性
+ (NSArray *)propertiesForClass:(Class)cls {
    //            NULL	值是一个 NULL 值。
    //            INTEGER	值是一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
    //            REAL	值是一个浮点值，存储为 8 字节的 IEEE 浮点数字。
    //            TEXT	值是一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
    //            BLOB	值是一个 blob 数据，完全根据它的输入存储。
    //            char  值是char。
    NSMutableArray *tmpPropertiesArray = class_properties_dict[NSStringFromClass([cls class])];
    if (tmpPropertiesArray) {
        return tmpPropertiesArray;
    }
    tmpPropertiesArray = [NSMutableArray array];
    unsigned int properticeCount = 0;
    objc_property_t *properticesList = class_copyPropertyList(cls, &properticeCount);
    if (properticeCount > 0) {
        @autoreleasepool {
            for (unsigned int i = 0; i < properticeCount; i++ ) {
                objc_property_t property = properticesList[i];
                NSString *p_name = @(property_getName(property));
                NSString *p_type = [NSString stringWithCString:property_copyAttributeValue(property, "T") encoding:NSUTF8StringEncoding];
                
                const char *type = [p_type UTF8String];
                switch (type[0]) {
                    case _C_INT: // int
                    case _C_LNG: // long
                    case _C_LNG_LNG: // long long
                    case _C_UINT: // unsigned int
                    case _C_ULNG: // unsigned long
                    case _C_ULNG_LNG: // unsigned long long
                    case _C_SHT: // short
                    case _C_USHT: // unsigned short
                    case _C_BOOL: // BOOL
                        p_type = @"INTEGER";
                        break;
                    case _C_FLT: // float
                    case _C_DBL: // double
                        p_type = @"REAL";
                        break;
                    case _C_ID:   //类
                    {
                        //获得类名
                        NSString *cls = [NSString stringWithUTF8String:type];
                        cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
                        cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        //获得类的协议（如果类中还包含model，那么需要配置类遵循的协议为需要的model）
#pragma clang diagnostic ignored "-Wunused-variable"
                        NSString *protocolName = @"";
                        if ([cls containsString:@"<"] && [cls containsString:@">"]) {
                            cls = [[cls componentsSeparatedByString:@"<"] firstObject];
                            //propertyName为cls中包含的model
                            p_name = [[cls componentsSeparatedByString:@"<"] lastObject];
                            p_name = [p_name substringToIndex:p_name.length - 1];
                        }
                        //判断类的类型
                        if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                            p_type = @"REAL";
                        }else if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                            p_type = @"TEXT";
                        }else if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                            p_type = @"NULL";
                        }else if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                            if (p_name.length > 0) {
                                p_type = @"NULL";
//                                continue;
                                //数组中存的是一个model类，使用外键关联表，暂时不考虑
//                                p_type = @"VARCHAR";
                            }else {
                                p_type = @"BLOB";
                            }
                        }else if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                            p_type = @"BLOB";
                        }else {
                            p_type = @"NULL";
//                            continue;
                            //属性类型为一个model类，使用外键关联表，暂时不考虑
//                            p_type = @"VARCHAR";
                        }
                    }
                        break;
                    default:
                        p_type = @"NULL";
//                        continue;
                        break;
                }
                [tmpPropertiesArray addObject:@{m_property_name:p_name,
                                                m_property_type:p_type}];
            }
            [class_properties_dict setObject:tmpPropertiesArray forKey:NSStringFromClass(cls)];
            free(properticesList);
        }
    }
    NSAssert(tmpPropertiesArray.count > 0, @"modelclass has no propertices");
    return tmpPropertiesArray;
}



//检查model是否匹配
- (void)checkModelClass:(id)model {
    NSAssert([model isMemberOfClass:[modelClass class]], @"modelclass don`t matching model");
}

//检查table是否存在
- (BOOL)checkTableExistWithModel:(id)model {
    if (![[CJWSQLiteTool manager] checkTableExistWithName:NSStringFromClass(object_getClass(model))]) {
        if (self.databaseWithModelClass(model)) {
            return YES;
        }else {
            NSLog(@"table is not exist!");
            return NO;
        }
    }
    return YES;
}

@end
