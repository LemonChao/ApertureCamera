//
//  LCCaptureManager.h
//  HtmlLoad
//
//  Created by zchao on 2018/6/29.
//  Copyright © 2018年 zchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const THThumbnailCreatedNotification;

@protocol LCCaptureManagerDelegate <NSObject>                             // 1
- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;
@end


@interface LCCaptureManager : NSObject

@property (weak, nonatomic) id<LCCaptureManagerDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

// Session Configuration                                                    // 2
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// Camera Device Support                                                    // 3
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;

@property (nonatomic, readonly) NSUInteger cameraCount;
@property (nonatomic, readonly) BOOL cameraHasTorch;
@property (nonatomic, readonly) BOOL cameraHasFlash;
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;
@property (nonatomic) AVCaptureTorchMode torchMode;
@property (nonatomic) AVCaptureFlashMode flashMode;

// Tap to * Methods                                                         // 4
- (void)resetFocusAndExposureModes;


// Still Image Capture
- (void)captureStillImageCompletionHandler:(void(^)(CMSampleBufferRef sampleBuffer, NSError *error))handler;


@end
