//
//  MainNavigationBarView.h
//  GMatch
//
//  Created by saimushi on 2014/09/19.
//

#import "common.h"
#define MainNavigationBarViewTag 999

@interface MainNavigationBarView : UIView

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title;
- (void)setTile:(NSString *)title;
- (void)setTile:(NSString *)title :(int)argFontSize;
- (void)setLogo;

@end
