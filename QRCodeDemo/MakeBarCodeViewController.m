//
//  MakeBarCodeViewController.m
//  QRCodeDemo
//
//  Created by ZJQ on 2017/2/10.
//  Copyright © 2017年 ZJQ. All rights reserved.
//

#define TEXT @"0123456789abcdefg"

#import "MakeBarCodeViewController.h"

@interface MakeBarCodeViewController ()

@end

@implementation MakeBarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *txmImage=[[UIImageView alloc]init];
    txmImage.center = self.view.center;
    txmImage.bounds = CGRectMake(0, 0, 300, 100);
    txmImage.image=[self generateBarCode:TEXT width:txmImage.frame.size.width height:txmImage.frame.size.height];
    [self.view addSubview:txmImage];
    UILabel *code = [[UILabel alloc]initWithFrame:CGRectMake(0, 85, txmImage.bounds.size.width, 15)];
    code.font = [UIFont systemFontOfSize:12];
    code.textAlignment = NSTextAlignmentCenter;
    code.text = TEXT;
    [txmImage addSubview:code];
    
}
- (UIImage *)generateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    
    // 生成条形码图片
    CIImage *barcodeImage;
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    barcodeImage = [filter outputImage];
    
    // 消除模糊
    CGFloat scaleX = width / barcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / barcodeImage.extent.size.height;
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
