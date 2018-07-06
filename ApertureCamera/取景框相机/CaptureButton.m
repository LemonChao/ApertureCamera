//
//  CaptureButton.m
//  HtmlLoad
//
//  Created by zchao on 2018/6/29.
//  Copyright © 2018年 zchao. All rights reserved.
//

#import "CaptureButton.h"

#define LINE_WIDTH 6.0f
#define DEFAULT_FRAME CGRectMake(0.0f, 0.0f, 66.0f, 66.0f)


@interface CaptureButton ()
@property (strong, nonatomic) CALayer *circleLayer;
@end

@implementation CaptureButton

+ (instancetype)captureButton {
    return [[self alloc] initWithCaptureButtonMode:CaptureButtonModePhoto];
}

+ (instancetype)captureButtonWithMode:(CaptureButtonMode)mode {
    return [[self alloc] initWithCaptureButtonMode:mode];
}

- (instancetype)initWithCaptureButtonMode:(CaptureButtonMode)mode {
    self = [super initWithFrame:DEFAULT_FRAME];
    if (self) {
        _captureButtonMode = mode;
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _captureButtonMode = CaptureButtonModePhoto;
    [self setupView];
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    UIColor *circleColor = (self.captureButtonMode == CaptureButtonModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
    _circleLayer = [CALayer layer];
    _circleLayer.backgroundColor = circleColor.CGColor;
    _circleLayer.bounds = CGRectInset(self.bounds, 8.0, 8.0);
    _circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _circleLayer.cornerRadius = _circleLayer.bounds.size.width / 2.0f;
    [self.layer addSublayer:_circleLayer];
}

- (void)setCaptureButtonMode:(CaptureButtonMode)mode {
    if (_captureButtonMode != mode) {
        _captureButtonMode = mode;
        
        if (mode == CaptureButtonModeVideo) {
            self.circleLayer.backgroundColor = [UIColor redColor].CGColor;
        }else if (mode == CaptureButtonModePhoto) {
            self.circleLayer.backgroundColor = [UIColor whiteColor].CGColor;
        }
        [self.circleLayer setValue:@1 forKeyPath:@"transform.scale"];
        self.circleLayer.cornerRadius = self.circleLayer.bounds.size.width/2.f;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (self.selected) { //video mode 有选中状态，切选中状态下点击无动画
        return;
    }
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.2f;
    scaleAnimation.toValue = @0.85f;
    if (highlighted) {
        scaleAnimation.toValue = @0.85f;
    }else {
        scaleAnimation.toValue = @1.0f;
    }
    
    [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
    [self.circleLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        
        [CATransaction disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        scaleAnimation.toValue = @0.6f;
        radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 4.0f);
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, radiusAnimation];
        animationGroup.beginTime = CACurrentMediaTime() + 0.1f;
        animationGroup.duration = 0.1f;
        
        [self.circleLayer setValue:radiusAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
        
        [self.circleLayer addAnimation:animationGroup forKey:@"scaleAndRadiusAnimation"];
        
    }else {
        
        [CATransaction disableActions];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        
        radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 2.0f);
        
        radiusAnimation.beginTime = CACurrentMediaTime() + 0.1f;
        radiusAnimation.duration = 0.1f;
        
        [self.circleLayer setValue:radiusAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer addAnimation:radiusAnimation forKey:@"cornerRadiusAnimation"];
    }
    
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGRect insetRect = CGRectInset(rect, LINE_WIDTH / 2.0f, LINE_WIDTH / 2.0f);
    CGContextStrokeEllipseInRect(context, insetRect);
}

@end

