//
//  TableViewCell.m
//  MCDownload
//
//  Created by M_Code on 2017/6/20.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "TableViewCell.h"
#import "MCDownloadManager.h"
#import "MCOperation.h"
@implementation TableViewCell
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(operationStateChange:) name:MCOperationStateChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(operationProgressChange:) name:MCOperationProgressChange object:nil];

}
- (void)operationProgressChange:(NSNotification * )notification
{
    MCOperation * op = notification.object;
    if(op.model.modelId == self.model.modelId){
        self.progressView.progress = op.progress;
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",op.progress * 100];
    }
}
- (void)operationStateChange:(NSNotification * )notification
{
    MCOperation * op = notification.object;
    if(op.model.modelId == self.model.modelId){
        self.donwloadBtn.selected = (op.donwloadState == MCDownloading || op.donwloadState == MCDownloadWaiting);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
