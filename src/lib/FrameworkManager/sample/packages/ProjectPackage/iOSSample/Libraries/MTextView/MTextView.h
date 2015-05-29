//
//  MTextView.h
//
//  Created by saimushi on 2015/01/04.
//  Version:1.0
//
/**
 *  [How To Use]
 *
 // テキスト入力エリアを表示
 textView = [[MTextView alloc] initWithFrame:(CGRect)画面サイズのフレーム
  andIdentifier:(NSString *)テキストエリアのID
  andView:(UIView *)下部にテキストエリアを貼り付ける元のView
  andMaxInputLength:(int)最大入力文字数
  andTextAreaHieght:(int)テキストエリアの1行分(デフォルト)の高さ
  andPlaceHolder:(NSString *)プレースホルダー文字列
  andTextAreaBackgroundImage:(UIImage)テキストエリア背景
  andLeftBtnImage:(UIImage)左ボタン背景
  andRightImage:(UIImage)右ボタン背景
  leftBlock:^(NSString *inputText){
    // 左ボタン押下イベント
    // 左ボタンの(BOOL)enabledを返却
    return BOOL;
  } 
  rightBlock:^(NSString *inputText){
    // 右ボタン押下イベント
    // 右ボタンの(BOOL)enabledを返却
    return BOOL;
  }
  limitCheckBlock:^BOOL(BOOL limitUnover, float length) {
    // 文字数チェック結果イベント
    // 右ボタンの(BOOL)enabledを返却
    return BOOL;
 }];
 // LINE風テキスト入力エリアを描画
 [self.view addSubview:textView];


 // テキストエリアのキーボードを明示的に閉じる
 [textView hideKeyboard];


 // テキストエリアを明示的にクリアにする
 [textView clearText];


 // テキストエリアのテキストを明示的にセットする
 [textView setText:NSString];


 // 左ボタンのenableを明示的に指定する
 [textView enabledLeft:BOOL];


 // 右ボタンのenableを明示的に指定する
 [textView enabledLeft:BOOL];
 */

#import <QuartzCore/QuartzCore.h>

#define TEXTAREA_BASE_HEIGHT 44
#define TEXTAREA_BACKGROUND_COLOR [UIColor whiteColor]
#define TEXTVIEW_BG_COLOR  [UIColor clearColor]
//#define TEXTVIEW_FONT_SIZE 12
#define TEXTVIEW_FONT_SIZE 14
//#define TEXTVIEW_FONT_COLOR [UIColor grayColor]
#define PLACEHOLDER_FONT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f]
#define TEXTVIEW_FONT_COLOR [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]

@interface MTextView : UIView <UITextViewDelegate, NSLayoutManagerDelegate>
{
    UIView *textAreaView;
}

@property (strong, nonatomic) UIView *textAreaView;

/* 左右のボタン及び、テキストViewを指定して初期化 */
-(id)initWithFrame:(CGRect)argFrame andIdentifier:(NSString *)argIdentifier
           andView:(UIView *)argChildeView
 andMaxInputLength:(int)argMaxInputLength
 andTextAreaHieght:(float)argTextAreaHeight
    andPlaceHolder:(NSString *)argPlaceHolder
andTextAreaBackgroundImage:(UIImage *)argTextAreaBackgroundImage
       andTextView:(UITextView *)argTextView
        andLeftBtn:(UIButton *)argLeftBtn
       andRightBtn:(UIButton *)argRightBtn
         leftBlock:(BOOL(^)(NSString *inputText))argLeftCompletion
        rightBlock:(BOOL(^)(NSString *inputText))argRightCompletion
   limitCheckBlock:(BOOL(^)(BOOL limitUnover, float length))arglimitCheckCompletion;

/* 左右のボタン画像及び、テキストView背景画像を指定して初期化 */
-(id)initWithFrame:(CGRect)argFrame andIdentifier:(NSString *)argIdentifier
           andView:(UIView *)argChildeView
 andMaxInputLength:(int)argMaxInputLength
 andTextAreaHieght:(float)argTextAreaHeight
    andPlaceHolder:(NSString *)argPlaceHolder
andTextAreaBackgroundImage:(UIImage *)argTextAreaBackgroundImage
   andLeftBtnImage:(UIImage *)argLeftBtnImage
     andRightImage:(UIImage *)argRightBtnImage
         leftBlock:(BOOL(^)(NSString *inputText))argLeftCompletion
        rightBlock:(BOOL(^)(NSString *inputText))argRightCompletion
   limitCheckBlock:(BOOL(^)(BOOL limitUnover, float length))arglimitCheckCompletion;

/* 固定のUIで初期化 */
-(id)initWithFrame:(CGRect)argFrame andIdentifier:(NSString *)argIdentifier
           andView:(UIView *)argChildeView
 andMaxInputLength:(int)argMaxInputLength
    andPlaceHolder:(NSString *)argPlaceHolder
         leftBlock:(BOOL(^)(NSString *inputText))argLeftCompletion
        rightBlock:(BOOL(^)(NSString *inputText))argRightCompletion
   limitCheckBlock:(BOOL(^)(BOOL limitUnover, float length))arglimitCheckCompletion;

/* キーボードを外から閉じる */
- (void)hideKeyboard;
/* 入力テキストを外からクリアする */
- (void)clearText;
/* 入力テキストを外からセットする */
- (void)setText:(NSString *)argText;
/* 外から+ボタンのEnable・Disableを操作するアクセサ */
- (void)enabledLeft:(BOOL)argEnabled;
/* 外から送信ボタンのEnable・Disableを操作するアクセサ */
- (void)enabledRight:(BOOL)argEnabled;

@end
