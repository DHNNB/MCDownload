//
//  MCOperation.m
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "MCOperation.h"
#include <sys/param.h>
#include <sys/mount.h>

@interface MCOperation () <NSURLSessionDelegate>
@property (assign, nonatomic) long long beginLength;
@property (assign, nonatomic) long long totalLength;
@property (assign, nonatomic) long long currentLength;
@property (retain, nonatomic) NSLock *lock;
@end

@implementation MCOperation
@synthesize finished = _finished;
@synthesize executing = _executing;
- (void)dealloc
{
    [self.session invalidateAndCancel];
    [self.downloadTask cancel];
}

- (instancetype)initWithModel:(MCModel * )model delegate:(id)delegate isAgain:(BOOL)isAgain isCopy:(BOOL)isCopy
{
    self = [super init];
    if (self){
        _isCopy = isCopy;
        _isAgain = isAgain;
        _delegate = delegate;
        _model = model;
        _downloadTask = [self downloadFileWithUrl:model.url tempPath:model.tempPath];
    }
    return self;
}
- (void)start
{
    [self.lock lock];
    if (self.isCancel || self.isCancelled){
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        [self.lock unlock];
        return;
    }
    if ([self isReady]){
        [self willChangeValueForKey:@"isFinished"];
        _finished = NO;
        [self didChangeValueForKey:@"isFinished"];
    }else{
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        [self.lock unlock];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    [self didChangeValueForKey:@"isExecuting"];
    [self.lock unlock];
}
-(void)main
{
    if (self.isCancel || self.isCancelled){
        return;
    }
    [self.downloadTask resume];
    dispatch_async(main_queue, ^{
        self.donwloadState = MCDownloading;
        if (_delegate && [_delegate respondsToSelector:@selector(downloadStart:)]){
            [_delegate downloadStart:self];
        }
    });
    while(!self.isFinished){
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}
- (NSURLSessionDataTask * )downloadFileWithUrl:(NSString * )url tempPath:(NSString * )tempPath
{
    dispatch_async(main_queue, ^{
        self.donwloadState = MCDownloadWaiting;
        if (_delegate && [_delegate respondsToSelector:@selector(downloadWaiting:)]){
            [_delegate downloadWaiting:self];
        }
    });
    self.beginLength = 0;
    if([[NSFileManager defaultManager] fileExistsAtPath:tempPath]){
        if (self.isAgain){
            [self removeTempPath];
        }else{
            NSData * data=[NSData dataWithContentsOfFile:tempPath];
            self.beginLength=(long long)data.length;
        }
    }
    
    self.stream = [[NSOutputStream alloc]initToFileAtPath:tempPath append:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *value = [NSString stringWithFormat:@"bytes=%lld-",self.beginLength];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [request setValue:value forHTTPHeaderField:@"Range"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //请求超时
    config.timeoutIntervalForRequest = 10.0f;
    //允许蜂窝网络访问
    config.allowsCellularAccess = YES;
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    return task;
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"文件期望下载%lld,文件类型%@",response.expectedContentLength,response.MIMEType);
    self.totalLength=response.expectedContentLength;
    if (![self checkDiskFreeSize:self.totalLength]){
        completionHandler(NSURLSessionResponseCancel);
        dispatch_async(main_queue, ^{
            self.donwloadState = MCDownloadError;
            if (_delegate && [_delegate respondsToSelector:@selector(downloadFailMsg:withOperation:)]){
                [_delegate downloadFailMsg:MCDiskFreeFail withOperation:self];
            }
        });
        [self finished];
        return;
    }
    completionHandler(NSURLSessionResponseAllow);
    [self.stream open];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.currentLength += data.length;
    // 打印下载进度
    double progress = (double)(self.currentLength+self.beginLength) / (self.totalLength+self.beginLength);
    self.model.progress = progress;
    self.progress = progress;
    //    NSLog(@"下载进度%.2f",progress);
    [self.stream write:data.bytes maxLength:data.length];
    dispatch_async(main_queue, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(donwloadProgress:withOperation:)]){
            [_delegate donwloadProgress:progress withOperation:self];
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self completionHandlerWithError:error];
}
- (void)completionHandlerWithError:(NSError * )error
{
    //主动取消的
    if (error.code == -999){
        [self finished];
        return;
    }
    NSString * str = @"下载失败";
    BOOL isFail = NO;
    if (error.code == -1001){
        str = @"请求超时";
        isFail = YES;
    }else if (error){
        NSLog(@"下载失败");
        isFail = YES;
    }else{
        [self movePathToDesPath];
        dispatch_async(main_queue, ^{
            self.donwloadState = MCDownloadFinished;
            if (_delegate && [_delegate respondsToSelector:@selector(downloadSuccess:withDesPath:)]){
                [_delegate downloadSuccess:self withDesPath:self.model.desPath];
            }
        });
        NSLog(@"下载完成");
    }
    if (isFail){
        dispatch_async(main_queue, ^{
            self.donwloadState = MCDownloadError;
            if (_delegate && [_delegate respondsToSelector:@selector(downloadFailMsg:withOperation:)])
            {
                [_delegate downloadFailMsg:str withOperation:self];
            }
        });
    }
    [self finished];
}
-(void)pauseDownload
{
    [self finished];
    dispatch_async(main_queue, ^{
        self.donwloadState = MCDownloadPasue;
        if (_delegate && [_delegate respondsToSelector:@selector(downloadPause:)]){
            [_delegate downloadPause:self];
        }
    });
}

-(void)cancleDownload
{
    [self finished];
    dispatch_async(main_queue, ^{
        self.donwloadState = MCNotDownload;
        if (_delegate && [_delegate respondsToSelector:@selector(downloadCancel:)]){
            [_delegate downloadCancel:self];
        }
    });
}
- (void)finished
{
    if (self.executing){
        self.isCancel = YES;
        [self.downloadTask cancel];
        [self willChangeValueForKey:@"isFinished"];
        if (self.stream.streamStatus != NSStreamStatusNotOpen){
            [self.stream close];
            self.stream = nil;
        }
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
    }else{
        self.isCancel = YES;
        [self cancel];
    }
}
- (void)removeTempPath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.model.tempPath error:nil];
}

- (void)movePathToDesPath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.model.desPath]){
        [fileManager removeItemAtPath:self.model.desPath error:nil];
    }
    if(self.isCopy){
        [fileManager copyItemAtPath:self.model.tempPath toPath:self.model.desPath error:nil];
        self.movePathSuccess = NO;
    }else if ([fileManager moveItemAtPath:self.model.tempPath toPath:self.model.desPath error:nil]){
        self.movePathSuccess = YES;
    }
}

- (long long)getCurrentLength
{
    return self.beginLength + self.currentLength;
}
- (long long)getTotalLength
{
    return self.beginLength + self.totalLength;
}

- (BOOL)checkDiskFreeSize:(long long)length{
    
    unsigned long long freeDiskSize = [self getDiskFreeSize];
    if (freeDiskSize < length + 1024 * 1024 * 100){
        return NO;
    }
    return YES;
}
- (unsigned long long)getDiskFreeSize
{
    struct statfs buf;
    unsigned long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bavail);
    }
    return freespace;
}
@end
