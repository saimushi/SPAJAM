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
@synthesize familiarNameInputLabel;
@synthesize familiarInfoInputLabel;

/* オーバーライド */
- (id)initWithFrame:(CGRect)argFrame WithDelegate:(id)delegate;
{
    self = [super initWithFrame:argFrame];
    imageView = [[UIImageView alloc] init];
    imageView.width = 320;
    imageView.height = 360;
    imageView.x = (self.width - imageView.width) / 2.0f;
    imageView.y = 55;
    [self addSubview:imageView];
    
    //神様のイメージ
    UIImageView *godImageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 240, 270)];
    [self addSubview:godImageView];
    
    //ファミリア名
    UILabel *familiarName = [[UILabel alloc]initWithFrame:CGRectMake(40, 305, 240, 24)];
    familiarName.text = @"ファミリア名";
    familiarName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [self addSubview:familiarName];
    
    UIView *familiarNameFrame = [[UIView alloc]initWithFrame:CGRectMake(40, 329, 240, 40)];
    [[familiarNameFrame layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[familiarNameFrame layer] setBorderWidth:2.0];
    [familiarNameFrame layer].cornerRadius = 5.0f;
    [self addSubview:familiarNameFrame];
    
    UIButton *familiarNamebutton = [[UIButton alloc]init];
    familiarNamebutton.frame = CGRectMake(40, 329, 240, 40);
    familiarNamebutton.backgroundColor = [UIColor clearColor];
    [familiarNamebutton addTarget:delegate
               action:@selector(nameInput:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:familiarNamebutton];
    
    familiarNameInputLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 329, 230, 40)];
    familiarNameInputLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [self addSubview:familiarNameInputLabel];
    //概要
    UILabel *familiarInfo = [[UILabel alloc]initWithFrame:CGRectMake(40, 379, 240, 24)];
    familiarInfo.text = @"概要";
    familiarInfo.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [self addSubview:familiarInfo];
    
    UIView *familiarInfoFrame = [[UIView alloc]initWithFrame:CGRectMake(39, 399, 240, 80)];
    [[familiarInfoFrame layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[familiarInfoFrame layer] setBorderWidth:2.0];
    [familiarInfoFrame layer].cornerRadius = 5.0f;
    [self addSubview:familiarInfoFrame];
    
    UIButton *familiarInfobutton = [[UIButton alloc]init];
    familiarInfobutton.frame = CGRectMake(40, 399, 240, 80);
    familiarInfobutton.backgroundColor = [UIColor clearColor];
    [familiarInfobutton addTarget:delegate
                           action:@selector(infoInput:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:familiarInfobutton];
    
    familiarInfoInputLabel = [[UILabel alloc]initWithFrame:CGRectMake(44, 399, 230, 80)];
    familiarInfoInputLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [self addSubview:familiarInfoInputLabel];
    return self;
}

@end
