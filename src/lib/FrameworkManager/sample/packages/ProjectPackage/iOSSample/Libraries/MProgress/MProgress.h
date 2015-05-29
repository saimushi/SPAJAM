//
//  MProgress.h
//
//  Created by maichi on 2014/07/24.
//  Version:1.0
/**
 *  [How To Use]
 *  
 *  1. ローディング画像のアニメーションタイプを選択
 *  #define ANIMATION_TYPE を１または2にセット
 *
 *  2. ローディング画像名をセット
 *  ・アニメーションタイプ１の時 用意する画像例 (sample1.png)  ⇒　この時IMAGE_NAME は @"sample"
 *  ・アニメーションタイプ２の時 用意する画像例 (sample1.png, sample2.png, sample3.png) ⇒　この時IMAGE_NAME は @"sample"
 *
 *  3. アニメーションタイプが2のときは、画像数をセット
 *  IMAGE_NUM に画像数をセット(1以上)
 *  
 *  4. 画像のスペースをセット
 *  MARGIN に フロートで数値をセット(めあす 50.0)
 *
 *  5. コントローラーからローディングを表示/非表示
 *  コントローラーでファイルをインポート
 *  #import "MProgress.h"
 *  
 *  // 表示
 *  [MProgress showProgress];
 *  
 *  // 非表示
 *  [MProgress dismissProgress];
 */

#import <UIKit/UIKit.h>

// 1:回転 2:複数の画像を順番に表示
#define ANIMATION_TYPE 1

// 2の場合に使う画像数
#define IMAGE_NUM  1

// 画像のスペース
#define MARGIN 50.0

@interface MProgress : UIView

+ (void)showProgress:(NSString *)argLoadingImageName :(NSString *)argLoadingText;
+ (void)showProgressWithLoadingText:(NSString *)argLoadingText;
+ (void)showProgressWithLoadingImage:(NSString *)argLoadingImageName;
+ (void)showProgress;
+ (void)dismissProgress;

@end
