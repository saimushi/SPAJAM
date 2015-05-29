//
//  MActionsheetButtonView.h
//
//  Created by maichi on 2014/07/30.
//  Version:1.0
/*
 [how to use]
 
 #import "MActionsheetButtonView.h"
 
 ・isCloseButtonがYESだと下にcancelボタンあり、NOだとなし
 
 // sample code
 [MActionsheetButtonView showActionsheetButtonView:[NSArray arrayWithObjects:@"１番上", @"２番め", nil]
                                    isCancelButton:YES
                                        completion:^(NSInteger buttonIndex) {
             // １番上のボタンを押した時
             if (buttonIndex == 1) {
                NSLog(@"first button pushed");
             
             // ２番めのボタンを押した時
             } else if (buttonIndex == 2) {
                NSLog(@"second button pushed");
             }
 }];
 
 ※※ #define MACTIONBUTTON_FONT_COLOR でフォントカラー変更可
 
 */

#import <UIKit/UIKit.h>

// フォントカラー（デフォルトはiOSの標準風 #146dfa）
#define MACTIONBUTTON_FONT_COLOR [UIColor colorWithRed:0.078 green:0.427 blue:0.980 alpha:1.00]


@interface MActionsheetButtonView : UIView

+ (MActionsheetButtonView *)showActionsheetButtonView:(NSArray *)buttonTitleArray
                                       isCancelButton:(BOOL)isCancelButton
                                           completion:(void (^)(NSInteger buttonIndex))completion;

@end
