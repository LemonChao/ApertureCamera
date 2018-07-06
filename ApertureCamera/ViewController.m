//
//  ViewController.m
//  ApertureCamera
//
//  Created by zchao on 2018/7/6.
//  Copyright © 2018年 zchao. All rights reserved.
//

#import "ViewController.h"
#import "ApertureCameraController.h"

@interface ViewController ()<ApertureCameraControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)takePhotoButtonAction:(UIButton *)sender {
    
    ApertureCameraController *cameraVC = [[ApertureCameraController alloc] init];
    cameraVC.delegate = self;
    
    [self presentViewController:cameraVC animated:YES completion:nil];
    
}


- (void)apertureCameraController:(ApertureCameraController *)controller didFinishTakePicture:(UIImage *)image {
    [self.photoButton setBackgroundImage:image forState:UIControlStateNormal];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
