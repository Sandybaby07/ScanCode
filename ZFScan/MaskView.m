//
//  ZFMaskView.m
//  ScanBarCode
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "MaskView.h"
#import "Const.h"

@interface MaskView()




@property (nonatomic, strong) UIImageView * scanLineImg;
@end

@implementation MaskView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addUI];
    }
    
    return self;
}

/**
 *  添加UI
 */
- (void)addUI{
    //遮罩层
    UIView * maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    maskView.backgroundColor = [UIColor whiteColor];
    maskView.alpha = 0.5;
    maskView.layer.mask = [self maskLayer];
    [self addSubview:maskView];
    
    //提示框
    UILabel * hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 120, 60)];
    hintLabel.text = @"放入QR COED 進行掃描";
    hintLabel.center = CGPointMake(maskView.center.x, maskView.center.y + (self.frame.size.width - 120) * 0.5 + 40);
    hintLabel.textColor = [UIColor lightGrayColor];
    hintLabel.numberOfLines = 0;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:hintLabel];
    
    //扫描线
    UIImage * scanLine = [UIImage imageNamed:@"scanline"];
    self.scanLineImg = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - (self.frame.size.width - 60)) * 0.5, (self.frame.size.height - (self.frame.size.width - 60)) * 0.5, self.frame.size.width - 60, scanLine.size.height)];
    self.scanLineImg.image = scanLine;
    self.scanLineImg.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.scanLineImg];
    [self.scanLineImg.layer addAnimation:[self animation] forKey:nil];
   }

- (CABasicAnimation *)animation{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 5;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = MAXFLOAT;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, (self.frame.size.height - (self.frame.size.width - 60)) * 0.5)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.scanLineImg.frame.origin.y + self.frame.size.width - 60 - self.scanLineImg.frame.size.height * 0.5)];
    
    return animation;
}

/**
 *  遮罩层bezierPath
 *
 *  @return UIBezierPath
 */
- (UIBezierPath *)maskPath{
    UIBezierPath * bezier = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [bezier appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake((self.frame.size.width - (self.frame.size.width - 60)) * 0.5,
                                                                    self.frame.size.height - (self.frame.size.width - 20),
                                                                    self.frame.size.width - 60,
                                                                    self.frame.size.width - 250)] bezierPathByReversingPath]];

    NSLog(@"ui");
    return bezier;
   
}

/**
 *  遮罩层ShapeLayer
 *
 *  @return CAShapeLayer
 */
- (CAShapeLayer *)maskLayer{
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.path = [self maskPath].CGPath;
    
    return layer;
}

/**
 *  移除动画
 */
- (void)removeAnimation{
    [self.scanLineImg.layer removeAllAnimations];
}

@end
