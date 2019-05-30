//
//  ViewController.m
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "ViewController.h"
#import "MCDownloadManager.h"
#import "TableViewCell.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;
@property (weak, nonatomic) IBOutlet UITableView *mcTableView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) NSMutableArray * dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mcTableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"downloadCell"];
    [self creatData];
}
- (void)creatData{
    for (int i = 1 ; i <= 20; i++) {
        MCModel * model = [[MCModel alloc]init];
        model.url = @"http://vd.yinyuetai.com/hd.yinyuetai.com/uploads/videos/common/E18B01693C177FDDBE82B857755FA7DE.mp4";
        model.desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.zip",i]];
        model.modelId = i;
        model.tempPath =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_des.zip",i]];
        [self.dataArray addObject:model];
    }
    [self.mcTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"downloadCell"];
    cell.nameLabel.text = [NSString stringWithFormat:@"下载%ld",indexPath.row];
    MCModel * model = self.dataArray[indexPath.row];
    cell.model = model;
    MCOperation * op = [[MCDownloadManager downloadManager] getOperationWithModel:model];
    if (op) {
        if (op.donwloadState == MCDownloadWaiting || op.donwloadState == MCDownloading) {
            cell.donwloadBtn.selected = YES;
        }else{
            cell.donwloadBtn.selected = NO;
        }
        cell.progressView.progress = op.progress;
        cell.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",op.progress * 100];
    }else{
        cell.donwloadBtn.selected = NO;
        cell.progressView.progress = model.progress;
        cell.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",model.progress * 100];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[MCDownloadManager downloadManager]addDonwloadWithModel:self.dataArray[indexPath.row]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray * )dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}


@end
