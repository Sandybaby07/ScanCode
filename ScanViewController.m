//
//  ViewController.m
//  ZFScanCode
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ScanViewController.h"
#import "Const.h"
#import "ResultScanViewController.h"

@interface ScanViewController()


@property (nonatomic, strong) UIButton * scanButton;//UI扫描按钮
@property (nonatomic, strong) UILabel * resultLabel;//UI顯示條碼掃瞄结果
@property (nonatomic, strong) UILabel * textResults;//文字掃描
@property (nonatomic, strong) UILabel * labelResults;//UI
@property (nonatomic, strong) UIImageView * imageResults;//UI

@property(nonatomic, readonly, strong) NSString *uuid;//uuid

@end

@implementation ScanViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI掃描按钮
    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.scanButton.frame = CGRectMake((SCREEN_WIDTH - 100), SCREEN_HEIGHT - 80, 100, 30);
    [self.scanButton setTitle:@"SCAN" forState:UIControlStateNormal];
    [self.scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton];
  
    //UI顯示條碼结果
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 100)];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.numberOfLines = 0;
    
    //UI顯示文字结果
    self.textResults = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, SCREEN_WIDTH, 100)];
    self.textResults.textAlignment = NSTextAlignmentCenter;
    self.textResults.numberOfLines = 0;

    //UI顯示片结果
    
    self.imageResults = [[UIImageView alloc]initWithFrame:CGRectMake(30, 250,216,384)];
    
    //相片9:16
    [self.view addSubview:self.resultLabel];
    [self.view addSubview:self.textResults];
    [self.view addSubview:self.imageResults];

    
    

}


/**
 * UI 掃描事件
 */
- (void)scanAction:(UIButton *)sender{
    
    
    ResultScanViewController * vc = [[ResultScanViewController alloc] init];
        
    vc.returnScanBarCodeValue= ^(NSString * barCodeString){
    self.resultLabel.text = [NSString stringWithFormat:@"掃描結果:\n%@",barCodeString];
        NSLog(@"條碼>>>>>%@",barCodeString);
    };
    vc.returnText= ^(NSString * Textdetect){
        self.textResults.text=[NSString stringWithFormat: @"文字偵測:\n%@",Textdetect];
        NSLog(@"文字>>>>%@",Textdetect);
    };
    vc.returnImage=^(UIImage*Imagedetect){
        self.imageResults.image=Imagedetect;
        NSLog(@"Photo");
                   };
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
