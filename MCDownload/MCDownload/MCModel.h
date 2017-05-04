//
//  MCModel.h
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCModel : NSObject

/**
 区分下载
 */
@property (assign, nonatomic) NSInteger modelId;
/**
 下载地址
 */
@property (copy, nonatomic) NSString * url;

/**
 最终路径
 */
@property (copy, nonatomic) NSString * desPath;

/**
 临时路径
 */
@property (copy, nonatomic) NSString * tempPath;

@end
