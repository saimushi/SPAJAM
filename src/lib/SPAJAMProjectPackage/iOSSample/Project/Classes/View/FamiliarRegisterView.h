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
}

@property (strong, nonatomic) UIImageView *imageView;

- (id)initWithFrame:(CGRect)argFrame WithDelegate:(id)delegate;

@end
