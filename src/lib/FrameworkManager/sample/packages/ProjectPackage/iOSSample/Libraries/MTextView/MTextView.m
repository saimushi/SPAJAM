//
//  MTextView.h
//
//  Created by saimushi on 2015/01/04.
//  Version:1.0
//

#import "MTextView.h"

@implementation MTextView
{
    BOOL initialized;
    NSString *messageIdentifier;
    NSString *placeHolder;
    int maxInputLength;
    BOOL placeHolderHidden;
    UIColor *textViewFontColor;
    float textViewHeight;
    float textAreaHeight;
    float latestKeyboardHeight;
    float onelineTextHeight;
    UIView *childeView;
    UIImageView *textAreaBGView;
    UITextView *textView;
    UIButton *leftBtn;
    UIButton *rightBtn;
    NSRange latestRange;
    // 高さも含めてオリジナルなサイズ
    CGRect childeViewOriginFrame;
    CGRect textAreaViewOriginFrame;
    // 高さが変わる度に切り替わるオリジナルサイズ
    CGRect childeViewLatestOriginFrame;
    CGRect textAreaViewLatestOriginFrame;
    UITapGestureRecognizer *tapGesture;
    BOOL (^leftBtnBlock)(NSString *inputText);
    BOOL (^rightBtnBlock)(NSString *inputText);
    BOOL (^limitCheckBlock)(BOOL limitUnover, float length);
}

@synthesize textAreaView;

#pragma mark override methods

-(void)dealloc
{
    // ローカル通知を破棄する
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark public methods

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
        limitCheckBlock:(BOOL(^)(BOOL limitUnover, float length))argLimitCheckCompletion;
{
    self = [super initWithFrame:argFrame];
    if (self) {
        initialized = NO;
        // メッセージ識別子を保持
        messageIdentifier = argIdentifier;
        // プレースホルダーを設定
        placeHolder = @"";
        if (nil != argPlaceHolder && 0 < argPlaceHolder.length){
            placeHolder = argPlaceHolder;
        }
        // 最大入力文字数
        // XXX デフォルトは制限なしとする
        maxInputLength = -1;
        if (0 < argMaxInputLength){
            maxInputLength = argMaxInputLength;
        }
        
        self.backgroundColor = [UIColor clearColor];
        childeView = argChildeView;
        childeView.frame = CGRectMake(argChildeView.frame.origin.x, 0, argChildeView.frame.size.width, self.frame.size.height - argTextAreaHeight);
        // 初期位置を保持しておく
        childeViewOriginFrame = childeView.frame;
        // 最終表示位置を保持しておく
        childeViewLatestOriginFrame = childeViewOriginFrame;
        // はみ出し表示を許可しておく
        if ([childeView isKindOfClass:NSClassFromString(@"UIScrollView")]) {
            childeView.clipsToBounds = NO;
            NSLog(@"offset-y=%f", ((UIScrollView *)childeView).contentOffset.y);
            NSLog(@"size-y=%f", ((UIScrollView *)childeView).contentSize.height);
        }
        [self addSubview:childeView];

        // テキストエリア
        self.textAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - argTextAreaHeight, self.frame.size.width, argTextAreaHeight)];
        self.textAreaView.backgroundColor = TEXTAREA_BACKGROUND_COLOR;
        // はみ出した部分は表示
        self.textAreaView.clipsToBounds = NO;
        // はみ出し表示になった時用の背景
        UIView *textAreaOverBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.textAreaView.frame.size.width, self.textAreaView.frame.size.height + 260)];
        textAreaOverBGView.backgroundColor = TEXTAREA_BACKGROUND_COLOR;
        textAreaOverBGView.clipsToBounds = NO;
        [self.textAreaView addSubview:textAreaOverBGView];
        textAreaBGView = nil;
        // テキストエリア背景
        if (nil != argTextAreaBackgroundImage){
            // 背景を画像で表示
            textAreaBGView = [[UIImageView alloc] initWithImage:[argTextAreaBackgroundImage stretchableImageWithLeftCapWidth:argTextAreaBackgroundImage.size.width / 2.0f topCapHeight:argTextAreaBackgroundImage.size.height / 2.0f]];
            textAreaBGView.frame = CGRectMake(0, self.textAreaView.frame.size.height - argTextAreaBackgroundImage.size.height, self.textAreaView.frame.size.width, self.textAreaView.frame.size.height);
            textAreaBGView.clipsToBounds = NO;
            [self.textAreaView addSubview:textAreaBGView];
        }
        // テキストView
        textView = argTextView;
        textViewHeight = textView.frame.size.height;
        // デレゲートを強制で奪う
        textView.delegate = self;
        textView.layoutManager.delegate = self;
        // 強制編集化
        textView.editable = YES;
        textView.scrollEnabled = NO;
        // 強制左寄せ
        textView.textAlignment = NSTextAlignmentLeft;
        // プレースホルダーを一旦デフォルトテキストに指定
        textView.text = placeHolder;
        // プレースホルダー設定
        placeHolderHidden = NO;
        textViewFontColor = textView.textColor;
        textView.textColor = PLACEHOLDER_FONT_COLOR;
        // 初期位置を保持しておく
        textAreaViewOriginFrame = textAreaView.frame;
        // 最終表示位置を保持しておく
        textAreaViewLatestOriginFrame = textAreaViewOriginFrame;
        // デフォルトのコンテンツサイズをリサジング用に取っておく
        [self.textAreaView addSubview:textView];

        // 1行分のコメントの高さを定義しておく
        NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:@"1" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : textView.font}];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByCharWrapping;
        style.alignment = NSTextAlignmentLeft;
        CGRect commentRect = [commentString boundingRectWithSize:CGSizeMake(textView.frame.size.width - 10, textView.frame.size.height * maxInputLength) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        onelineTextHeight = commentRect.size.height;

        // latestNSRangeの初期化
        latestRange = NSRangeFromString(@"");

        // 左ボタン
        leftBtn = argLeftBtn;
        // ボタン押下で実行するブロックの定義
        leftBtnBlock = argLeftCompletion;
        if (nil != leftBtnBlock) {
            // 左ボタンを設置
            if (CGRectEqualToRect(leftBtn.frame, CGRectZero)){
                leftBtn.frame = CGRectMake(10, (argTextAreaHeight - (argTextAreaHeight / 2.0f)) / 2.0f, argTextAreaHeight / 2.0f, argTextAreaHeight / 2.0f);
            }
            [leftBtn addTarget:self action:@selector(onPushLeft:) forControlEvents:UIControlEventTouchUpInside];
            [self.textAreaView addSubview:leftBtn];
        }
        
        // 右ボタン
        rightBtn = argRightBtn;
        // ボタン押下で実行するブロックの定義
        rightBtnBlock = argRightCompletion;
        if (nil != rightBtnBlock) {
            // 右ボタンを設置
            if (CGRectEqualToRect(rightBtn.frame, CGRectZero)){
                rightBtn.frame = CGRectMake(argFrame.size.width - rightBtn.frame.size.width - 10, (argTextAreaHeight - rightBtn.frame.size.height) / 2.0f, rightBtn.frame.size.width, rightBtn.frame.size.height);
            }
            [rightBtn addTarget:self action:@selector(onPushRight:) forControlEvents:UIControlEventTouchUpInside];
            [self.textAreaView addSubview:rightBtn];
        }

        // 文字数制限チェック完了時に実行するブロックの定期
        limitCheckBlock = argLimitCheckCompletion;

        // タップ登録
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouch:)];
        // 先ずは無効にしておく
        tapGesture.enabled = NO;
        [childeView addGestureRecognizer:tapGesture];
        
        // テキストエリアは最後にAdd
        [self addSubview:self.textAreaView];

        // テキストエリアの初期の高さを取っておく(サイズ比較・移動処理用)
        textAreaHeight = TEXTAREA_BASE_HEIGHT;
        if (0 < argTextAreaHeight){
            textAreaHeight = argTextAreaHeight;
        }

        // 最後の表示キーボードの高さを0にリセット
        latestKeyboardHeight = 0.0f;

        // メッセージ識別子に一致したメッセージがローカルに保存されていたら、それをデフォルトテキストとしてセットして上げる
        if (nil != messageIdentifier && 0 < messageIdentifier.length) {
            NSString *defaultString = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Default-message-%@", messageIdentifier]];
            if (nil != defaultString && 0 < defaultString.length) {
                [self setText:defaultString];
            }
        }
        initialized = YES;
    }
    return self;
}

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
   limitCheckBlock:(BOOL(^)(BOOL limitUnover, float length))argLimitCheckCompletion;
{
    // 左ボタン
    UIButton *_leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (nil != argLeftBtnImage) {
        // イメージボタンで生成
        _leftBtn.backgroundColor = [UIColor clearColor];
        [_leftBtn setBackgroundImage:argLeftBtnImage forState:UIControlStateNormal];
        _leftBtn.frame = CGRectMake(10, (TEXTAREA_BASE_HEIGHT - argLeftBtnImage.size.height) / 2.0f, argLeftBtnImage.size.width, argLeftBtnImage.size.height);
    }
    else {
        _leftBtn.backgroundColor = [UIColor grayColor];
        _leftBtn.frame = CGRectMake(10, (TEXTAREA_BASE_HEIGHT - (TEXTAREA_BASE_HEIGHT / 2.0f)) / 2.0f, TEXTAREA_BASE_HEIGHT / 2.0f, TEXTAREA_BASE_HEIGHT / 2.0f);
        [_leftBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [_leftBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_leftBtn setTitle:NSLocalizedString(@"+", @"+") forState:UIControlStateNormal];
        [_leftBtn setTitle:NSLocalizedString(@"+", @"+") forState:UIControlStateHighlighted];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
        // 角丸に
        _leftBtn.layer.cornerRadius = _leftBtn.frame.size.height / 5.0f;
    }
    
    // 右ボタン
    UIButton *_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (nil != argRightBtnImage) {
        _rightBtn.backgroundColor = [UIColor clearColor];
        [_rightBtn setBackgroundImage:argRightBtnImage forState:UIControlStateNormal];
        _rightBtn.frame = CGRectMake(argFrame.size.width - argRightBtnImage.size.width - 10, (TEXTAREA_BASE_HEIGHT - argRightBtnImage.size.height) / 2.0f, argRightBtnImage.size.width, argRightBtnImage.size.height);
    }
    else {
        _rightBtn.backgroundColor = [UIColor greenColor];
        _rightBtn.frame = CGRectMake(argFrame.size.width - TEXTAREA_BASE_HEIGHT - 10, (TEXTAREA_BASE_HEIGHT - (TEXTAREA_BASE_HEIGHT / 2.0f)) / 2.0f, TEXTAREA_BASE_HEIGHT, TEXTAREA_BASE_HEIGHT / 2.0f);
        [_rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [_rightBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_rightBtn setTitle:NSLocalizedString(@"Send", @"Send") forState:UIControlStateNormal];
        [_rightBtn setTitle:NSLocalizedString(@"Send", @"Send") forState:UIControlStateHighlighted];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
        // 角丸に
        _rightBtn.layer.cornerRadius = _rightBtn.frame.size.height / 5.0f;
    }
    
    // 中央テキストエリア
    float height = TEXTVIEW_FONT_SIZE * 1.7f;
    UITextView *_textView = [[UITextView alloc] initWithFrame:CGRectMake(_leftBtn.frame.origin.x + _leftBtn.frame.size.width + 10, _rightBtn.frame.origin.y + (_rightBtn.frame.size.height - height) / 2.0f, argFrame.size.width - _leftBtn.frame.size.width - _rightBtn.frame.size.width - 10 * 4, height)];
    _textView.font = [UIFont systemFontOfSize:TEXTVIEW_FONT_SIZE];
    _textView.textColor = TEXTVIEW_FONT_COLOR;
    _textView.backgroundColor = TEXTVIEW_BG_COLOR;
    // パディング制御
    _textView.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    return [self initWithFrame:argFrame andIdentifier:argIdentifier andView:argChildeView andMaxInputLength:argMaxInputLength andTextAreaHieght:argTextAreaHeight andPlaceHolder:(NSString *)argPlaceHolder andTextAreaBackgroundImage:argTextAreaBackgroundImage andTextView:_textView andLeftBtn:_leftBtn andRightBtn:_rightBtn leftBlock:argLeftCompletion rightBlock:argRightCompletion limitCheckBlock:argLimitCheckCompletion];
}

-(id)initWithFrame:(CGRect)argFrame andIdentifier:(NSString *)argIdentifier
           andView:(UIView *)argChildeView
 andMaxInputLength:(int)argMaxInputLength
    andPlaceHolder:(NSString *)argPlaceHolder
         leftBlock:(BOOL(^)(NSString *inputText))argLeftCompletion
        rightBlock:(BOOL(^)(NSString *inputText))argRightCompletion
   limitCheckBlock:(BOOL(^)(BOOL limitUnover, float length))argLimitCheckCompletion;
{
    // 左ボタン
    UIButton *_leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.backgroundColor = [UIColor grayColor];
    _leftBtn.frame = CGRectMake(10, (TEXTAREA_BASE_HEIGHT - (TEXTAREA_BASE_HEIGHT / 2.0f)) / 2.0f, TEXTAREA_BASE_HEIGHT / 2.0f, TEXTAREA_BASE_HEIGHT / 2.0f);
    [_leftBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [_leftBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_leftBtn setTitle:NSLocalizedString(@"+", @"+") forState:UIControlStateNormal];
    [_leftBtn setTitle:NSLocalizedString(@"+", @"+") forState:UIControlStateHighlighted];
    [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_leftBtn setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    // 角丸に
    _leftBtn.layer.cornerRadius = _leftBtn.frame.size.height / 5.0f;
    
    // 右ボタン
    UIButton *_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.backgroundColor = [UIColor greenColor];
    _rightBtn.frame = CGRectMake(argFrame.size.width - TEXTAREA_BASE_HEIGHT - 10, (TEXTAREA_BASE_HEIGHT - (TEXTAREA_BASE_HEIGHT / 2.0f)) / 2.0f, TEXTAREA_BASE_HEIGHT, TEXTAREA_BASE_HEIGHT / 2.0f);
    [_rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [_rightBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_rightBtn setTitle:NSLocalizedString(@"Send", @"Send") forState:UIControlStateNormal];
    [_rightBtn setTitle:NSLocalizedString(@"Send", @"Send") forState:UIControlStateHighlighted];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    // 角丸に
    _rightBtn.layer.cornerRadius = _rightBtn.frame.size.height / 5.0f;
    
    float height = TEXTVIEW_FONT_SIZE * 1.7f;
    UITextView *_textView = [[UITextView alloc] initWithFrame:CGRectMake(_leftBtn.frame.origin.x + _leftBtn.frame.size.width + 10, _rightBtn.frame.origin.y + (_rightBtn.frame.size.height - height) / 2.0f, argFrame.size.width - _leftBtn.frame.size.width - _rightBtn.frame.size.width - 10 * 4, height)];
    _textView.font = [UIFont systemFontOfSize:TEXTVIEW_FONT_SIZE];
    _textView.textColor = TEXTVIEW_FONT_COLOR;
    _textView.backgroundColor = TEXTVIEW_BG_COLOR;
    // パディング制御
    _textView.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    // 角丸&ボーダー
    _textView.layer.borderWidth = 1.0f;
    _textView.layer.cornerRadius = _textView.frame.size.height / 5.0f;
    _textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    return [self initWithFrame:argFrame andIdentifier:argIdentifier andView:argChildeView andMaxInputLength:argMaxInputLength andTextAreaHieght:TEXTAREA_BASE_HEIGHT andPlaceHolder:(NSString *)argPlaceHolder andTextAreaBackgroundImage:nil andTextView:_textView andLeftBtn:_leftBtn andRightBtn:_rightBtn leftBlock:argLeftCompletion rightBlock:argRightCompletion limitCheckBlock:argLimitCheckCompletion];
}

/* 外からキーボードを閉じれる用にするアクセサ */
- (void)hideKeyboard;
{
    [self onTouch:nil];
}

/* 外から入力テキストをクリアにし、エリアを低く出来る用にするアクセサ */
- (void)clearText;
{
    textView.text = placeHolder;
    placeHolderHidden = NO;
    textView.textColor = PLACEHOLDER_FONT_COLOR;
    // テキストエリアのりサイズをshouldChangeにお願いする
    [self textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@""];
}

/* 外から入力テキストを設定し、エリアサイズをリサイズ出来る用にするアクセサ */
- (void)setText:(NSString *)argText;
{
    NSRange range = textView.selectedRange;
    textView.scrollEnabled = NO;
    textView.text = argText;
    placeHolderHidden = YES;
    textView.textColor = textViewFontColor;
    // テキストエリアのりサイズをshouldChangeにお願いする
    [self textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@""];
    textView.text = argText;
    range.length = 0;
    textView.selectedRange = range;
}

/* 外から+ボタンのEnable・Disableを操作するアクセサ */
- (void)enabledLeft:(BOOL)argEnabled;
{
    leftBtn.enabled = argEnabled;
}

/* 外から送信ボタンのEnable・Disableを操作するアクセサ */
- (void)enabledRight:(BOOL)argEnabled;
{
    rightBtn.enabled = argEnabled;
}

#pragma mark private methods

- (void)onPushLeft:(id)sender
{
    leftBtn.enabled = NO;
    NSString *inputText = textView.text;
    if (NO == placeHolderHidden) {
        inputText = @"";
    }
    [self enabledLeft:leftBtnBlock(inputText)];
}

- (void)onPushRight:(id)sender
{
    rightBtn.enabled = NO;
    NSString *inputText = textView.text;
    if (NO == placeHolderHidden) {
        inputText = @"";
    }
    [self enabledRight:rightBtnBlock(inputText)];
}

- (void)onTouch:(id)sender
{
    if (YES == tapGesture.enabled) {
        // 画面タッチを無効に
        tapGesture.enabled = NO;
        // キーボードを閉じる
        [textView resignFirstResponder];
    }
}


#pragma mark Keyboard NSNotification

/* キーボード表示アニメーション */
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // スクロールコンテンツのオフセット移動処理用
    // ありえない数字で初期化
    CGPoint offset = CGPointMake(-10000, -10000);
    if ([childeView isKindOfClass:NSClassFromString(@"UIScrollView")]) {
        offset = ((UIScrollView *)childeView).contentOffset;
    }
    if (0.0 < duration) {
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            self.textAreaView.frame = CGRectMake(self.textAreaView.frame.origin.x, textAreaViewLatestOriginFrame.origin.y - keyboardFrame.size.height, self.textAreaView.frame.size.width, self.textAreaView.frame.size.height);
            // コンテンツ領域内のオフセットの移動判定
            if (latestKeyboardHeight != keyboardFrame.size.height && 0 < offset.y){
                // キーボードサイズが変わった場合且つ、スクロールコンテンツの場合はオフセットを元の位置に戻して上げる
                [((UIScrollView *)childeView) setContentOffset:CGPointMake(offset.x, offset.y + (keyboardFrame.size.height - latestKeyboardHeight))];
            }
        } completion:^(BOOL finished) {
            // チャイルドViewをリサイズ
            childeView.frame = CGRectMake(childeView.frame.origin.x, childeViewLatestOriginFrame.origin.y, childeView.frame.size.width, childeViewLatestOriginFrame.size.height - keyboardFrame.size.height);
            // コンテンツ領域内のオフセットの移動判定
            if (latestKeyboardHeight != keyboardFrame.size.height && 0 < offset.y){
                // キーボードサイズが変わった場合且つ、スクロールコンテンツの場合はオフセットを元の位置に戻して上げる
                [((UIScrollView *)childeView) setContentOffset:CGPointMake(offset.x, offset.y + (keyboardFrame.size.height - latestKeyboardHeight))];
            }
            // 画面タッチを有効に
            tapGesture.enabled = YES;
            // 最後の表示キーボードの高さを取っておく
            latestKeyboardHeight = keyboardFrame.size.height;
        }];
    }
    else {
        self.textAreaView.frame = CGRectMake(self.textAreaView.frame.origin.x, textAreaViewLatestOriginFrame.origin.y - keyboardFrame.size.height, self.textAreaView.frame.size.width, self.textAreaView.frame.size.height);
        // チャイルドViewをリサイズ
        childeView.frame = CGRectMake(childeView.frame.origin.x, childeViewLatestOriginFrame.origin.y, childeView.frame.size.width, childeViewLatestOriginFrame.size.height - keyboardFrame.size.height);
        // コンテンツ領域内のオフセットの移動判定
        if (latestKeyboardHeight != keyboardFrame.size.height && 0 < offset.y){
            // キーボードサイズが変わった場合且つ、スクロールコンテンツの場合はオフセットを元の位置に戻して上げる
            [((UIScrollView *)childeView) setContentOffset:CGPointMake(offset.x, offset.y + (keyboardFrame.size.height - latestKeyboardHeight))];
        }
        // 画面タッチを有効に
        tapGesture.enabled = YES;
        // 最後の表示キーボードの高さを取っておく
        latestKeyboardHeight = keyboardFrame.size.height;
    }
}

/* キーボード非表示アニメーション */
- (void)keyboardWillHide:(NSNotification *)notification {
    // ローカル通知を破棄する
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    // キーボードが閉じるアニメーションに合わせてテキスト入力エリアを移動する
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // ありえない数字で初期化
    CGPoint offset = CGPointMake(-10000, -10000);
    if ([childeView isKindOfClass:NSClassFromString(@"UIScrollView")]) {
        offset = CGPointMake(((UIScrollView *)childeView).contentOffset.x, ((UIScrollView *)childeView).contentOffset.y - keyboardFrame.size.height);
        NSLog(@"offset-now-y=%f", ((UIScrollView *)childeView).contentOffset.y);
    }
    childeView.frame = CGRectMake(childeViewLatestOriginFrame.origin.x, childeViewLatestOriginFrame.origin.y - childeView.frame.size.height, childeViewLatestOriginFrame.size.width, childeViewLatestOriginFrame.size.height);
    if (0 < offset.y){
        NSLog(@"offset-changed-y=%f", ((UIScrollView *)childeView).contentOffset.y);
        // サイズ変更後にオフセットをセットし直す
        [((UIScrollView *)childeView) setContentOffset:CGPointMake(offset.x, offset.y)];
        NSLog(@"offset-new-y=%f", ((UIScrollView *)childeView).contentOffset.y);
    }
    // テーブルViewならセルの表示が綺麗になるようにリロードを掛けて置いてあげる
    if ([childeView isKindOfClass:NSClassFromString(@"UITableView")]) {
        [((UITableView *)childeView) reloadData];
    }
    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
        // 段々表示位置を下げるアニメーション
        self.textAreaView.frame = textAreaViewLatestOriginFrame;
        childeView.frame = childeViewLatestOriginFrame;
    } completion:^(BOOL finished) {
        // 画面タッチを無効に
        tapGesture.enabled = NO;
        // 最後の表示キーボードの高さを0にリセット
        latestKeyboardHeight = 0.0f;
        // 各種UIの表示位置を初期位置に
        childeView.frame = childeViewLatestOriginFrame;
        self.textAreaView.frame = textAreaViewLatestOriginFrame;
        // スクロールコンテンツのオフセットを元の位置に戻してあげる
        if (0 < offset.y){
            [((UIScrollView *)childeView) setContentOffset:CGPointMake(offset.x, offset.y)];
        }
    }];
}


#pragma mark UITextView Delegate

/* 編集の開始 */
-(BOOL)textViewShouldBeginEditing:(UITextView*)argTextView
{
    // ローカル通知を登録する
    // キーボード表示通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // キーボード非表示通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // プレースホルダー破棄判定
    if (NO == placeHolderHidden){
        // プレースホルダーの場合はテキストをクリア
        placeHolderHidden = YES;
        argTextView.text = @"";
        argTextView.textColor = textViewFontColor;
    }
    // テキストエリアサイズのチェック
    [self textView:argTextView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@""];
    return YES;
}

/* 編集の終了 */
-(BOOL)textViewShouldEndEditing:(UITextView*)argTextView
{
    NSLog(@"nowText=%@", argTextView.text);
    // プレースホルダー復帰判定
    if (YES == placeHolderHidden && 0 == argTextView.text.length){
        placeHolderHidden = NO;
        argTextView.text = placeHolder;
        argTextView.textColor = PLACEHOLDER_FONT_COLOR;
    }
    return YES;
}

/* 編集中の入力値変更 */
- (BOOL)textView:(UITextView *)argTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // プレースホルダーの破棄判定
    if (NO == placeHolderHidden) {
        placeHolderHidden = YES;
        argTextView.text = @"";
        argTextView.textColor = textViewFontColor;
    }

    // 入力済みのテキストを取得
    NSMutableString *str = [argTextView.text mutableCopy];

    // 入力途中のバックスペース判定
    if (0 == text.length && 0 < latestRange.location && 1 < range.length && latestRange.location == range.location + range.length - 1) {
        // バックスペースレンジに変更
        range = NSMakeRange(latestRange.location -1, 1);
    }
    
    // 入力済みのテキストと入力が行われた(行われる)テキストを結合
    [str replaceCharactersInRange:range withString:text];

    // 行数判定
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : argTextView.font}];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentLeft;
    CGRect commentRect = [commentString boundingRectWithSize:CGSizeMake(argTextView.frame.size.width - 10, argTextView.frame.size.height * maxInputLength) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];

    if (onelineTextHeight * 2.5f < commentRect.size.height) {
        // テキストエリアを3行に拡大
        self.textAreaView.frame = CGRectMake(textAreaViewOriginFrame.origin.x, textAreaViewOriginFrame.origin.y - latestKeyboardHeight - textViewHeight * 1.5f, textAreaViewOriginFrame.size.width, textViewHeight * 2.5f + ((textAreaHeight - textViewHeight) / 2.0f) * 2.0f);
        if (nil != textAreaBGView){
            textAreaBGView.frame = CGRectMake(textAreaBGView.frame.origin.x, textAreaBGView.frame.origin.y, textAreaBGView.frame.size.width, self.textAreaView.frame.size.height);
        }
        // XXX フレームサイズを一旦作る！この前にsizeToFitは絶対ダメ！
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textViewHeight * 2.5f);
        textView.scrollEnabled = YES;
        // XXX 一旦とっとく！
        CGRect frame = textView.frame;
        // XXX 一旦Fitさせる！
        [textView sizeToFit];
        // XXX ホントにframeを変更！
        textView.frame = frame;
        // ボタンの位置を移動
        if (nil != leftBtnBlock) {
            leftBtn.frame = CGRectMake(leftBtn.frame.origin.x, (self.textAreaView.frame.size.height - textAreaHeight) + (textAreaHeight - leftBtn.frame.size.height) / 2.0f, leftBtn.frame.size.width, leftBtn.frame.size.height);
        }
        if (nil != rightBtnBlock) {
            rightBtn.frame = CGRectMake(rightBtn.frame.origin.x, (self.textAreaView.frame.size.height - textAreaHeight) + (textAreaHeight - rightBtn.frame.size.height) / 2.0f, rightBtn.frame.size.width, rightBtn.frame.size.height);
        }
        // テキストエリアのオリジナルフレームサイズを変更する
        textAreaViewLatestOriginFrame = CGRectMake(textAreaViewOriginFrame.origin.x, textAreaViewOriginFrame.origin.y - textViewHeight, textAreaViewOriginFrame.size.width, textViewHeight * 2.5f + ((textAreaHeight - textViewHeight) / 2.0f) * 2.0f);
        // コンテンツ領域のフレームサイズも変更
        childeView.frame = CGRectMake(childeViewOriginFrame.origin.x, childeViewOriginFrame.origin.y, childeViewOriginFrame.size.width, childeViewOriginFrame.size.height - latestKeyboardHeight - textViewHeight);
        // 次のRect
        CGRect nextRect = CGRectMake(childeViewOriginFrame.origin.x, childeViewOriginFrame.origin.y, childeViewOriginFrame.size.width, childeViewOriginFrame.size.height - textViewHeight);
        // コンテンツ領域内のオフセットの移動判定
        if ([childeView isKindOfClass:NSClassFromString(@"UIScrollView")] && !CGRectEqualToRect(childeViewLatestOriginFrame, nextRect)) {
            // スクロールコンテンツで且つRectが変わっていたらオフセットを自動で動かしてあげる
            [((UIScrollView *)childeView) setContentOffset:CGPointMake(((UIScrollView *)childeView).contentOffset.x, ((UIScrollView *)childeView).contentOffset.y + textViewHeight)];
        }
        // コンテンツ領域のオリジナルフレームサイズも変更しておく
        childeViewLatestOriginFrame = nextRect;
    }
    else if (onelineTextHeight * 1.5f < commentRect.size.height) {
        // テキストエリアを２行に拡大
        self.textAreaView.frame = CGRectMake(textAreaViewOriginFrame.origin.x, textAreaViewOriginFrame.origin.y - latestKeyboardHeight - textViewHeight * 0.8f, textAreaViewOriginFrame.size.width, textViewHeight * 1.8f + ((textAreaHeight - textViewHeight) / 2.0f) * 2.0f);
        if (nil != textAreaBGView){
            textAreaBGView.frame = CGRectMake(textAreaBGView.frame.origin.x, textAreaBGView.frame.origin.y, textAreaBGView.frame.size.width, self.textAreaView.frame.size.height);
        }
        // XXX フレームサイズを一旦作る！この前にsizeToFitは絶対ダメ！
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textViewHeight * 1.8f);
        textView.scrollEnabled = YES;
        // XXX 一旦とっとく！
        CGRect frame = textView.frame;
        // XXX 一旦Fitさせる！
        [textView sizeToFit];
        // XXX ホントにframeを変更！
        textView.frame = frame;
        // ボタンの位置を移動
        if (nil != leftBtnBlock) {
            leftBtn.frame = CGRectMake(leftBtn.frame.origin.x, (self.textAreaView.frame.size.height - textAreaHeight) + (textAreaHeight - leftBtn.frame.size.height) / 2.0f, leftBtn.frame.size.width, leftBtn.frame.size.height);
        }
        if (nil != rightBtnBlock) {
            rightBtn.frame = CGRectMake(rightBtn.frame.origin.x, (self.textAreaView.frame.size.height - textAreaHeight) + (textAreaHeight - rightBtn.frame.size.height) / 2.0f, rightBtn.frame.size.width, rightBtn.frame.size.height);
        }
        // テキストエリアのオリジナルフレームサイズを変更する
        textAreaViewLatestOriginFrame = CGRectMake(textAreaViewOriginFrame.origin.x, textAreaViewOriginFrame.origin.y - textViewHeight, textAreaViewOriginFrame.size.width, textViewHeight * 1.8f + ((textAreaHeight - textViewHeight) / 2.0f) * 2.0f);
        // コンテンツ領域のフレームサイズも変更
        childeView.frame = CGRectMake(childeViewOriginFrame.origin.x, childeViewOriginFrame.origin.y, childeViewOriginFrame.size.width, childeViewOriginFrame.size.height - latestKeyboardHeight - textViewHeight);
        // 次のRect
        CGRect nextRect = CGRectMake(childeViewOriginFrame.origin.x, childeViewOriginFrame.origin.y, childeViewOriginFrame.size.width, childeViewOriginFrame.size.height - textViewHeight);
        // コンテンツ領域内のオフセットの移動判定
        if ([childeView isKindOfClass:NSClassFromString(@"UIScrollView")] && !CGRectEqualToRect(childeViewLatestOriginFrame, nextRect)) {
            // スクロールコンテンツで且つRectが変わっていたらオフセットを自動で動かしてあげる
            [((UIScrollView *)childeView) setContentOffset:CGPointMake(((UIScrollView *)childeView).contentOffset.x, ((UIScrollView *)childeView).contentOffset.y + textViewHeight)];
        }
        // コンテンツ領域のオリジナルフレームサイズも変更しておく
        childeViewLatestOriginFrame = nextRect;
    }
    else{
        // テキストエリアを1行に戻す
        self.textAreaView.frame = CGRectMake(textAreaViewOriginFrame.origin.x, textAreaViewOriginFrame.origin.y - latestKeyboardHeight, textAreaViewOriginFrame.size.width, textAreaViewOriginFrame.size.height);
        if (nil != textAreaBGView){
            textAreaBGView.frame = CGRectMake(textAreaBGView.frame.origin.x, textAreaBGView.frame.origin.y, textAreaBGView.frame.size.width, self.textAreaView.frame.size.height);
        }
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textViewHeight);
        // ボタンの位置を移動
        if (nil != leftBtnBlock) {
            leftBtn.frame = CGRectMake(leftBtn.frame.origin.x, (textAreaHeight - leftBtn.frame.size.height) / 2.0f, leftBtn.frame.size.width, leftBtn.frame.size.height);
        }
        if (nil != rightBtnBlock) {
            rightBtn.frame = CGRectMake(rightBtn.frame.origin.x, (textAreaHeight - rightBtn.frame.size.height) / 2.0f, rightBtn.frame.size.width, rightBtn.frame.size.height);
        }
        // テキストエリアのオリジナルフレームサイズを変更する
        textAreaViewLatestOriginFrame = textAreaViewOriginFrame;
        // コンテンツ領域内のオフセットの移動判定
        CGPoint offset = CGPointMake(-10000, -10000);
        if ([childeView isKindOfClass:NSClassFromString(@"UIScrollView")]) {
            offset = ((UIScrollView *)childeView).contentOffset;
        }
        // コンテンツ領域のフレームサイズも変更
        childeView.frame = CGRectMake(childeViewOriginFrame.origin.x, childeViewOriginFrame.origin.y, childeViewOriginFrame.size.width, childeViewOriginFrame.size.height  - latestKeyboardHeight);
        // コンテンツ領域内のオフセットの移動判定
        if (!CGRectEqualToRect(childeViewLatestOriginFrame, childeViewOriginFrame) && 0 < offset.y){
            // スクロールコンテンツで且つRectが変わっていたらオフセットを自動で動かしてあげる
            [((UIScrollView *)childeView) setContentOffset:CGPointMake(offset.x, offset.y - textViewHeight)];
            // テキストエリアを1ラインモードに変更
            textView.contentOffset = CGPointZero;
            textView.scrollEnabled = NO;
        }
        // コンテンツ領域のオリジナルフレームサイズも変更しておく
        childeViewLatestOriginFrame = childeViewOriginFrame;
    }

    // 入力テキストの保存
    if (YES == placeHolderHidden){
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:[NSString stringWithFormat:@"Default-message-%@", messageIdentifier]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // 文字数判定
    BOOL limitUnover = YES;
    if (0 < maxInputLength && [str length] > maxInputLength) {
        // 文字数オーバー
        limitUnover = NO;
    }
    if (nil != limitCheckBlock){
        // initの途中の場合は遅延実行
        if (NO == initialized){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self enabledRight:limitCheckBlock(limitUnover, [str length])];
            });
        }
        else {
            [self enabledRight:limitCheckBlock(limitUnover, [str length])];
        }
    }
    else {
        // 送信ボタンを押せなくする
        [self enabledRight:limitUnover];
    }

    // バックスペース判定用に以前のrangeを取っておく
    latestRange = range;

    return YES;
}


#pragma mark NSLayoutManager Delegate

// 行間の通知
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 1.0f;
}

@end
