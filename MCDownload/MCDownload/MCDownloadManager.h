//
//  MCDownloadManager.h
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCModel.h"
#import "MCOperation.h"
#import <UIKit/UIKit.h>
@protocol MCMonitoringDelegate <NSObject>
/**
 下载进度
 
 @param progress 进度
 @param operation -
 */
- (void)donwloadProgress:(CGFloat)progress withOperation:(MCOperation * )operation;
@optional

@end
@interface MCDownloadManager : NSObject

/**
 监控下载状态
 */
@property (weak, nonatomic) id<MCMonitoringDelegate> delegate;
/**
 同事下载个数 默认 1个
 */
@property (assign, nonatomic) NSInteger maxCount;

/**
 创建

 @return -
 */
+ (MCDownloadManager * )downloadManager;

/**
 添加下载

 @param model 自己的model
 */
- (void)addDonwloadWithModel:(MCModel *)model;
@end
