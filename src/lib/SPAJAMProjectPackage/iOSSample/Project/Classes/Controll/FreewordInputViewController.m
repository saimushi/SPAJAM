//
//  FreewordInputViewController.m
//  GMatch
//
//  Created by saimushi on 2014/09/19.
//

#import "FreewordInputViewController.h"
#import "FreewordInputView.h"

@interface FreewordInputViewController ()
{
    FreewordInputView *inputView;
    NSString *title;
    NSString *inputString;
    int numberOfLine;
    int minLength;
    int maxLength;
    id target;
    SEL selector;
    BOOL isSecure;
    UIKeyboardType defaultkeyboardType;
}
@end

@implementation FreewordInputViewController

- (id)init:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector;
{
    self = [super init];
    if(self != nil){
        title = argTitle;
        inputString = argInputString;
        numberOfLine = argNumberOfLine;
        minLength = argMinLength;
        maxLength = argMaxLength;
        target = argTarget;
        selector = argSelector;
        isSecure = NO;
        defaultkeyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (id)initWithSecure:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector :(BOOL)argSecure
{
    self = [super init];
    if(self != nil){
        title = argTitle;
        inputString = argInputString;
        numberOfLine = argNumberOfLine;
        minLength = argMinLength;
        maxLength = argMaxLength;
        target = argTarget;
        selector = argSelector;
        isSecure = argSecure;
        defaultkeyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (id)init:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector :(UIKeyboardType)argKeyboardType;
{
    self = [super init];
    if(self != nil){
        title = argTitle;
        inputString = argInputString;
        numberOfLine = argNumberOfLine;
        minLength = argMinLength;
        maxLength = argMaxLength;
        target = argTarget;
        selector = argSelector;
        isSecure = NO;
        defaultkeyboardType = argKeyboardType;
    }
    return self;
}

- (id)initWithSecure:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector :(BOOL)argSecure :(UIKeyboardType)argKeyboardType;
{
    self = [super init];
    if(self != nil){
        title = argTitle;
        inputString = argInputString;
        numberOfLine = argNumberOfLine;
        minLength = argMinLength;
        maxLength = argMaxLength;
        target = argTarget;
        selector = argSelector;
        isSecure = argSecure;
        defaultkeyboardType = argKeyboardType;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    
    // ナビゲーションバーにタイトルViewをセット
    [self.navigationItem setTitle:title];
    // 閉じるボタン
    //[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_clause"] target:self action:@selector(onPushCloseButton:)]];
    UIImage *backgroundImage = [UIImage imageNamed:@"bg_header.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :RGBA(230, 197, 107, 1)}];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                target:self
                                                action:@selector(onPushCloseButton:)
                                                ]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    // 5.5インチHD対応
    if (400 < self.view.width){
        self.view.height -= 20;
    }
    // 4.7インチHD対応
    else if (320 < self.view.width){
        self.view.height -= 10;
    }
    inputView = [[FreewordInputView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.width, self.view.height - self.navigationController.navigationBar.frame.size.height - 64) :inputString :numberOfLine :self];
    inputView.onelineField.secureTextEntry = isSecure;
    inputView.multilineField.secureTextEntry = isSecure;
    inputView.onelineField.keyboardType = defaultkeyboardType;
    inputView.multilineField.keyboardType = defaultkeyboardType;
    [self.view addSubview:inputView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/* 描画(再描画)が走る直前に呼ばれるので、その度に処理したい事を追加 */
- (void)viewWillAppear:(BOOL)animated
{
    // ナビゲーションバーのボタンはナビゲーションして戻ってくるとけされてしまったままになるので、ここで描画毎に追加する
    // SystemItemCancelはローカライズしてくれない？
    if(minLength <= inputString.length && maxLength >= inputString.length){
        inputView.saveBtn.enabled = YES;
        inputView.errorLabel.hidden = YES;
    }
    else {
        inputView.saveBtn.enabled = NO;
        if(maxLength < inputString.length){
            inputView.errorLabel.hidden = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setKeyboardType:(UIKeyboardType)argKeyboardType;
{
    defaultkeyboardType = argKeyboardType;
    inputView.onelineField.keyboardType = defaultkeyboardType;
    inputView.multilineField.keyboardType = defaultkeyboardType;
}

- (void)onPushComplteButton:(id)sender;
{
    if(1 == numberOfLine){
        inputString = inputView.onelineField.text;
    }
    else {
        inputString = inputView.multilineField.text;
    }
    [self onPushCloseButton:sender];
}

- (void)onPushCloseButton:(id)sender
{
    if(1 == numberOfLine){
        [inputView.onelineField resignFirstResponder];
    }
    else {
        [inputView.multilineField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([target respondsToSelector:selector]) {
            // dismmisモーダルアニメーション後
            [target performSelector:selector withObject:inputString afterDelay:0.0f];
        }
    }];
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 実際に UITextView に入力されている文字数
    int textLength;
    textLength = ((int)(textField.text.length - range.length)) + (int)string.length;
    NSLog(@"Count : %d", textLength);

    if(minLength <= textLength && maxLength >= textLength){
        inputView.saveBtn.enabled = YES;
        inputView.errorLabel.hidden = YES;
    }
    else {
        inputView.saveBtn.enabled = NO;
        if(maxLength < textLength){
            inputView.errorLabel.hidden = NO;
        }
    }
    return YES;
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 実際に UITextView に入力されている文字数
    int textLength;
    textLength = ((int)(textView.text.length - range.length)) + (int)text.length;
    NSLog(@"Count : %d", textLength);

    if(minLength <= textLength && maxLength >= textLength){
        inputView.saveBtn.enabled = YES;
        inputView.errorLabel.hidden = YES;
    }
    else {
        inputView.saveBtn.enabled = NO;
        if(maxLength < textLength){
            inputView.errorLabel.hidden = NO;
        }
    }
    return YES;
}

@end
