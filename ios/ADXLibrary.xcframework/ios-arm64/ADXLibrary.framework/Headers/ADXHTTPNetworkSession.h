//
//  ADXHTTPNetworkSession.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ADXHTTPMethod NS_STRING_ENUM;
extern ADXHTTPMethod const ADXHTTPMethodGet;
extern ADXHTTPMethod const ADXHTTPMethodPost;

@interface ADXHTTPNetworkSession : NSObject
/**
 Singleton instance of @c ADXHTTPNetworkSession.
 */
+ (instancetype)sharedInstance;


/**
 Initializes a HTTP network request.
 @param request Request to send.
 @param responseHandler Optional response handler that will be invoked on the current thread.
 @param errorHandler Optional error handler that will be invoked on the current thread.
 @param shouldRedirectWithNewRequest Optional logic control block to determine if a redirection should occur. This is invoked on the current thread.
 @returns The HTTP networking task.
 */
+ (NSURLSessionTask *)taskWithHttpRequest:(NSURLRequest *)request
                          responseHandler:(void (^ _Nullable)(NSData *data, NSHTTPURLResponse *response))responseHandler
                             errorHandler:(void (^ _Nullable)(NSError *error))errorHandler
             shouldRedirectWithNewRequest:(BOOL (^ _Nullable)(NSURLSessionTask *task, NSURLRequest *newRequest))shouldRedirectWithNewRequest;


/**
 Initializes a HTTP network request and immediately sends it.
 @param request Request to send.
 @param responseHandler Optional response handler that will be invoked on the main thread.
 @param errorHandler Optional error handler that will be invoked on the main thread.
 @returns The HTTP networking task.
 */
+ (NSURLSessionTask *)startTaskWithHttpRequest:(NSURLRequest *)request
                               responseHandler:(void (^ _Nullable)(NSData *data, NSHTTPURLResponse *response))responseHandler
                                  errorHandler:(void (^ _Nullable)(NSError *error))errorHandler;

/**
 Initializes a HTTP network request and immediately sends it.
 @param request Request to send.
 @param responseHandler Optional response handler that will be invoked on the main thread.
 @param errorHandler Optional error handler that will be invoked on the main thread.
 @param shouldRedirectWithNewRequest Optional logic control block to determine if a redirection should occur. This is invoked on the current thread.
 @returns The HTTP networking task.
 */
+ (NSURLSessionTask *)startTaskWithHttpRequest:(NSURLRequest *)request
                               responseHandler:(void (^ _Nullable)(NSData *data, NSHTTPURLResponse *response))responseHandler
                                  errorHandler:(void (^ _Nullable)(NSError *error))errorHandler
                  shouldRedirectWithNewRequest:(BOOL (^ _Nullable)(NSURLSessionTask *task, NSURLRequest *newRequest))shouldRedirectWithNewRequest;


+ (NSURLSessionTask *)taskWithHTTPRequestURLString:(NSString *)URLString
                                            method:(ADXHTTPMethod)method
                                        parameters:(NSDictionary *_Nullable)parameters
                                   responseHandler:(void (^ _Nullable)(NSData *data, NSHTTPURLResponse *response))responseHandler
                                      errorHandler:(void (^ _Nullable)(NSError * error))errorHandler
                      shouldRedirectWithNewRequest:(BOOL (^ _Nullable)(NSURLSessionTask *task, NSURLRequest * newRequest))shouldRedirectWithNewRequest;

// GET
+ (NSURLSessionTask *)GETStartTaskWithRequestURLString:(NSString *)URLString;


+ (NSURLSessionTask *)GETStartTaskWithHTTPRequestURLString:(NSString *)URLString
                                           responseHandler:(void (^ _Nullable)(NSData *data, NSDictionary *dict, NSHTTPURLResponse *response))responseHandler;

+ (NSURLSessionTask *)GETStartTaskWithHTTPRequestURLString:(NSString *)URLString
                                                parameters:(NSDictionary *_Nullable)parameters
                                           responseHandler:(void (^ _Nullable)(NSData *data, NSDictionary *dict, NSHTTPURLResponse *response))responseHandler;


+ (NSURLSessionTask *)GETStartTaskWithHTTPRequestURLString:(NSString *)URLString
                                                parameters:(NSDictionary *_Nullable)parameters
                                           responseHandler:(void (^ _Nullable)(NSData *data, NSDictionary *dict, NSHTTPURLResponse *response))responseHandler
                                              errorHandler:(void (^ _Nullable)(NSError * error))errorHandler;

+ (NSURLSessionTask *)GETStartTaskWithHTTPRequestURLString:(NSString *)URLString
                                                parameters:(NSDictionary *_Nullable)parameters
                                           responseHandler:(void (^ _Nullable)(NSData *data, NSDictionary *dict, NSHTTPURLResponse *response))responseHandler
                                              errorHandler:(void (^ _Nullable)(NSError * error))errorHandler
                              shouldRedirectWithNewRequest:(BOOL (^ _Nullable)(NSURLSessionTask * task, NSURLRequest * newRequest))shouldRedirectWithNewRequest;

@end

NS_ASSUME_NONNULL_END
