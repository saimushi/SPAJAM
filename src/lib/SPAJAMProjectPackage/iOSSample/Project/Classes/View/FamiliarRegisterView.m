//
//  GodMyPageView.m
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "FamiliarRegisterView.h"

@implementation FamiliarRegisterView

@synthesize imageView;
@synthesize familiarNameTextView;
@synthesize familiarInfoTextView;

/* オーバーライド */
- (id)initWithFrame:(CGRect)argFrame WithDelegate:(id)delegate;
{
    self = [super initWithFrame:argFrame];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"bg_2.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    [self addSubview:background];

    //神様のイメージ
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(53, 75, 214, 240)];
    [self addSubview:imageView];
    
    //ファミリア名
    UILabel *familiarNameLabel = [[UILabel alloc] init];
    familiarNameLabel.frame = CGRectMake(110, 320, 100, 24);
    familiarNameLabel.textColor = RGBA(230, 197, 107, 1);
    familiarNameLabel.font = [UIFont boldSystemFontOfSize:15];
    familiarNameLabel.textAlignment = NSTextAlignmentCenter;
    familiarNameLabel.text = @"ファミリア名";
    [self addSubview:familiarNameLabel];
    
    UIImage *logo1Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo1 = [[UIImageView alloc] initWithImage:logo1Image];
    logo1.x = familiarNameLabel.x - logo1.width;
    logo1.y = familiarNameLabel.y + 6;
    [self addSubview:logo1];
    
    UIImage *logo2Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo2 = [[UIImageView alloc] initWithImage:logo2Image];
    logo2.x = familiarNameLabel.x + familiarNameLabel.width;
    logo2.y = familiarNameLabel.y + 6;
    [self addSubview:logo2];
    
    UIImage *familiarNameTextViewBackgroundImage = [UIImage imageNamed:@"form_small.png"];
    UIImageView *familiarNameTextViewBackground = [[UIImageView alloc] initWithImage:familiarNameTextViewBackgroundImage];
    familiarNameTextViewBackground.frame = CGRectMake(27.5, 350, familiarNameTextViewBackground.frame.size.width, familiarNameTextViewBackground.frame.size.height);
    [self addSubview:familiarNameTextViewBackground];
    
    familiarNameTextView = [[UITextView alloc] init];
    familiarNameTextView.frame = CGRectMake(35, 357, 250, 31.5);
    familiarNameTextView.editable = NO;
    familiarNameTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:familiarNameTextView];
    
    UIButton *familiarNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    familiarNameButton.frame = CGRectMake(35, 357, 250, 31.5);
    [familiarNameButton addTarget:delegate action:@selector(nameInput:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:familiarNameButton];
    
    UILabel *familiarInfoLabel = [[UILabel alloc] init];
    familiarInfoLabel.frame = CGRectMake(105, 400, 110, 24);
    familiarInfoLabel.textColor = RGBA(230, 197, 107, 1);
    familiarInfoLabel.font = [UIFont boldSystemFontOfSize:15];
    familiarInfoLabel.textAlignment = NSTextAlignmentCenter;
    familiarInfoLabel.text = @"ファミリア概要";
    [self addSubview:familiarInfoLabel];
    
    UIImage *logo3Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo3 = [[UIImageView alloc] initWithImage:logo3Image];
    logo3.x = familiarInfoLabel.x - logo1.width;
    logo3.y = familiarInfoLabel.y + 6;
    [self addSubview:logo3];
    
    UIImage *logo4Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo4 = [[UIImageView alloc] initWithImage:logo4Image];
    logo4.x = familiarInfoLabel.x + familiarInfoLabel.width;
    logo4.y = familiarInfoLabel.y + 6;
    [self addSubview:logo4];
    
    UIImage *familiarInfoTextViewBackgroundImage = [UIImage imageNamed:@"form_big.png"];
    UIImageView *familiarInfoTextViewBackground = [[UIImageView alloc] initWithImage:familiarInfoTextViewBackgroundImage];
    familiarInfoTextViewBackground.frame = CGRectMake(27.5, 430, familiarInfoTextViewBackground.frame.size.width, familiarInfoTextViewBackground.frame.size.height);
    [self addSubview:familiarInfoTextViewBackground];
    
    familiarInfoTextView = [[UITextView alloc] init];
    familiarInfoTextView.frame = CGRectMake(35, 437, 250, 115);
    familiarInfoTextView.editable = NO;
    familiarInfoTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:familiarInfoTextView];
    
    UIButton *familiarInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    familiarInfoButton.frame = CGRectMake(35, 437, 250, 115);
    [familiarInfoButton addTarget:delegate action:@selector(infoInput:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:familiarInfoButton];
    
    return self;
}

/* dummy */
- (void)nameInput:(id)sender{
}

/* dummy */
- (void)infoInput:(id)sender{
}

@end
