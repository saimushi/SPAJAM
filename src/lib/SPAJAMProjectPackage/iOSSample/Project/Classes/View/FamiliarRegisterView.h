//
//  GodMyPageView.h
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "common.h"

@interface FamiliarRegisterView : UIView
{
    UIImageView *imageView;
    UITextView *familiarNameTextView;
    UITextView *familiarInfoTextView;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *familiarNameTextView;
@property (strong, nonatomic) UITextView *familiarInfoTextView;

- (id)initWithFrame:(CGRect)argFrame WithDelegate:(id)delegate;

@end
