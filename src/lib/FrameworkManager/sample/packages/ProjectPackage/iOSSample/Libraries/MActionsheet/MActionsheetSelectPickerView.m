//
//  MActionsheetSelectPickerView.m
//
//  Created by maichi on 2014/09/05.
//  Version:1.0
//

#import "MActionsheetSelectPickerView.h"

@implementation MActionsheetSelectPickerView
{
    UIPickerView *selectPickerView;
    int _defaultIndexInt;
    NSArray *_selectArray;
    void(^_compBlock)(NSInteger buttonIndex);
}

+ (MActionsheetSelectPickerView *)setSelectPickerView:(int)defaultIndex
                                          selectArray:(NSArray *)selectArray
                                           completion:(void (^)(NSInteger selectIndex))completion;
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MActionsheetSelectPickerView *mActionsheetSelectPickerView = [[self alloc] initView:(int)defaultIndex
                                                                            selectArray:(NSArray *)selectArray
                                                                             completion:(void (^)(NSInteger selectIndex))completion];
    [window addSubview:mActionsheetSelectPickerView];
    return mActionsheetSelectPickerView;
}

/**
 * 選択ピッカーのビューをセット
 */
- (id)initView:(int)defaultIndex
   selectArray:(NSArray *)selectArray
    completion:(void (^)(NSInteger selectIndex))completion
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    if (self) {
        _defaultIndexInt = defaultIndex;
        _selectArray     = [NSArray arrayWithArray:selectArray];
        _compBlock = [completion copy];
        [self setView];
    }
    return self;
}

- (void)setView
{
    // 背景を黒透明にする
    self.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.5];

    // ピッカー初期化
    selectPickerView = [[UIPickerView alloc] init];

    // ピッカーとボタンのアニメーション背景
    UIView *pickerMiddleBgView = [[UIView alloc] init];
    pickerMiddleBgView.frame   = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    pickerMiddleBgView.backgroundColor = [UIColor clearColor];

    // ボタン背景
    UIView *bgBtnrView = [[UIView alloc] init];
    bgBtnrView.frame   = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 40 - selectPickerView.frame.size.height, self.frame.size.width, 40);
    bgBtnrView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];

    // キャンセルボタン
    UIButton *selectCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectCancelButton.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height - 40 - selectPickerView.frame.size.height, 100, 40);
    selectCancelButton.backgroundColor = [UIColor clearColor];
    [selectCancelButton setTitleColor:MACTIONSELECT_FONT_COLOR forState:UIControlStateNormal];
    [selectCancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    [selectCancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [selectCancelButton sizeToFit];
    selectCancelButton.frame = CGRectMake(20, selectCancelButton.frame.origin.y, selectCancelButton.frame.size.width, 40);
    [selectCancelButton addTarget:self action:@selector(onPushPickerCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    selectCancelButton.userInteractionEnabled = YES;
    
    // OKボタン
    UIButton *selectOkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectOkButton.frame = CGRectMake(self.frame.size.width - 100, selectCancelButton.frame.origin.y, 100, 40);
    selectOkButton.backgroundColor = [UIColor clearColor];
    [selectOkButton setTitleColor:MACTIONSELECT_FONT_COLOR forState:UIControlStateNormal];
    [selectOkButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    [selectOkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [selectOkButton sizeToFit];
    selectOkButton.frame = CGRectMake(self.frame.size.width - selectOkButton.frame.size.width - 20, selectCancelButton.frame.origin.y, selectOkButton.frame.size.width, 40);
    [selectOkButton addTarget:self action:@selector(onPushSelectPickerOkButton:) forControlEvents:UIControlEventTouchUpInside];
    selectOkButton.userInteractionEnabled = YES;
    
    // 下から表示
    CGPoint middleCenter = pickerMiddleBgView.center;
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width/2.0, offSize.height*2.0);
    pickerMiddleBgView.center = offScreenCenter;
    [self addSubview:pickerMiddleBgView];
    [UIView animateWithDuration:0.5f animations:^{
        pickerMiddleBgView.center = middleCenter;
    }];
    
    // ピッカーの作成
    selectPickerView.frame = CGRectMake(0, selectCancelButton.frame.origin.y + selectCancelButton.frame.size.height, self.frame.size.width, selectPickerView.frame.size.height);
    selectPickerView.delegate   = self;
    selectPickerView.dataSource = self;
    selectPickerView.backgroundColor = [UIColor clearColor];
    selectPickerView.showsSelectionIndicator = YES;
    
    // ピッカー背景
    UIView *bgSelectPickerView = [[UIView alloc] init];
    bgSelectPickerView.frame   = CGRectMake(0,
                                            selectCancelButton.frame.origin.y + selectCancelButton.frame.size.height,
                                            self.frame.size.width,
                                            selectPickerView.frame.size.height + 45);
    bgSelectPickerView.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    [pickerMiddleBgView addSubview:bgSelectPickerView];
    [pickerMiddleBgView addSubview:selectPickerView];

    // ボタンは後から設置
    [pickerMiddleBgView addSubview:bgBtnrView];
    [pickerMiddleBgView addSubview:selectCancelButton];
    [pickerMiddleBgView addSubview:selectOkButton];

    // デフォルト値を設定
    [selectPickerView selectRow:_defaultIndexInt inComponent:0 animated:NO];
    
    return;
}

#pragma mark - set UIPickerView

/**
 * ピッカーに表示する列数を返す
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/**
 * ピッカーに表示する行数を返す
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _selectArray.count;
}

/**
 * ピッカーの内容を設定
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_selectArray objectAtIndex:row];
}

/**
 * ピッカーを隠す
 */
- (void)hidePicker
{
    UIView *pickerMiddleBgView = [self.subviews objectAtIndex:0];
    
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width/2.0, offSize.height*3.0);
    [UIView animateWithDuration:0.5f animations:^{
        pickerMiddleBgView.center = offScreenCenter;
    } completion:^(BOOL finished) {
        //
        [self performSelector:@selector(didFinishHidePicker) withObject:nil];
    }];
}

/**
 * ピッカーを隠し終った時
 */
- (void)didFinishHidePicker
{
    [self removeFromSuperview];
}

#pragma mark - UIButton pushed

/**
 * ピッカーキャンセル
 */
- (void)onPushPickerCancelButton:(id)sender
{
    [self hidePicker];
}

/**
 * 選択ピッカーOK
 */
- (void)onPushSelectPickerOkButton:(id)sender
{
    // 選択されたindex
    NSInteger selectedRow = [selectPickerView selectedRowInComponent:0];
    _compBlock(selectedRow);
    
    [self hidePicker];
    return;
}

@end
