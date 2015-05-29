//
//  MStatusbarProgress.h
//
//  Created by saimushi on 2015/01/14.
//  Version:1.0
/**
 *  [How To Use]
 *  
 *  // 表示
 *  [MStatusbarProgress show:総送信バイト数 :総バイト数];
 *  
 *  // 非表示
 *  非表示は、総バイト数に達したと判断された場合、一定時間後に自動で非表示されます
 */

#import <UIKit/UIKit.h>

// プログレスカラー
//#define MSTATUSBAR_PROGRESS_COLOR  [UIColor blueColor]
#define MSTATUSBAR_PROGRESS_COLOR  [UIColor colorWithRed:0.67 green:0.84 blue:0.20 alpha:0.5f]

// プログレスの高さ
#define MSTATUSBAR_PROGRESS_HEIGHT 22.0f

@interface MStatusbarProgress : UIView

+ (void)show:(double)argTotalBytesSent :(double)argTotalBytes;

@end
