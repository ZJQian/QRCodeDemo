//
//  MakeQRCodeViewController.m
//  QRCodeDemo
//
//  Created by ZJQ on 2017/2/10.
//  Copyright © 2017年 ZJQ. All rights reserved.
//

#define TEXT @"0123456789abcdefg"

#import "MakeQRCodeViewController.h"

@interface MakeQRCodeViewController ()

@end

@implementation MakeQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *ewmImage=[[UIImageView alloc]init];
    ewmImage.center = self.view.center;
    ewmImage.bounds = CGRectMake(0, 0, 280, 280);
    ewmImage.image =[self generateQRCode:TEXT width:ewmImage.bounds.size.width height:ewmImage.bounds.size.height];
    [self.view addSubview:ewmImage];
}

- (UIImage *)generateQRCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    
    // 生成二维码图片
    CIImage *qrcodeImage;
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    qrcodeImage = [filter outputImage];
    
    // 消除模糊
    CGFloat scaleX = width / qrcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / qrcodeImage.extent.size.height;
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
