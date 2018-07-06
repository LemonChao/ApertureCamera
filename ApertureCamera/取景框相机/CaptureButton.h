//
//  CaptureButton.h
//  HtmlLoad
//
//  Created by zchao on 2018/6/29.
//  Copyright © 2018年 zchao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CaptureButtonMode) {
    CaptureButtonModePhoto = 0, // default
    CaptureButtonModeVideo = 1
};


@interface CaptureButton : UIButton

@property (nonatomic) CaptureButtonMode captureButtonMode;

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(CaptureButtonMode)captureButtonMode;

@end
