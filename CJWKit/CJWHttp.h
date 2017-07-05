//
//  CJWHttp.h
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/19.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define N(url) [CJWHttp manager].urlString(url)

//typedef NS_ENUM(NSInteger, SSLPinningMode) {
//    SSLPinningModeNone,
//    SSLPinningModePublicKey,
//    SSLPinningModeCertificate,
//};

@class CJWHttp;

typedef CJWHttp *(^CJWHttpChainStringBlock)(NSString *string);
typedef CJWHttp *(^CJWHttpChainDictionaryBlock)(NSDictionary *dictionary);
typedef CJWHttp *(^CJWHttpChainTimeIntervalBlock)(NSTimeInterval timeoutInterval);
typedef void(^CJWHttpChainResponseBlock)(void(^success)(NSData *responseData),void(^failure)(NSError *error));

@interface CJWHttp : NSObject

@property (nonatomic, copy) CJWHttpChainStringBlock urlString;
@property (nonatomic, copy) CJWHttpChainDictionaryBlock header;
@property (nonatomic, copy) CJWHttpChainDictionaryBlock parameters;
@property (nonatomic, copy) CJWHttpChainTimeIntervalBlock timeoutInterval;
@property (nonatomic, copy) CJWHttpChainStringBlock certificatePath;

+ (instancetype)manager;

- (CJWHttpChainStringBlock)urlString;

- (CJWHttpChainDictionaryBlock)header;

- (CJWHttpChainDictionaryBlock)parameters;

- (CJWHttpChainTimeIntervalBlock)timeoutInterval;

- (CJWHttpChainStringBlock)sslCertificatePath;

//- (CJWHttpChainSSLPinningModeBlock)sslPinningMode;

- (CJWHttpChainResponseBlock)post;

@end
