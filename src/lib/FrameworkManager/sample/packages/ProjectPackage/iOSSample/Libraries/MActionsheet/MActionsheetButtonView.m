//
//  MActionsheetButtonView.m
//
//  Created by maichi on 2014/07/30.
//  Version:1.0

#import "MActionsheetButtonView.h"

#define BUTTON_BG_HL_COLOR [UIColor colorWithRed:0.969 green:0.969 blue:0.961 alpha:0.98] // #F7F7F5

@implementation MActionsheetButtonView
{
    NSArray *_buttonTitleArray;
    void(^_compBlock)(NSInteger buttonIndex);
    BOOL _isCancelButton;
}

+ (MActionsheetButtonView *)showActionsheetButtonView:(NSArray *)buttonTitleArray
                                       isCancelButton:(BOOL)isCancelButton
                                           completion:(void (^)(NSInteger buttonIndex))completion;
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MActionsheetButtonView *mActionsheetButtonView = [[self alloc] initActionsheetButtonView:buttonTitleArray
                                                                              isCancelButton:(BOOL)isCancelButton
                                                                                  completion:(void (^)(NSInteger))completion];
    [window addSubview:mActionsheetButtonView];
    
    return mActionsheetButtonView;
}

/**
 * アクションシートビューを生成
 */
- (id)initActionsheetButtonView:(NSArray *)buttonTitleArray
                 isCancelButton:(BOOL)isCancelButton 
                     completion:(void (^)(NSInteger))completion
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    if (self) {
        _buttonTitleArray = [NSArray arrayWithArray:buttonTitleArray];
        _isCancelButton   = isCancelButton;
        _compBlock = [completion copy];
        
        [self setView];
    }
    return self;
}

- (void)setView
{
    CGFloat cornerRadius     = 5.0;
    CGFloat space            = 10.0f;
    CGFloat space_s          = 5.0f;
    CGFloat buttonHeight     = 50.0f;
    UIColor *buttonBgColor   = [UIColor colorWithRed:0.992 green:0.992 blue:0.980 alpha:0.98]; // #fdfdfa
    UIColor *buttonFontColor = MACTIONBUTTON_FONT_COLOR;
    
    // 背景
    self.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.4];
    
    // ピッカーとボタンのアニメーション背景
    UIView *bgView = [[UIView alloc] init];
    bgView.frame   = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgView];
    
    // ボタンを追加
    int countButtonTitleArray = (int)_buttonTitleArray.count;
    CGFloat firstButtonOriginY = bgView.frame.size.height - buttonHeight - space*2.0f;
    if (_isCancelButton == NO) {
        firstButtonOriginY = bgView.frame.size.height;
    }
    for (int i = 0; i < countButtonTitleArray; i++) {
        CGFloat buttonOriginY = firstButtonOriginY - buttonHeight*(countButtonTitleArray - i) - space_s*(countButtonTitleArray - i);
        
        UIButton *button = [[UIButton alloc] init];
        button.tag = i + 1;
        button.frame = CGRectMake(space, buttonOriginY, bgView.frame.size.width - space*2.0f, buttonHeight);
        button.backgroundColor = buttonBgColor;
        [button setTitleColor:buttonFontColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onPushMActionButton:) forControlEvents:UIControlEventTouchDown];
        button.layer.cornerRadius = cornerRadius;
        button.showsTouchWhenHighlighted = YES;
        [button setTitle:[_buttonTitleArray objectAtIndex:i] forState:UIControlStateNormal];
        [bgView addSubview:button];
    }
    
    // キャンセルボタン
    if (_isCancelButton == YES) {
        UIButton *leftButton = [[UIButton alloc] init];
        leftButton.frame = CGRectMake(space, bgView.frame.size.height - buttonHeight - space, bgView.frame.size.width - space*2.0f, buttonHeight);
        leftButton.backgroundColor = buttonBgColor;
        [leftButton setTitleColor:buttonFontColor forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(onPushCancelButton:) forControlEvents:UIControlEventTouchDown];
        leftButton.layer.cornerRadius = cornerRadius;
        leftButton.showsTouchWhenHighlighted = YES;
        [leftButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
        [bgView addSubview:leftButton];
    }
    
    // 下から表示
    CGPoint middleCenter = bgView.center;
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width/2.0, offSize.height*2.0);
    bgView.center = offScreenCenter;
    [UIView animateWithDuration:0.5f animations:^{
        bgView.center = middleCenter;
    }];
    
    return;
}

/**
 * 追加ボタンを押下
 */
- (void)onPushMActionButton:(id)sender
{
    UIButton *pushedButton = (UIButton *)sender;
    pushedButton.backgroundColor = BUTTON_BG_HL_COLOR;
    _compBlock(pushedButton.tag);
    [self hidePicker];
    return;
}

/**
 * キャンセル
 */
- (void)onPushCancelButton:(id)sender
{
    UIButton *pushedButton = (UIButton *)sender;
    pushedButton.backgroundColor = BUTTON_BG_HL_COLOR;
    [self hidePicker];
    return;
}

/**
 * ピッカーを隠す
 */
- (void)hidePicker
{
    UIView *bgView = [self.subviews objectAtIndex:0];
    
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width/2.0, offSize.height*3.0);
    [UIView animateWithDuration:0.3f animations:^{
        bgView.center = offScreenCenter;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(didFinishHidePicker) withObject:nil];
    }];
    return;
}

/**
 * ピッカーを隠し終った時
 */
- (void)didFinishHidePicker
{
    [self removeFromSuperview];
    return;
}

@end