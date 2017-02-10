//
//  ScanQRViewController.m
//  QRCodeDemo
//
//  Created by ZJQ on 2017/2/10.
//  Copyright © 2017年 ZJQ. All rights reserved.
//

#import "ScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanView.h"

@interface ScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) CIDetector *detector;
@property (nonatomic, strong)ScanView *scanView;

@end

@implementation ScanQRViewController

- (AVCaptureSession *)session {

    if (!_session) {
        
        //获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input) {
            return nil;
        }
        //创建输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理，并在主线程中刷新UI
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        CGFloat width = 300/CGRectGetWidth(self.view.bounds);
        CGFloat height = 300/CGRectGetHeight(self.view.bounds);
        //设置扫描区域
        output.rectOfInterest = CGRectMake((1-height)/2, (1-width)/2, height, width);
        
        
        _session = [[AVCaptureSession alloc]init];
        
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        [_session addInput:input];
        [_session addOutput:output];
        
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode128Code];
        
    }
    return _session;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self.session startRunning];
}
- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnItemClicked)];
    self.navigationItem.rightBarButtonItem = right;
    
    
    [self checkAVAuthorizationStatus];
    
    ScanView *scanView = [[ScanView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    [self.view addSubview:scanView];
    self.scanView = scanView;
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
}


- (void)rightBarBtnItemClicked {
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]
                                               options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:1]}];
    
    if (features.count >=1) {
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        NSLog(@"相册二维码---%@",scannedResult);
       
    }else{
        
        [self.scanView pause];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"未扫描出结果" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alert show];
        
    }
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex==0) {
        [self.session startRunning];
        [self.scanView run];
    }
}


- (void)checkAVAuthorizationStatus {

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请打开相机权限" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }

}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    if (metadataObjects.count>0) {
        [self.session stopRunning];
        NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) metadataObjects.firstObject stringValue];
        NSLog(@"-----%@",scannedResult);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
