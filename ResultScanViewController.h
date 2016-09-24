//
//  ResultScanViewController.h
//  ZFScan
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//
//


#import <UIKit/UIKit.h>

@interface ResultScanViewController : UIViewController

/** 扫描结果 */
@property (nonatomic, copy) void (^returnScanBarCodeValue)(NSString * barCodeString);
@property (nonatomic, copy) void (^returnText)(NSString * Textdetect);
@property (nonatomic, copy) void (^returnImage)(UIImage * Imagedetect);
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end