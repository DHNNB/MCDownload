//
//  ViewController.m
//  MCDownload
//
//  Created by M_Code on 2017/5/4.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "ViewController.h"
#import "MCDownloadManager.h"
@interface ViewController ()<MCMonitoringDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)startDownload:(id)sender {
    MCModel * model = [[MCModel alloc]init];
    model.url = @"http://m2.pc6.com/xxj/jihuang.dmg";
    model.desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"10.zip"];
    model.tempPath =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"9.zip"];
    [MCDownloadManager downloadManager].delegate = self;
    [[MCDownloadManager downloadManager]addDonwloadWithModel:model];
}
- (void)donwloadProgress:(CGFloat)progress withOperation:(MCOperation * )operation
{
  //  operation.model.modelId 来区分下载
    
    self.slider.value = progress;
    self.pressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress * 100.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
