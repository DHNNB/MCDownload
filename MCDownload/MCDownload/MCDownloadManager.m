//
//  MCDownloadManager.m
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "MCDownloadManager.h"
#import "MCOperation.h"
@interface MCDownloadManager()
@property (retain, nonatomic) NSOperationQueue * downloadQueue;
@end
@implementation MCDownloadManager
+ (MCDownloadManager * )downloadManager
{
    static dispatch_once_t onceToken;
    static MCDownloadManager * manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[MCDownloadManager alloc]init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxCount = 1;
    }
    return self;
}
- (void)donwloadProgress:(CGFloat)progress withOperation:(MCOperation * )operation
{
    if (_delegate && [_delegate respondsToSelector:@selector(donwloadProgress:withOperation:)]) {
        [_delegate donwloadProgress:progress withOperation:operation];
    }
}
- (void)addDonwloadWithModel:(MCModel *)model
{
    // again 为yes 不断点续传
    MCOperation * operation = [[MCOperation  alloc]initWithModel:model delegate:self isAgain:YES isCopy:NO];
    [self.downloadQueue addOperation:operation];
}
- (NSOperationQueue * )downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc]init];
        _downloadQueue.maxConcurrentOperationCount = self.maxCount;
    }
    return _downloadQueue;
}
@end
