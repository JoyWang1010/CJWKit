//
//  CJWHttp.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/19.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define N(url) [CJWHttp manager].urlString(url)

@interface CJWHttp : NSObject

+ (instancetype)manager;

- (CJWHttp *(^)(NSString *string))urlString;

- (CJWHttp *(^)(NSDictionary *dictionary))header;

- (CJWHttp *(^)(NSDictionary *dictionary))parameters;

- (CJWHttp *(^)(NSTimeInterval timeoutInterval))timeoutInterval;

- (CJWHttp *(^)(NSString *string))sslCertificatePath;

- (void(^)(void(^success)(NSData *responseData),void(^failure)(NSError *error)))post;

@end
