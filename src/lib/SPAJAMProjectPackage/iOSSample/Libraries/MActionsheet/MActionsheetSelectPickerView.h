//
//  MActionsheetSelectPickerView.h
//
//  Created by maichi on 2014/09/05.
//  Version:1.0
//
/*
 [how to use]
 
 #import "MActionsheetSelectPickerView.h"

// sample code
 NSArray *selectArray = [[NSArray alloc] initWithObjects:@"１番目", @"２番目", @"３番目", @"４番目", nil];
 [MActionsheetSelectPickerView setSelectPickerView:2
                                       selectArray:selectArray
                                        completion:^(NSInteger selectIndex) {
                                            NSLog(@"selectIndex=%d", selectIndex);
 }];

※※ #define MACTIONDATE_FONT_COLOR でフォントカラー変更可
※※ #define SPACE で空白変更可

*/

#import <UIKit/UIKit.h>

// フォントカラー（デフォルトはiOSの標準風 #146dfa）
#define MACTIONSELECT_FONT_COLOR [UIColor colorWithRed:0.078 green:0.427 blue:0.980 alpha:1.00]

@interface MActionsheetSelectPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

+ (MActionsheetSelectPickerView *)setSelectPickerView:(int)defaultIndex
                                          selectArray:(NSArray *)selectArray
                                           completion:(void (^)(NSInteger selectIndex))completion;

@end