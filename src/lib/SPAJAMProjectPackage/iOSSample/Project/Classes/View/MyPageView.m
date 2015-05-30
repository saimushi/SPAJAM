//
//  GodMyPageView.m
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "MyPageView.h"
#import "UserModel.h"
#import "FamiliarModel.h"

@implementation MyPageView

/* オーバーライド */
- (id)initWithFrame:(CGRect)argFrame WithTopViewController:(TopViewController*)argTopViewController;
{
    self = [super initWithFrame:argFrame];
    if (self) {
        
        // 神さまの画像
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dummy_god"]];
        imageView.width  = 320;
        imageView.height = 360;
        imageView.x = 0;
        imageView.y = 0;
        [self addSubview:imageView];
        
        // 経験値とかを表示する
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 260, 320, 80)];
        [label setText:@"このへんに経験値とか表示する...?"];
        [self addSubview:label];
        
    }
    return self;
}

@end
