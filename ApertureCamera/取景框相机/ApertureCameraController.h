//
//  ApertureCameraController.h
//  HtmlLoad
//
//  Created by zchao on 2018/6/29.
//  Copyright © 2018年 zchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApertureCameraController;
@protocol ApertureCameraControllerDelegate <NSObject>

@optional
//拍照完成
- (void)apertureCameraController:(ApertureCameraController *)controller didFinishTakePicture:(UIImage *)image;

@end


@interface ApertureCameraController : UIViewController

@property(nonatomic, weak) id<ApertureCameraControllerDelegate> delegate;


@end
