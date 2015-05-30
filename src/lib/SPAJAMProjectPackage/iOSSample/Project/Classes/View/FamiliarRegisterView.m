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
    return self;
}

@end
