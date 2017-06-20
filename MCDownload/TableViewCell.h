//
//  TableViewCell.h
//  MCDownload
//
//  Created by M_Code on 2017/6/20.
//  Copyright © 2017年 MC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCModel.h"
@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *donwloadBtn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) MCModel * model;
@end
