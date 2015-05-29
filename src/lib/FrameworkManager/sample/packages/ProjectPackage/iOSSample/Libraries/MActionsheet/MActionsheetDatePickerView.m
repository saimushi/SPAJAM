//
//  MActionsheetDatePickerView.m
//
//  Created by maichi on 2014/09/05.
//  Version:1.0
//

#import "MActionsheetDatePickerView.h"

@implementation MActionsheetDatePickerView
{
    UIDatePicker *datePicker;
    NSString *_defaultDateString;
    void(^_compBlock)(NSString *selectDate);
}

+ (MActionsheetDatePickerView *)setDatePickerView:(NSString *)defaultDateString
                                       completion:(void (^)(NSString *selectDate))completion
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MActionsheetDatePickerView *mActionsheetDatePickerView = [[self alloc] initView:(NSString *)defaultDateString
                                                                         completion:(void (^)(NSString *selectDate))completion];
    [window addSubview:mActionsheetDatePickerView];
    return mActionsheetDatePickerView;
}

/**
 * 日付けピッカーのビューをセット
 */
- (id)initView:(NSString *)defaultDateString
    completion:(void (^)(NSString *selectDate))completion
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    if (self) {
        if (defaultDateString != nil) {
            _defaultDateString = [NSString stringWithString:defaultDateString];
        }
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
    datePicker = [[UIDatePicker alloc] init];
    
    // ピッカーとボタンのアニメーション背景
    UIView *pickerMiddleBgView = [[UIView alloc] init];
    pickerMiddleBgView.frame   = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    pickerMiddleBgView.backgroundColor = [UIColor clearColor];
    
    // ボタン背景
    UIView *bgBtnrView = [[UIView alloc] init];
    bgBtnrView.frame   = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 40 - datePicker.frame.size.height, self.frame.size.width, 40);
    bgBtnrView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    
    // キャンセルボタン
    UIButton *selectCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectCancelButton.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height - 40 - datePicker.frame.size.height, 100, 40);
    selectCancelButton.backgroundColor = [UIColor clearColor];
    [selectCancelButton setTitleColor:MACTIONDATE_FONT_COLOR forState:UIControlStateNormal];
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
    [selectOkButton setTitleColor:MACTIONDATE_FONT_COLOR forState:UIControlStateNormal];
    [selectOkButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    [selectOkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [selectOkButton sizeToFit];
    selectOkButton.frame = CGRectMake(self.frame.size.width - selectOkButton.frame.size.width - 20, selectCancelButton.frame.origin.y, selectOkButton.frame.size.width, 40);
    [selectOkButton addTarget:self action:@selector(onPushDatePickerOkButton:) forControlEvents:UIControlEventTouchUpInside];
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
    datePicker.frame = CGRectMake(0, selectCancelButton.frame.origin.y + selectCancelButton.frame.size.height, self.frame.size.width, datePicker.frame.size.height);
    datePicker.datePickerMode = UIDatePickerModeDate;

    // 現在日時
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 和暦回避
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    NSLog(@"%@", [[NSLocale preferredLanguages] objectAtIndex:0]);
    NSLog(@"%@", [NSLocale currentLocale].debugDescription);
    NSLog(@"%@", [NSCalendar currentCalendar].debugDescription);
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"ja"]) {
        // デートピッカーの書式を強制和暦に
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    }
    [formatter setDateFormat:MACTIONDATE_DATE_FORMAT];
//    if ([[[NSLocale alloc] objectForKey:@"ja_JP"] isEqualToString:[NSLocale currentLocale].description]){
//        
//    }

    NSLog(@"%@", datePicker.locale.debugDescription);
    NSLog(@"%@", datePicker.calendar.debugDescription);

    datePicker.backgroundColor = [UIColor clearColor];

    // ピッカー背景
    UIView *bgSelectPickerView = [[UIView alloc] init];
    bgSelectPickerView.frame   = CGRectMake(0,
                                            selectCancelButton.frame.origin.y + selectCancelButton.frame.size.height,
                                            self.frame.size.width,
                                            datePicker.frame.size.height + 45);
    bgSelectPickerView.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    [pickerMiddleBgView addSubview:bgSelectPickerView];
    [pickerMiddleBgView addSubview:datePicker];

    // ボタンは後から設置
    [pickerMiddleBgView addSubview:bgBtnrView];
    [pickerMiddleBgView addSubview:selectCancelButton];
    [pickerMiddleBgView addSubview:selectOkButton];
    
    // 最大最小値をセット
    datePicker.minimumDate = [formatter dateFromString:MACTIONDATE_MIN_DATE];
    datePicker.maximumDate = [formatter dateFromString:MACTIONDATE_MAX_DATE];

    // デフォルト値を設定
    if (_defaultDateString.length == MACTIONDATE_DATE_FORMAT.length) {
        [datePicker setDate:[formatter dateFromString:_defaultDateString]];
    }
    
    return;
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
 * 日付ピッカーOK
 */
- (void)onPushDatePickerOkButton:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.dateFormat = MACTIONDATE_DATE_FORMAT;
    NSString *selectedDate = [formatter stringFromDate:[datePicker date]];
    
    _compBlock(selectedDate);

    [self hidePicker];
}

@end
