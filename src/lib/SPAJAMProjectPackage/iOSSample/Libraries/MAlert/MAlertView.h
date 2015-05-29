//
//  MAlertView.h
//
//  Created by maichi on 2014/11/07.
//  Version:1.0
//

#import <UIKit/UIKit.h>

// フォントカラー（デフォルトはiOSの標準風 #146dfa）
#define MALERT_FONT_COLOR [UIColor colorWithRed:0.078 green:0.427 blue:0.980 alpha:1.0]

#define MALERT_INDEX_LEFT_BUTTON  1
#define MALERT_INDEX_RIGHT_BUTTON 2

@interface MAlertView : UIView

+ (MAlertView *)showAlertView:(NSString *)title
              leftButtonTitle:(NSString *)leftButtonTitle
             rightButtonTitle:(NSString *)rightButtonTitle
                   completion:(void (^)(NSInteger buttonIndex))completion;

+ (MAlertView *)showAlertModalView:(UIView *)modalView
                        leftButtonTitle:(NSString *)leftButtonTitle
                       rightButtonTitle:(NSString *)rightButtonTitle
                             completion:(void (^)(NSInteger buttonIndex))completion;

@end
