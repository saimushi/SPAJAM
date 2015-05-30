//
//  FreewordInputView.m
//  GMatch
//
//  Created by saimushi on 2014/09/21.
//

#import "FreewordInputView.h"
#import "FreewordInputViewController.h"

@implementation FreewordInputView
{
    UIView *btnAreaView;
}

@synthesize onelineField;
@synthesize multilineField;
@synthesize saveBtn;
@synthesize errorLabel;

- (id)initWithFrame:(CGRect)argFrame :(NSString *)argInputString :(int)argNumberOfLine :(FreewordInputViewController *)argTarget;
{
    self = [super initWithFrame:argFrame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 209)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];

        if(1 == argNumberOfLine){
            // 一行の時はUITextFieldに変更
            self.onelineField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, 30)];
            self.onelineField.text = argInputString;
            self.onelineField.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
            self.onelineField.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            self.onelineField.textAlignment = NSTextAlignmentLeft;
            self.onelineField.returnKeyType = UIReturnKeyDone;
            self.onelineField.clearsOnBeginEditing = NO;
            self.onelineField.delegate = argTarget;
            [self.onelineField becomeFirstResponder];
            [self addSubview:self.onelineField];
        }
        else {
            self.multilineField = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, self.height - 209 - 50)];
            self.multilineField.text = argInputString;
            self.multilineField.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
            self.multilineField.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            self.multilineField.backgroundColor = [UIColor clearColor];
            self.multilineField.textAlignment = NSTextAlignmentLeft;
            self.multilineField.editable = YES;
            self.multilineField.delegate = argTarget;
            NSRange range;
            range.location = 0;
            range.length = 0;
            self.multilineField.selectedRange = range;
            [self.multilineField becomeFirstResponder];
            [self addSubview:self.multilineField];
        }
        
        btnAreaView = [[UIView alloc] init];
        btnAreaView.x = 0;
        btnAreaView.y = self.height - 209 - 40;
        btnAreaView.width = self.width;
        btnAreaView.height = 80;
        btnAreaView.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];

        // エラーメッセージ
        self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 200, 12)];
        self.errorLabel.text = @"文字数がオーバーしています";
        self.errorLabel.textColor = [UIColor colorWithRed:0.97 green:0.27 blue:0.27 alpha:1.0];
        self.errorLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        self.errorLabel.backgroundColor = [UIColor clearColor];
        self.errorLabel.textAlignment = NSTextAlignmentLeft;
        self.errorLabel.hidden = YES;
        [btnAreaView addSubview:self.errorLabel];

        // 保存ボタン
        //UIImage* saveBtnImage = [UIImage imageNamed:@"btn_save"];
        self.saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[self.saveBtn setBackgroundImage:saveBtnImage forState:UIControlStateNormal];
        //self.saveBtn.width = saveBtnImage.size.width;
        //self.saveBtn.height = saveBtnImage.size.height;
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        self.saveBtn.width = 65;
        self.saveBtn.height = 35;
        self.saveBtn.x = btnAreaView.width - self.saveBtn.width - 10;
        self.saveBtn.y = 5;
        self.saveBtn.enabled = NO;
        [self.saveBtn addTarget:argTarget action:@selector(onPushComplteButton:) forControlEvents:UIControlEventTouchUpInside];
        [btnAreaView addSubview:self.saveBtn];

        [self addSubview:btnAreaView];
    }
    return self;
}

@end
