//
//  MCDownloadManager.m
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "MCDownloadManager.h"
#import "MCOperation.h"
@interface MCDownloadManager() <MCDownloadDelegate>
@property (retain, nonatomic) NSOperationQueue * downloadQueue;
@end
@implementation MCDownloadManager

//下载管理 进度改变
NSString * const MCOperationProgressChange = @"OperationProgressChange";
//状态改变
NSString * const MCOperationStateChange = @"OperationStateChange";


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
- (void)addDonwloadWithModel:(MCModel *)model
{
    for (MCOperation  * op in self.downloadQueue.operations) { //在下载 暂停
        if (op.model.modelId == model.modelId) {
            [op pauseDownload];
            return;
        }
    }
    // again 为yes 不断点续传
    MCOperation * operation = [[MCOperation  alloc]initWithModel:model delegate:self isAgain:NO isCopy:NO];
    [self.downloadQueue addOperation:operation];
}
#define mark - MCDownloadDelegate
- (void)donwloadProgress:(CGFloat)progress withOperation:(MCOperation * )operation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationProgressChange object:operation];
}
- (void)downloadSuccess:(MCOperation * )operation withDesPath:(NSString * )desPath
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationStateChange object:operation];
}
- (void)downloadFailMsg:(NSString *)msg withOperation:(MCOperation * )operation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationStateChange object:operation];
}
- (void)downloadPause:(MCOperation * )operation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationStateChange object:operation];
}
- (void)downloadStart:(MCOperation * )operation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationStateChange object:operation];
}
- (void)downloadCancel:(MCOperation * )operation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationStateChange object:operation];
}
- (void)downloadWaiting:(MCOperation * )operation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MCOperationStateChange object:operation];
}

- (void)setMaxCount:(NSInteger)maxCount
{
    _maxCount = maxCount;
    self.downloadQueue.maxConcurrentOperationCount = maxCount;
}
- (NSOperationQueue * )downloadQueue
{
    if (!_downloadQueue){
        _downloadQueue = [[NSOperationQueue alloc]init];
        _downloadQueue.maxConcurrentOperationCount = self.maxCount;
    }
    return _downloadQueue;
}
@end
