//
//  MActionsheetDatePickerView.h
//
//  Created by maichi on 2014/09/05.
//  Version:1.0
//
/*
 [how to use]
 
#import "MActionsheetDatePickerView.h"
 
 // sample code
 [MActionsheetDatePickerView setDatePickerView:@"1985/09/08"
                                    completion:(^(NSString *selectDate) {
                                        NSLog(@"selectDate=%@", selectDate);
 })];
 
 ※※ #define MACTIONDATE_FONT_COLOR でフォントカラー変更可
 ※※ #define SPACE で空白変更可

 // 日付けの型を変更
 #define MACTIONDATE_DATE_FORMAT
 
 // 日付けの最大、最小値を変更
 MACTIONDATE_MIN_DATE
 MACTIONDATE_MAX_DATE
 ※ MACTIONDATE_DATE_FORMATと同じ型でセットすること
 
 */

#import <UIKit/UIKit.h>

// フォントカラー（デフォルトはiOSの標準風 #146dfa）
#define MACTIONDATE_FONT_COLOR [UIColor colorWithRed:0.078 green:0.427 blue:0.980 alpha:1.00]
#define MACTIONDATE_DEFAULT_LOCAL @"en_US"
#define MACTIONDATE_SPACE 5

// 日付けの型
#define MACTIONDATE_DATE_FORMAT @"yyyy/MM/dd"
#define MACTIONDATE_MIN_DATE    @"1800/01/01"
#define MACTIONDATE_MAX_DATE    @"2100/12/31"

@interface MActionsheetDatePickerView : UIView

+ (MActionsheetDatePickerView *)setDatePickerView:(NSString *)defaultDateString
                                       completion:(void (^)(NSString *selectDate))completion;

@end

