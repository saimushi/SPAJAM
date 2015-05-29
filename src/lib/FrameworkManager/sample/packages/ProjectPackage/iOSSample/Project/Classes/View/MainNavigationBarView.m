//
//  MainNavigationBarView.m
//  GMatch
//
//  Created by saimushi on 2014/09/19.
//

#import "MainNavigationBarView.h"

@implementation MainNavigationBarView
{
    UILabel *titleLabel;
    UIImageView *logoImageView;
}

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title;
{
    self = [self initWithFrame:frame];
    if(self){
        self.tag = MainNavigationBarViewTag;
        UIView *view = (UIView *)[self initWithFrame:frame];
        view.y = -20;
        view.height += 20;
        view.backgroundColor = [UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0];
        titleLabel = [[UILabel alloc] init];
        titleLabel.frame = view.frame;
        titleLabel.width -= 50;
        titleLabel.height -= 20;
        titleLabel.center = self.center;
        titleLabel.y = 20;
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel setFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:navibar_title_size]];
        titleLabel.minimumScaleFactor = 1.0f;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        [titleLabel setAdjustsFontSizeToFitWidth:YES];
        [view insertSubview:titleLabel atIndex:1];
        
        logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_log"]];
        logoImageView.center = self.center;
        logoImageView.y = (self.height - 20 - logoImageView.height)/2 + 20;
        logoImageView.hidden = YES;
        [view insertSubview:logoImageView atIndex:1];
        
        view.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setTile:(NSString *)title;
{
    logoImageView.hidden = YES;
    titleLabel.hidden = NO;
    titleLabel.text = title;
}

- (void)setTile:(NSString *)title :(int)argFontSize;
{
    logoImageView.hidden = YES;
    titleLabel.hidden = NO;
    titleLabel.text = title;
    [titleLabel setFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:argFontSize]];
}

- (void)setLogo
{
    logoImageView.hidden = NO;
    titleLabel.hidden = YES;
}

@end
