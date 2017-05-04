//
//  MCOperation.h
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MCModel.h"
static NSString * MCDiskFreeFail = @"手机存储空间不足,请及时清理";
#define global_quque    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define main_queue      dispatch_get_main_queue()

typedef NS_ENUM(NSInteger,MCDownloadState) {
    MCNotDownload = 0,
    MCDownloadWaiting,
    MCDownloading,
    MCDownloadPasue,
    MCDownloadFinished, //4
    MCDownloadError,
    MCDownloadExtracted, //解压完成
    MCDownloadExtractedError, //解压失败
};

@class MCOperation;
@protocol MCDownloadDelegate <NSObject>

@optional


/**
 下载成功
 
 @param operation -
 @param desPath 最终文件
 */
- (void)downloadSuccess:(MCOperation * )operation withDesPath:(NSString * )desPath;

/**
 下载失败
 
 @param msg 失败信息
 @param operation -
 */
- (void)downloadFailMsg:(NSString *)msg withOperation:(MCOperation * )operation;

/**
 下载进度
 
 @param progress 进度
 @param operation -
 */
- (void)donwloadProgress:(CGFloat)progress withOperation:(MCOperation * )operation;

/**
 下载暂停
 
 @param operation -
 */
- (void)downloadPause:(MCOperation * )operation;

/**
 下载开始
 
 @param operation -
 */
- (void)downloadStart:(MCOperation * )operation;

/**
 下载取消
 
 @param operation -
 */
- (void)downloadCancel:(MCOperation * )operation;

/**
 下载等待
 
 @param operation -
 */
- (void)downloadWaiting:(MCOperation * )operation;
@end

@interface MCOperation : NSOperation

/**
 model
 */
@property (retain, nonatomic) MCModel * model;
/**
 下载代理
 */
@property (weak, nonatomic) id<MCDownloadDelegate> delegate;

/**
 下载完成之后 缓存文件是否成功移到最终目录
 */
@property (assign,nonatomic) BOOL movePathSuccess;

/**
 进度
 */
@property (assign, nonatomic) CGFloat progress;

/**
 下载状态
 */
@property (assign, nonatomic) MCDownloadState donwloadState;

/**
 是否重新下载 不继续上次
 */
@property (assign, nonatomic) BOOL isAgain;

/**
 下载完成是复制 到最终目录
 */
@property (assign, nonatomic) BOOL isCopy;

/**
 请求
 */
@property (retain, nonatomic) NSURLSession * session;
@property (retain, nonatomic) NSURLSessionDataTask * downloadTask;

/**
 控制 下载状态
 */
@property (assign, nonatomic) BOOL isCancel;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

/**
 文件写入
 */
@property (retain, nonatomic) NSOutputStream * stream;

/**
 创新下载线程
 
 @param model -
 @param delegate 代理
 @param isAgain 是否重新下载 不继续上次
 @param isCopy  下载完成是否copy （默认 移动到 最终目录）
 @return -
 */
- (instancetype)initWithModel:(MCModel * )model
                   delegate:(id)delegate
                    isAgain:(BOOL)isAgain
                     isCopy:(BOOL)isCopy;

/**
 暂停下载
 */
-(void)pauseDownload;

/**
 取消下载
 */
-(void)cancleDownload;

/**
 当前长度
 
 @return -
 */
- (long long)getCurrentLength;

/**
 最大长度
 
 @return -
 */
- (long long)getTotalLength;

/**
 调用此方法 直接完成此次下载 （线程 移除队列）
 */
- (void)finished;
@end

