//
//  FreewordInputViewController.h
//  GMatch
//
//  Created by saimushi on 2014/09/19.
//

#import "common.h"

@interface FreewordInputViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

- (id)init:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector;
- (id)initWithSecure:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector :(BOOL)argSecure;
- (id)init:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector :(UIKeyboardType)argKeyboardType;
- (id)initWithSecure:(NSString *)argTitle :(NSString *)argInputString :(int)argNumberOfLine :(int)argMinLength :(int)argMaxLength :(id)argTarget :(SEL)argSelector :(BOOL)argSecure :(UIKeyboardType)argKeyboardType;

- (void)setKeyboardType:(UIKeyboardType)argKeyboardType;
- (void)onPushComplteButton:(id)sender;

@end
