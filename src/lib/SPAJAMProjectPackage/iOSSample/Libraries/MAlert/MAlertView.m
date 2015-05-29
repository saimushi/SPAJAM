//
//  MAlertView.m
//
//  Created by n00874 on 2014/11/07.
//  Copyright (c) 2014年 cybird. All rights reserved.
//

#import "MAlertView.h"

@implementation MAlertView
{
    UIView *dialogView;
    
    UIView *_modalView;
    NSString *_leftButtonTitle;
    NSString *_rightButtonTitle;
    void(^_compBlock)(NSInteger buttonIndex);
}

+ (MAlertView *)showAlertView:(NSString *)title
              leftButtonTitle:(NSString *)leftButtonTitle
             rightButtonTitle:(NSString *)rightButtonTitle
                   completion:(void (^)(NSInteger buttonIndex))completion
{
    // タイトルをセット
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    CGFloat dialogWidth  = window.frame.size.width - 60;
    CGFloat dialogHeight = 120.0;
    CGFloat buttonHeight = 50;
    CGFloat titleLabelMargin = 10;
    CGFloat titleLabelHeight = dialogHeight - buttonHeight;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(titleLabelMargin, titleLabelMargin,
                                  dialogWidth - titleLabelMargin*2, titleLabelHeight - titleLabelMargin*2);
    titleLabel.backgroundColor = UIColor.clearColor;
    titleLabel.text            = title;
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    titleLabel.font            = [UIFont systemFontOfSize:14];
    titleLabel.textColor       = UIColor.blackColor;
    titleLabel.numberOfLines   = 0;
    titleLabel.lineBreakMode   = NSLineBreakByWordWrapping;

    return [MAlertView showAlertModalView:titleLabel leftButtonTitle:leftButtonTitle rightButtonTitle:rightButtonTitle completion:completion];
}

+ (MAlertView *)showAlertModalView:(UIView *)modalView
                        leftButtonTitle:(NSString *)leftButtonTitle
                       rightButtonTitle:(NSString *)rightButtonTitle
                             completion:(void (^)(NSInteger buttonIndex))completion
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MAlertView *mAlertView =[[self alloc] initAlertModalView:(UIView *)modalView
                                                       leftButtonTitle:leftButtonTitle
                                                      rightButtonTitle:rightButtonTitle
                                                            completion:(void (^)(NSInteger))completion];
    mAlertView.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [window addSubview:mAlertView];
    
    [mAlertView show];
    
    return mAlertView;
}

/**
 * アラートビューを生成
 */
- (id)initAlertModalView:(UIView *)modalView
         leftButtonTitle:(NSString *)leftButtonTitle
        rightButtonTitle:(NSString *)rightButtonTitle
              completion:(void (^)(NSInteger))completion
{
    self = [self init];
    if (self) {
        _modalView = modalView;
        if (leftButtonTitle != nil) {
            _leftButtonTitle = [NSString stringWithString:leftButtonTitle];
        };
        if (rightButtonTitle != nil) {
            _rightButtonTitle = [NSString stringWithString:rightButtonTitle];
        };
        _compBlock = [completion copy];
        
        [self setView];
    }
    return self;
}

- (void)setView
{
    CGRect bounds = self.superview.bounds;
    self.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    if ([self.superview isKindOfClass:UIWindow.class]
        && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
        self.bounds = (CGRect){CGPointZero, {bounds.size.height, bounds.size.width}};
        
    } else {
        self.bounds = (CGRect){CGPointZero, bounds.size};
    }
    
    CGFloat cornerRadius = 7.0;
    self.hidden = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // ダイアログをセット
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    dialogView = [[UIView alloc] init];
    dialogView.backgroundColor     = [UIColor colorWithRed:0.992 green:0.992 blue:0.980 alpha:0]; // #fdfdfa
    dialogView.layer.cornerRadius  = cornerRadius;
    dialogView.layer.shadowRadius  = cornerRadius + 5;
    dialogView.layer.shadowOpacity = 0.1f;
    dialogView.layer.shadowOffset  = CGSizeMake(-(cornerRadius+5)/2.0f, -(cornerRadius+5)/2.0f);
    [self addSubview:dialogView];
    [self applyMotionEffects];
    
    // モーダルをセット
    [dialogView addSubview:_modalView];
    
    // ダイアログの高さを調整
    CGFloat buttonHeight = 50;
    CGFloat dialogHeight = _modalView.frame.size.height + buttonHeight;
    dialogView.frame = CGRectMake((window.frame.size.width - _modalView.frame.size.width)/2,
                                  (window.frame.size.height - dialogHeight)/2,
                                  _modalView.frame.size.width,
                                  dialogHeight);
    
    // ボタンをセット
    CGFloat buttonWidth  = dialogView.frame.size.width;
    if (_rightButtonTitle != nil) {
        buttonWidth = dialogView.frame.size.width/2;
    }
    
    // 左ボタン
    UIButton *leftButton = [[UIButton alloc] init];
    leftButton.tag = MALERT_INDEX_LEFT_BUTTON;
    leftButton.frame = CGRectMake(0, dialogView.frame.size.height - buttonHeight, buttonWidth, buttonHeight);
    leftButton.backgroundColor = UIColor.clearColor;
    [leftButton setTitleColor:MALERT_FONT_COLOR forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(onPushAlertButton:) forControlEvents:UIControlEventTouchDown];
    leftButton.layer.cornerRadius = cornerRadius;
    leftButton.showsTouchWhenHighlighted = YES;
    [leftButton setTitle:_leftButtonTitle forState:UIControlStateNormal];
    [dialogView addSubview:leftButton];
    
    // 上ボーダー
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = [UIColor lightGrayColor].CGColor;
    topBorder.borderWidth = 1;
    topBorder.frame = CGRectMake(0, 0, dialogView.frame.size.width, 1);
    [leftButton.layer addSublayer:topBorder];
    
    // 右ボタン
    if (_rightButtonTitle != nil) {
        UIButton *rightButton = [[UIButton alloc] init];
        rightButton.tag = MALERT_INDEX_RIGHT_BUTTON;
        rightButton.frame = CGRectMake(buttonWidth, dialogView.frame.size.height - buttonHeight, buttonWidth, buttonHeight);
        rightButton.backgroundColor = UIColor.clearColor;
        [rightButton setTitleColor:MALERT_FONT_COLOR forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(onPushAlertButton:) forControlEvents:UIControlEventTouchDown];
        rightButton.layer.cornerRadius = cornerRadius;
        rightButton.showsTouchWhenHighlighted = YES;
        [rightButton setTitle:_rightButtonTitle forState:UIControlStateNormal];
        [dialogView addSubview:rightButton];
        
        // 左ボーダー
        CALayer *leftBorder = [CALayer layer];
        leftBorder.borderColor = [UIColor lightGrayColor].CGColor;
        leftBorder.borderWidth = 1;
        leftBorder.frame = CGRectMake(0, 0, 1, rightButton.frame.size.height);
        [rightButton.layer addSublayer:leftBorder];
    }
    
    [self tintColorDidChange];
    return;
}

/**
 * 表示
 */
- (void)show
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    dialogView.transform = transform;
    dialogView.alpha     = 0.5f;
    
    self.backgroundColor = UIColor.clearColor;
    self.hidden = NO;
    
    void (^animBlock)() = ^{
        dialogView.transform = CGAffineTransformIdentity;
        dialogView.alpha     = 1.0f;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    };
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animBlock
                     completion:nil];
    return;
}

/**
 * 非表示
 */
- (void)dismiss
{
    [self hide:YES completion:^{
        [self removeFromSuperview];
    }];
    return;
}

- (void)hide:(BOOL)animated completion:(void(^)())completionBlock
{
    dialogView.transform = CGAffineTransformIdentity;
    dialogView.alpha     = 1.0f;
    
    void(^animBlock)() = ^{
        CGAffineTransform transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        dialogView.transform = transform;
        dialogView.alpha     = 0.0f;
        self.backgroundColor = UIColor.clearColor;
    };
    
    void(^animCompletionBlock)(BOOL) = ^(BOOL finished) {
        self.hidden = YES;
        if (completionBlock) {
            completionBlock();
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:animBlock
                         completion:animCompletionBlock];
    } else {
        animBlock();
        animCompletionBlock(YES);
    }
    return;
}

#pragma mark - Helper to create UIMotionEffects

- (UIInterpolatingMotionEffect *)motionEffectWithKeyPath:(NSString *)keyPath type:(UIInterpolatingMotionEffectType)type
{
    UIInterpolatingMotionEffect *effect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:keyPath type:type];
    effect.minimumRelativeValue = @(-10);
    effect.maximumRelativeValue = @(10);
    return effect;
}

- (void)applyMotionEffects
{
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[[self motionEffectWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis],
                                        [self motionEffectWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis]];
    [dialogView addMotionEffect:motionEffectGroup];
    return;
}

#pragma mark - UIButton pushed

/**
 * アラートボタンのボタンをおした時
 */
- (void)onPushAlertButton:(id)sender
{
    UIButton *pushedButton = (UIButton *)sender;
    _compBlock(pushedButton.tag);
    [self dismiss];
    return;
}

@end
