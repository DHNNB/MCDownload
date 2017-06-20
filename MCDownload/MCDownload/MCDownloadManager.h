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

@interface MCDownloadManager : NSObject

UIKIT_EXTERN NSString *const MCOperationProgressChange;
UIKIT_EXTERN NSString *const MCOperationStateChange;

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

/**
 查询在下载的model

 @param model  -
 @return -
 */
- (MCOperation * )getOperationWithModel:(MCModel *)model;
@end
