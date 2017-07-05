//
//  NSObject+CJWModel.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/21.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "NSObject+CJWModel.h"
#import <objc/runtime.h>

@interface CJWModelUtil : NSObject

@end

@implementation CJWModelUtil

static const NSString *m_property_name = @"m_property_name";
static const NSString *m_property_type = @"m_property_type";
static NSMutableDictionary *class_properties_dict;

+ (void)initialize {
    class_properties_dict = [NSMutableDictionary dictionary];
}

+ (instancetype)modelFromJsonDict:(NSDictionary *)jsonDict outputModel:(Class)modelClass {
    if ([jsonDict isEqual:[NSNull null]] || jsonDict == nil || !jsonDict) {
        @throw [NSException exceptionWithName:@"CJWModelNullInstanceException" reason:@"jsonDict can not be nil" userInfo:nil];
        return nil;
    }
    id modelObj = [[modelClass alloc] init];
    NSArray *propertiesArray = [self propertiesForClass:modelClass];
    NSArray *keyArrays = [jsonDict allKeys];
    for (NSDictionary *propertyDict in propertiesArray) {
        NSString *propertyName = propertyDict[m_property_name];
        NSString *propertyType = propertyDict[m_property_type];
        if ([keyArrays containsObject:propertyName]) //判断jsondict中是否存在model的属性，如果存在再进行转换
        {
            const char *type = [propertyType UTF8String];
            switch (type[0]) {
                case _C_INT: // int
                    [modelObj setValue:[NSNumber numberWithInteger:[jsonDict[propertyName] integerValue]] forKey:propertyName];
                    break;
                case _C_LNG: // long
                    [modelObj setValue:[NSNumber numberWithLong:[jsonDict[propertyName] longValue]] forKey:propertyName];
                    break;
                case _C_SHT: // short
                    [modelObj setValue:[NSNumber numberWithShort:[jsonDict[propertyName] shortValue]] forKey:propertyName];
                    break;
                case _C_LNG_LNG: // long long
                    [modelObj setValue:[NSNumber numberWithLongLong:[jsonDict[propertyName] longLongValue]] forKey:propertyName];
                    break;
                case _C_UINT: // unsigned int
                    [modelObj setValue:[NSNumber numberWithInteger:[jsonDict[propertyName] unsignedIntegerValue]] forKey:propertyName];
                    break;
                case _C_USHT: // unsigned short
                    [modelObj setValue:[NSNumber numberWithUnsignedShort:[jsonDict[propertyName] unsignedShortValue]] forKey:propertyName];
                    break;
                case _C_ULNG: // unsigned long
                    [modelObj setValue:[NSNumber numberWithUnsignedLong:[jsonDict[propertyName] unsignedLongValue]] forKey:propertyName];
                    break;
                case _C_ULNG_LNG: // unsigned long long
                    [modelObj setValue:[NSNumber numberWithUnsignedLongLong:[jsonDict[propertyName] longLongValue]] forKey:propertyName];
                    break;
                case _C_FLT: // float
                    [modelObj setValue:[NSNumber numberWithFloat:[jsonDict[propertyName] floatValue]] forKey:propertyName];
                    break;
                case _C_DBL: // double
                    [modelObj setValue:[NSNumber numberWithDouble:[jsonDict[propertyName] doubleValue]] forKey:propertyName];
                    break;
                case _C_BOOL: // BOOL
                    [modelObj setValue:[NSNumber numberWithBool:[jsonDict[propertyName] boolValue]] forKey:propertyName];
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
                        propertyName = [[cls componentsSeparatedByString:@"<"] lastObject];
                        propertyName = [propertyName substringToIndex:propertyName.length - 1];
                    }
                    //判断类的类型
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                        //用来处理高精度资金财务类型数字
                        [modelObj setValue:[NSNumber numberWithDouble:[jsonDict[propertyName] doubleValue]] forKey:propertyName];
                    }else if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                        //默认返回时间字段为距1970年的毫秒值
                        NSTimeInterval timeInterval = [jsonDict[propertyName] longLongValue]/1000;
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                        [modelObj setValue:date forKey:propertyName];
                    }else if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                        NSString *string = @"";
                        NSString *tmpString = jsonDict[propertyName];
                        if (tmpString != nil || jsonDict[propertyName] != [NSNull null]) {
                            if ([tmpString isKindOfClass:[NSString class]]) {
                                if (![tmpString isEqualToString:@"<null>"] && ![tmpString isEqualToString:@"nil"]) {
                                    string = [NSString stringWithFormat:@"%@",tmpString];
                                }
                            }
                        }
                        [modelObj setValue:string forKey:propertyName];
                    }else if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                        NSMutableArray *tmpArr = [NSMutableArray array];
                        NSArray *tmpJsonArr = jsonDict[propertyName];
                        if ([tmpJsonArr isEqual:[NSNull null]] || tmpJsonArr == nil) {
                            continue;
                        }
                        if ([tmpJsonArr isKindOfClass:[NSArray class]]) {
                            continue;
                        }
                        for (id value in tmpJsonArr) {
                            if (propertyName.length > 0) {
                                id model = [CJWModelUtil modelFromJsonDict:value outputModel:NSClassFromString(propertyName)];
                                [tmpArr addObject:model];
                            }else {
                                [tmpArr addObject:value];
                            }
                        }
                        [modelObj setValue:tmpArr forKey:propertyName];
                    }else if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                        NSDictionary *tmpDict = jsonDict[propertyName];
                        if ([tmpDict isEqual:[NSNull null]] || tmpDict == nil) {
                            continue;
                        }
                        if ([tmpDict isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        [modelObj setValue:tmpDict forKey:propertyName];
                    }else {
                        //属性类型为一个model类
                        id model = [CJWModelUtil modelFromJsonDict:jsonDict[propertyName] outputModel:NSClassFromString(cls)];
                        [modelObj setValue:model forKey:propertyName];
                    }
                }
                default:
                    break;
            }
        }
    }
    return modelObj;
}

+ (NSArray *)propertiesForClass:(Class)cls {
    NSMutableArray *tmpPropertiesArray = class_properties_dict[NSStringFromClass(cls)];
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
                [tmpPropertiesArray addObject:@{m_property_name:p_name,
                                                m_property_type:p_type}];
            }
            [class_properties_dict setObject:tmpPropertiesArray forKey:NSStringFromClass(cls)];
            free(properticesList);
        }
    }
    return tmpPropertiesArray;
}

@end

@implementation NSObject (CJWModel)
- (CJWModelChainDictionaryBlock)modelFromJsonDict {
    return ^(NSDictionary *jsonDict) {
        return [CJWModelUtil modelFromJsonDict:jsonDict outputModel:[self class]];
    };
}

- (CJWModelChainArrayBlock)modelArrayFromJsonArray {
    return ^(NSArray *jsonArray) {
        NSMutableArray *tempArray = [NSMutableArray array];
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id tempModel = [CJWModelUtil modelFromJsonDict:obj outputModel:[self class]];
            [tempArray addObject:tempModel];
        }];
        return tempArray;
    };
}

@end
