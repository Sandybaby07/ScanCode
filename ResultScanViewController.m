//
//  ResultScanViewController.m
//  Scan
//
//  Created by SUNGWEICHIH on 2016/9/19.
//  Copyright © 2016年 Tester. All rights reserved.
//

#import <Foundation/Foundation.h>


//
//  ZFScanViewController.m
//  ZFScan
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ScanViewController.h"
#import "ResultScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import <AVFoundation/AVCaptureOutput.h>
#import "Const.h"
#import "MaskView.h"
#import<CoreMedia/CMSampleBuffer.h>
#import <CoreGraphics/CGImage.h>
#import <MediaPlayer/MPVolumeView.h>
@interface ResultScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
    
}
/** 输入输出的中间桥梁 */
@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) AVCaptureSession * session2;
@property(nonatomic, strong)AVCaptureDevice * device;
/** 扫描支持的编码格式的数组 */
@property (nonatomic, strong) NSMutableArray * metadataObjectTypes;
/** UI遮罩层 */
@property (nonatomic, strong) MaskView * maskView;
@property (nonatomic, strong) UILabel * textResults;
@property (nonatomic, strong) UILabel * labelResults;
@property (nonatomic, strong) UIImageView * imageResults;


@end

@implementation ResultScanViewController

- (NSMutableArray *)metadataObjectTypes{
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = [NSMutableArray arrayWithObjects:AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeUPCECode,  nil];
        
        // >= iOS 8
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            [_metadataObjectTypes addObjectsFromArray:@[AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeDataMatrixCode]];
        }
    }
    
    return _metadataObjectTypes;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   
}
- (void)viewDidLoad {

    
    [super viewDidLoad];
    [self capture];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*添加遮罩层*/

- (void)addUI{
    self.maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.maskView];
    
}

/*掃描初始化*/

- (void)capture{
   
    //取得鏡頭
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //建立 AVCaptureDeviceInput
    NSArray *myDevices = [AVCaptureDevice devices];
    //使用後置鏡頭當做輸入
    NSError *error = nil;
    for (_device in myDevices) {
        if ([_device position] == AVCaptureDevicePositionBack) {
            if (error) {
                //裝置取得失敗時的處理常式
            } else {
                //宣告輸入流
                AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
                //宣告輸出流
                AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
                AVCaptureStillImageOutput *textOutput = [[AVCaptureStillImageOutput alloc] init];
                //设置代理 在主线程里刷新
                [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                [textOutput isStillImageStabilizationSupported];
                //初始化链接对象//建立 AVCaptureSession
                self.session = [[AVCaptureSession alloc] init];
                self.session2 =[[AVCaptureSession alloc] init];
                //高质量采集率 //AVCaptureSessionPreset 的關鍵字來查閱各種解析度的定義
                self.session.sessionPreset = AVCaptureSessionPresetHigh;
                self.session2.sessionPreset =AVCaptureSessionPresetHigh;
               //添加輸入，輸出 二維碼session
                [self.session addInput:input];
                [self.session addOutput:output];
                //设置扫描支持的编码格式(如下设置条形码和二维码兼容)
                

                
  
                [self.session startRunning];
               output.metadataObjectTypes = self.metadataObjectTypes;
            //  [self configureCameraForHighestFrameRate:_device];
                [self.session stopRunning];
                //----------------------------------------------------------------------------------//
                //宣告输入流
                AVCaptureDeviceInput * textinput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
                //添加輸入輸出文字session
                [self.session2 addInput:textinput];
                [self.session2 addOutput:textOutput];
                
                //開始捕捉
             
                [self.session2 startRunning];
                
                AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session2];
                layer.frame  =  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                layer.videoGravity = AVLayerVideoGravityResizeAspect;
                //                CGRectMake((self.frame.size.width - (self.frame.size.width - 60)) * 0.5,
                //                           self.frame.size.height - (self.frame.size.width - 20),
                //                           self.frame.size.width - 60,
                //                           self.frame.size.width - 250)
                //layer.backgroundColor = [UIColor yellowColor].CGColor;
                
                //layer.frame = self.view.bounds;
                
                [self.view.layer addSublayer:layer];
                [self addUI];
                // [self.session]

                
               // [self.session2 startRunning];
              
                [self configureCameraForHighestFrameRate:_device];
                __block NSString *image64;
                NSDictionary *myOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
                [textOutput setOutputSettings:myOutputSettings];
                AVCaptureConnection *myVideoConnection = nil;
                
                //從 AVCaptureStillImageOutput 中取得正確類型的 AVCaptureConnection
                for (AVCaptureConnection *connection in textOutput.connections) {
                    for (AVCaptureInputPort *port in [connection inputPorts]) {
                        if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                            myVideoConnection = connection;
                            break;
                        }
                    }
                }
                
                //擷取影像（包含拍照音效）
                [textOutput captureStillImageAsynchronouslyFromConnection:myVideoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
                 {
                    if(imageDataSampleBuffer){
                     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    
                     UIImage *Image = [[UIImage alloc] initWithData:imageData];
                     image64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
                     [self createRequest:image64];
                    
                     self.returnImage(Image);
                   // [self turnTorchOn:NO];
                     }
                    
                 }];
                [self.session2 stopRunning];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)configureCameraForHighestFrameRate:(AVCaptureDevice *)device
{
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    
    CGPoint pointOfInterest = CGPointZero;
    pointOfInterest = CGPointMake((SCREEN_WIDTH - (SCREEN_WIDTH- 60)) * 0.5,SCREEN_HEIGHT - (SCREEN_HEIGHT- 20));

    if ( bestFormat ) {
        if ( [device lockForConfiguration:NULL] == YES ) {
           
            device.activeFormat = bestFormat;
            [_device setTorchMode:AVCaptureTorchModeOn];
            [_device setFlashMode:AVCaptureFlashModeOn];
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.maxFrameDuration;
            if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [_device setFocusPointOfInterest:pointOfInterest];
            }

            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
                NSLog(@"whitebalance");
            }
            
            if([device isExposureModeSupported:AVCaptureExposureModeCustom]){
             //   CMTime exposureTime,minTime, maxTime;
             //   exposureTime = device.activeFormat.maxExposureDuration;                minTime = device.activeFormat.minExposureDuration;//1
             //   maxTime = device.activeFormat.maxExposureDuration;//13
//                if ( CMTimeCompare(exposureTime, minTime) < 0 ) {
//                    exposureTime = minTime;
//                } else if ( CMTimeCompare(exposureTime, maxTime) > 0 ) {
//                    exposureTime = maxTime;
//                }
//               
//                 NSLog(@"%f",device.activeFormat.minISO);//23
//                 NSLog(@"%f",device.activeFormat.maxISO);//736
          //      [device setExposureMode:AVCaptureExposureModeAutoExpose];
               [device setExposureModeCustomWithDuration:CMTimeMake(2, 13) ISO:300
                                        completionHandler:^(CMTime syncTime) {}];
               [device setExposureTargetBias:3 completionHandler:^(CMTime syncTime) {}];
                

               // NSLog(@"exposure time: %lld",);
                NSLog(@"whiteBalanceMode : %ld  ",(long)device.whiteBalanceMode);
                NSLog(@"flight : %ld",(long)device.flashMode);
            }
            
            
            [_device setTorchMode:AVCaptureTorchModeOff];
            [_device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
        }
    }
}



- (void)captureOutput:(AVCaptureMetadataOutput*)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects.firstObject;
        // self.returnScanBarCodeValue(metadataObject.stringValue);
        //攜出資料
        NSString *string = metadataObject.stringValue;
        NSString *pattern = @"[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]";
        NSRegularExpression *regex =[NSRegularExpression regularExpressionWithPattern:pattern options: NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range : NSMakeRange(0, [string length])];
        if (match != nil) {
            NSString *s1 = [string substringWithRange:[match rangeAtIndex:0]];
            self.returnScanBarCodeValue(s1);
            [self.navigationController popViewControllerAnimated:YES];
        }
        [self.session stopRunning];
        
    }
}


- (void) createRequest: (NSString*)imageData {
    // Create our request URL
    
    NSString *urlString = @"https://vision.googleapis.com/v1/images:annotate?key=";
    NSString *API_KEY = @"AIzaSyDB2KlTfnanJWhny5YLl00uU-_DakTpriU";
    
    NSString *requestString = [NSString stringWithFormat:@"%@%@", urlString, API_KEY];
    
    NSURL *url = [NSURL URLWithString: requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request
     addValue:[[NSBundle mainBundle] bundleIdentifier]
     forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
    
    // Build our API request
    NSDictionary *paramsDictionary =
    @{@"requests":@[
              @{@"image":
                    @{@"content":imageData},
                @"features":@[
                        @{@"type":@"TEXT_DETECTION",
                          @"maxResults":@50},
                        @{@"type":@"LABEL_DETECTION",
                          @"maxResults":@10},
                        ]}]};
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&error];
    [request setHTTPBody: requestData];
    
    // Run the request on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runRequestOnBackgroundThread: request];
    });
}

- (void)runRequestOnBackgroundThread: (NSMutableURLRequest*) request {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
        [self analyzeResults:data];
    }];
    [task resume];
}

- (void)analyzeResults: (NSData*)dataToParse {
    // Update UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataToParse options:kNilOptions error:&e];
        
        NSArray *responses = [json objectForKey:@"responses"];
        NSLog(@"%@", responses);
        NSDictionary *responseData = [responses objectAtIndex: 0];
        NSDictionary *errorObj = [json objectForKey:@"error"];
        
        //[self.spinner stopAnimating];
        self.labelResults.hidden = true;
        self.textResults.hidden = true;
        
        
        
        // Check for errors
        if (errorObj) {
            NSString *errorString1 = @"Error code ";
            NSString *errorCode = [errorObj[@"code"] stringValue];
            NSString *errorString2 = @": ";
            NSString *errorMsg = errorObj[@"message"];
            self.labelResults.text = [NSString stringWithFormat:@"%@%@%@%@", errorString1, errorCode, errorString2, errorMsg];
        } else {
            
            // Get text annotations
            NSDictionary *textAnnotations = [responseData objectForKey:@"textAnnotations"];
            NSInteger numTexts = [textAnnotations count];
            NSMutableArray *texts = [[NSMutableArray alloc] init];
            if (numTexts > 0) {
                NSString *textResultsText = @"Text found: ";
                for (NSDictionary *text in textAnnotations) {
                    NSString *textString = [text objectForKey:@"description"];
                    [texts addObject:textString];
                }
                for (NSString *text in texts) {
                    // if it's not the last item add a comma
                    if (texts[texts.count - 1] != text) {
                        NSString *commaString = [text stringByAppendingString:@" "];
                        textResultsText = [textResultsText stringByAppendingString:commaString];
                    } else {
                        textResultsText = [textResultsText stringByAppendingString:text];
                    }
                }
                self.returnText(textResultsText);
                
            } else {
                self.textResults.text = @"No texts found";
            }
            
            // Get label annotations
            NSDictionary *labelAnnotations = [responseData objectForKey:@"labelAnnotations"];
            NSInteger numLabels = [labelAnnotations count];
            NSMutableArray *labels = [[NSMutableArray alloc] init];
            if (numLabels > 0) {
                NSString *labelResultsText = @"label found: ";
                for (NSDictionary *label in labelAnnotations) {
                    NSString *labelString = [label objectForKey:@"description"];
                    [labels addObject:labelString];
                    
                }
                for (NSString *label in labels) {
                    // if it's not the last item add a comma
                    if (labels[labels.count - 1] != label) {
                        NSString *commaString = [label stringByAppendingString:@" "];
                        labelResultsText = [labelResultsText stringByAppendingString:commaString];
                    } else {
                        labelResultsText = [labelResultsText stringByAppendingString:label];
                    }
                }
                
                self.returnText(labelResultsText);
                
            } else {
                self.labelResults.text = @"No labels found";
            }
            
        }
        
    });
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
