//
//  MProgress.m
//
//  Created by maichi on 2014/07/24.
//  Version:1.0

#import "MProgress.h"

@implementation MProgress
{
    UIView *_lodingView;
}

/**
 * プログレスを表示
 */
+ (void)showProgress:(NSString *)argLoadingImageName :(NSString *)argLoadingText;
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MProgress *mProgress =[[self alloc] initProgressView:argLoadingImageName :argLoadingText];
    mProgress.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [window addSubview:mProgress];
    
    [mProgress show];
    
    // プログレスを表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void)showProgressWithLoadingText:(NSString *)argLoadingText;
{
    [MProgress showProgress:@"sample" :argLoadingText];
}

+ (void)showProgressWithLoadingImage:(NSString *)argLoadingImageName;
{
    [MProgress showProgress:argLoadingImageName :@"loading..."];
}

+ (void)showProgress
{
    [MProgress showProgress:@"sample" :@"loading..."];
}

/**
 * プログレスを非表示
 */
+ (void)dismissProgress
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    
    MProgress *mProgress;
    NSEnumerator *subviewsEnum = window.subviews.reverseObjectEnumerator;
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            mProgress = (MProgress *)subview;
            if (mProgress) {
                [mProgress dismiss];
            }
        }
    }
    
    // プログレスを非表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return;
}

#pragma mark - private function

- (id)initProgressView:(NSString *)argLoadingImageName :(NSString *)argLoadingText
{
    self = [self init];
    if (self) {
        [self setView:argLoadingImageName :argLoadingText];
    }
    return self;
}

- (void)setView:(NSString *)argLoadingImageName :(NSString *)argLoadingText
{
    CGRect bounds = self.superview.bounds;
    self.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    if ([self.superview isKindOfClass:UIWindow.class]
        && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
        self.bounds = (CGRect){CGPointZero, {bounds.size.height, bounds.size.width}};
        
    } else {
        self.bounds = (CGRect){CGPointZero, bounds.size};
    }
    
    self.hidden = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // ローディング画像をセット
    UIImage *loadingImage = [[UIImage alloc] init];
    if (ANIMATION_TYPE == 1) {
        loadingImage = [UIImage imageNamed:argLoadingImageName];
    } else {
        loadingImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png", argLoadingImageName]];
    }

    // ローディングビューをセット
    CGFloat loadingViewWidth  = loadingImage.size.width + MARGIN;
    CGFloat loadingViewHeight = loadingImage.size.height + MARGIN;
    CGSize mainScreenSize = [[UIScreen mainScreen] applicationFrame].size;
    _lodingView = [[UIView alloc] init];
    _lodingView.frame = CGRectMake((mainScreenSize.width - loadingViewWidth)/2,
                                   (mainScreenSize.height - loadingViewHeight)/2,
                                   loadingViewWidth,
                                   loadingViewHeight);
    _lodingView.backgroundColor    = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.9];
    _lodingView.layer.cornerRadius = 5.0f;
    [self addSubview:_lodingView];
    
    // 画像枠をセット
    UIImageView *lodingImageView = [[UIImageView alloc] init];
    lodingImageView.frame = CGRectMake((loadingViewWidth - loadingImage.size.width)/2,
                                       (loadingViewHeight - 20 - loadingImage.size.height)/2,
                                       loadingImage.size.width, loadingImage.size.height);
    lodingImageView.backgroundColor = [UIColor clearColor];
    lodingImageView.contentMode = UIViewContentModeScaleAspectFit;
    lodingImageView.image = loadingImage;
    [_lodingView addSubview:lodingImageView];
    
    // アニメーションタイプが1であれば、画像を回転
    if (ANIMATION_TYPE == 1) {
        [UIView animateWithDuration:0.5f
                              delay:0.5f
                            options:UIViewAnimationOptionRepeat
                         animations:^{
                             CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                             rotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI / 180) * 360];
                             rotationAnimation.duration = 2.0f;
                             rotationAnimation.repeatCount = HUGE_VALF;
                             [lodingImageView.layer addAnimation:rotationAnimation forKey:@"rotateAnimation"];
                         } completion:^(BOOL finished) {
                         }];
    
    // アニメーションタイプが2であれば、画像を入れ替え
    } else {
        NSMutableArray *rotationImageArray = [NSMutableArray array];
        for (NSInteger i = 1; i < IMAGE_NUM + 1; i++) {
            UIImage *rotationImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", argLoadingImageName, (int)i]];
            [rotationImageArray addObject:rotationImage];
        }
        lodingImageView.animationImages      = rotationImageArray;
        lodingImageView.animationDuration    = 0.8;
        lodingImageView.animationRepeatCount = 0;
        [lodingImageView startAnimating];
    }
    
    // 文字をセット
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.frame    = CGRectMake(0, _lodingView.frame.size.height - 20, _lodingView.frame.size.width, 12);
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.numberOfLines   = 0;
    loadingLabel.font            = [UIFont systemFontOfSize:10];
    loadingLabel.textColor       = [UIColor grayColor];
    loadingLabel.textAlignment   = NSTextAlignmentCenter;
    loadingLabel.lineBreakMode   = NSLineBreakByCharWrapping;
    loadingLabel.text            = argLoadingText;
    [_lodingView addSubview:loadingLabel];
    
    // 文字を点滅
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration     = 0.5f;
    animation.autoreverses = YES;
    animation.repeatCount  = HUGE_VALF;
    animation.fromValue    = [NSNumber numberWithFloat:1.0f];
    animation.toValue      = [NSNumber numberWithFloat:0.0f];
    [loadingLabel.layer addAnimation:animation forKey:@"blink"];
    
    [self applyMotionEffects];
    
    [self tintColorDidChange];
    return;
}

/**
 * 表示
 */
- (void)show
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    _lodingView.transform = transform;
    _lodingView.alpha     = 0.5f;
    
    self.backgroundColor = UIColor.clearColor;
    self.hidden = NO;
    
    void (^animBlock)() = ^{
        _lodingView.transform = CGAffineTransformIdentity;
        _lodingView.alpha     = 1.0f;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
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
    _lodingView.transform = CGAffineTransformIdentity;
    _lodingView.alpha     = 1.0f;
    
    void(^animBlock)() = ^{
        CGAffineTransform transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        _lodingView.transform = transform;
        _lodingView.alpha     = 0.0f;
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
    [_lodingView addMotionEffect:motionEffectGroup];
    return;
}

@end
