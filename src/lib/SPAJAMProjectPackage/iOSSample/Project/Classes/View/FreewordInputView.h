//
//  FreewordInputView.h
//  GMatch
//
//  Created by saimushi on 2014/10/03.
//

#import "common.h"

@interface FreewordInputView : UIView
{
    UITextField *onelineField;
    UITextView *multilineField;
    UIButton *saveBtn;
    UILabel *errorLabel;
}

@property (strong, nonatomic) UITextField *onelineField;
@property (strong, nonatomic) UITextView *multilineField;
@property (strong, nonatomic) UIButton *saveBtn;
@property (strong, nonatomic) UILabel *errorLabel;

- (id)initWithFrame:(CGRect)argFrame :(NSString *)argInputString :(int)argNumberOfLine :(id)argTarget;

@end
