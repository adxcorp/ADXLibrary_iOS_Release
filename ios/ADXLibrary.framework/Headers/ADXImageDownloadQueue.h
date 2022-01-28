//
//  ADXImageDownloadQueue.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ADXImageDownloadQueueCompletionBlock)(NSDictionary <NSURL *, UIImage *> *result, NSArray *errors);

@interface ADXImageDownloadQueue : NSObject

- (void)addDownloadImageURLs:(NSArray<NSURL *> *)imageURLs
             completionBlock:(ADXImageDownloadQueueCompletionBlock)completionBlock;

- (void)cancelAllDownloads;

@end

NS_ASSUME_NONNULL_END
