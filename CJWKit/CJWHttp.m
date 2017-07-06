//
//  CJWHttp.m
//  CJWKitExample
//
//  Created by JoyWang on 2017/6/19.
//  Copyright © 2017年 JoyWang. All rights reserved.
//

#import "CJWHttp.h"

@interface CJWHttp () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>


@property (nonatomic, copy) CJWHttp *(^urlString)(NSString *string);
@property (nonatomic, copy) CJWHttp *(^header)(NSDictionary *dictionary);
@property (nonatomic, copy) CJWHttp *(^parameters)(NSDictionary *dictionary);
@property (nonatomic, copy) CJWHttp *(^timeoutInterval)(NSTimeInterval timeoutInterval);
@property (nonatomic, copy) CJWHttp *(^certificatePath)(NSString *string);

@property (readwrite, nonatomic, strong) NSMutableURLRequest *request;
@property (readwrite, nonatomic, copy) NSString *sslCertificatePathString;
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfigution;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSURLSessionTask *sessionTask;
@property (readwrite, nonatomic, strong) NSMutableData *responseData;
@property (readwrite, nonatomic, copy) void(^completeWithSuccessHandle)(NSData * _Nullable responseData);
@property (readwrite, nonatomic, copy) void(^completeWithFailureHandle)(NSError * _Nullable error);

@end

@implementation CJWHttp

+ (instancetype)manager {
    return [[[CJWHttp class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionConfigution = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfigution delegate:self delegateQueue:self.operationQueue];
        self.request = [[NSMutableURLRequest alloc] init];
    }
    return self;
}

- (CJWHttp *(^)(NSString *string))urlString {
    return ^(NSString *urlString) {
        NSParameterAssert(urlString);
        self.request.URL = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        return self;
    };
}

- (CJWHttp *(^)(NSDictionary *dictionary))header {
    return ^(NSDictionary *header) {
        NSParameterAssert(header);
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           if (![key isKindOfClass:[NSString class]] || ![obj isKindOfClass:[NSString class]]) {
               @throw [NSException exceptionWithName:@"CJWHttpNullInstanceException" reason:@"The key or value in header can not be nil" userInfo:nil];
           }
           [self.request setValue:obj forHTTPHeaderField:key];
        }];
        //设置默认Content-Type为application/x-www-form-urlencoded
        if (![self.request valueForHTTPHeaderField:@"Content-Type"]) {
            [self.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        return self;
    };
}

- (CJWHttp *(^)(NSDictionary *dictionary))parameters {
    return ^(NSDictionary *parameters) {
        NSParameterAssert(parameters);
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![key isKindOfClass:[NSString class]] || ![obj isKindOfClass:[NSString class]]) {
                @throw [NSException exceptionWithName:@"CJWHttpNullInstanceException" reason:@"The key or value in parameters is nil" userInfo:nil];
            }

        }];

        return self;
    };
}

- (CJWHttp *(^)(NSTimeInterval timeoutInterval))timeoutInterval {
    return ^(NSTimeInterval timeoutInterval) {
        NSParameterAssert(timeoutInterval);
        self.request.timeoutInterval = timeoutInterval;
        return self;
    };
}

- (CJWHttp *(^)(NSString *string))sslCertificatePath {
    return ^(NSString *sslCertificatePath) {
        NSParameterAssert(sslCertificatePath);
        self.sslCertificatePathString = sslCertificatePath;
        return self;
    };
}

//- (CJWHttpChainSSLPinningModeBlock)sslPinningMode {
//    
//}

- (void(^)(void(^success)(NSData *responseData),void(^failure)(NSError *error)))post {
    return ^(void(^success)(NSData *responseData), void(^failure)(NSError *error)) {
        self.completeWithSuccessHandle = success;
        self.completeWithFailureHandle = failure;
        self.sessionTask = [self.session dataTaskWithRequest:self.request];
        [self.sessionTask resume];
    };
}

#pragma mark - NSURLSessionDelegate
/**
 *得到一个失败的session
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    
}


/**
 *SSL验证,在此处设置SSL验证策略和信息
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
        /**
         *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA），请替换掉你的证书名称
         */
        NSString *cerPath = self.sslCertificatePathString;//自签名证书
        NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
        
        SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
        NSCAssert(caRef != nil, @"caRef is nil");
        
        NSArray *caArray = @[(__bridge id)(caRef)];
        NSCAssert(caArray != nil, @"caArray is nil");
        
        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
        SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
        NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
        
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential = nil;
//        if ([.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {  //证书可用
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
//        } else {
//            //不可用则取消ssl验证
//            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
//        }
        completionHandler(disposition, credential);
    }
}

/**
 *APP后台时接收到连接消息
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

#pragma mark - NSURLSessionDataDelegate
/**
 *接收到服务端响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *接收到数据（可能调用多次）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

#pragma mark - NSURLSessionTaskDelegate
/**
 *请求成功或者失败（如果失败，error有值）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
        if (error != nil) {
            if (self.completeWithFailureHandle) {
                self.completeWithFailureHandle(error);
            }
        }else {
            if (self.completeWithSuccessHandle) {
                self.completeWithSuccessHandle(self.responseData);
            }
        }
    });
}

- (NSMutableData *)responseData {
    if (_responseData == nil) {
        _responseData = [[NSMutableData alloc] init];
    }
    return _responseData;
}

@end
