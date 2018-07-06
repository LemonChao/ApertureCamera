//
//  ApertureCameraController.m
//  HtmlLoad
//
//  Created by zchao on 2018/6/29.
//  Copyright © 2018年 zchao. All rights reserved.
//

#import "ApertureCameraController.h"
#import "LCCaptureManager.h"
#import "CaptureButton.h"
#import "LCFlashControl.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ApertureCameraController ()

@property(nonatomic, strong) CaptureButton *captureButton;


@property(nonatomic, strong) LCCaptureManager *captureManager;

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end


@implementation ApertureCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captureManager = [[LCCaptureManager alloc] init];

    NSError *error;
    if ([self.captureManager setupSession:&error]) {
        self.previewLayer.session = self.captureManager.captureSession;
        [self.captureManager startSession];
    }
    [self.view.layer addSublayer:self.previewLayer];

    [self setupViews];
}

- (void)setupViews {
    
    
    CGFloat containerH = (SCREEN_HEIGHT - SCREEN_WIDTH*0.61)/2;
    UIView *topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, containerH)];
    topContainerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topContainerView];

    LCFlashControl *flashControl = [[LCFlashControl alloc] initWithFrame:CGRectMake(10, 25, 48, 48)];
    [flashControl addTarget:self action:@selector(flashControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [topContainerView addSubview:flashControl];
    
    
    UIView *bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.previewLayer.frame), SCREEN_WIDTH, containerH)];
    bottomContainerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomContainerView];

    self.captureButton.center = CGPointMake(CGRectGetWidth(bottomContainerView.bounds)/2, CGRectGetHeight(bottomContainerView.bounds)/1.5);
    [bottomContainerView addSubview:self.captureButton];

    UIButton *cancelButton = [self createCancelButton];
    cancelButton.frame = CGRectMake(0, CGRectGetHeight(bottomContainerView.bounds)/1.5 - 20, 80, 40);
    [bottomContainerView addSubview:cancelButton];

    UIButton *switchButton = [self createSwitchCameraButton];
    switchButton.frame = CGRectMake(CGRectGetWidth(bottomContainerView.frame)-80, CGRectGetMinY(cancelButton.frame), 80, 40);
    [bottomContainerView addSubview:switchButton];
    
}

- (void)captureButtonAction:(UIButton *)button {
    
    [self.captureManager captureStillImageCompletionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
        
        CFDictionaryRef exifAttachments = CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) { //拍照信息
            NSLog(@"attachements: %@", exifAttachments);
        } else {
            NSLog(@"no attachments");
        }
        
        if (sampleBuffer != NULL) {//转成图片

            NSData *imageData =
            [AVCaptureStillImageOutput
             jpegStillImageNSDataRepresentation:sampleBuffer];
            
            UIImage *photoImage = [[UIImage alloc] initWithData:imageData];
            
            CGSize originImgSize = photoImage.size;
            
            CGRect rect =  CGRectMake(0, (originImgSize.height-originImgSize.width*0.61)/2, originImgSize.width, originImgSize.width*0.61); //要裁剪的图片区域，按照取景框的比例截取
            
            UIImage *sendImage = [self cropImage:photoImage toRect:rect];
            
            if ([self.delegate respondsToSelector:@selector(apertureCameraController:didFinishTakePicture:)]) {
                [self.delegate apertureCameraController:self didFinishTakePicture:sendImage];
            }

        } else {
            NSLog(@"NULL sampleBuffer: %@", [error localizedDescription]);
        }

    }];
    
}

- (void)popbackAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchCamera:(UIButton *)button {
    if ([self.captureManager switchCameras]) {
        [self.captureManager resetFocusAndExposureModes];
    }
}

- (void)flashControlValueChanged:(LCFlashControl *)flashControl {
    NSInteger mode = [flashControl selectedMode];
    self.captureManager.flashMode = mode;
}

- (UIButton *)createCancelButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightRegular];
    [button addTarget:self action:@selector(popbackAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)createSwitchCameraButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateSelected];
    button.tintColor = [UIColor whiteColor];

    [button addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];

    return button;
}


//裁剪图片
- (UIImage *)cropImage:(UIImage*)image toRect:(CGRect)rect {
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    // use the rect to crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    // create a new UIImage and set the scale and orientation appropriately
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    // memory cleanup
    CGImageRelease(imageRef);
    
    return result;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = CGRectMake(0, (SCREEN_HEIGHT - SCREEN_WIDTH*0.61)/2, SCREEN_WIDTH, SCREEN_WIDTH*0.61);
    }
    return _previewLayer;
}

- (CaptureButton *)captureButton {
    if (!_captureButton) {
        _captureButton = [CaptureButton captureButton];
        [_captureButton addTarget:self action:@selector(captureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureButton;
}

@end
