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
- (id)initWithFrame:(CGRect)argFrame WithTopViewController:(TopViewController*)argTopViewController :(BOOL)isGod;
{
    self = [super initWithFrame:argFrame];
    if (self) {
        
        // 神さまの画像
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 360)];
        [imageView hnk_setImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@/image/familiar%@.jpg", PROTOCOL, DOMAIN_NAME, URL_BASE, APPDELEGATE.familiarID]] placeholderImage:nil success:^(UIImage *image) {
            //
            NSLog(@"succ");
            imageView.image = image;
        } failure:^(NSError *error) {
            //
            NSLog(@"err");
        }];
        [self addSubview:imageView];
        
        if(!isGod){
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_button"]];
            bgImageView.x = 0;
            bgImageView.y = imageView.y+imageView.height;
            [self addSubview:bgImageView];
            
            UIImage  *familliaImage = [UIImage imageNamed:@"b_familia_list"];
            UIButton *famillia = [UIButton buttonWithType:UIButtonTypeCustom];
            [famillia setBackgroundImage:familliaImage forState:UIControlStateNormal];
            famillia.width = familliaImage.size.width;
            famillia.height = familliaImage.size.height;
            famillia.x = 30;
            famillia.y = imageView.y+imageView.height + 2;
            famillia.backgroundColor = [UIColor clearColor];
            [famillia addTarget:argTopViewController action:@selector(onTapFamiliarListButton:)
               forControlEvents:UIControlEventTouchDown];
            [self addSubview:famillia];
            
            UIImage  *activityImage = [UIImage imageNamed:@"b_monster"];
            UIButton *activity = [UIButton buttonWithType:UIButtonTypeCustom];
            [activity setBackgroundImage:activityImage forState:UIControlStateNormal];
            activity.width = activityImage.size.width;
            activity.height = activityImage.size.height;
            activity.x = 30;
            activity.y = famillia.y + famillia.height + 2;
            activity.backgroundColor = [UIColor clearColor];
            [activity addTarget:argTopViewController action:@selector(onTapActivityRegisterButton:)
               forControlEvents:UIControlEventTouchDown];
            [self addSubview:activity];
        }
        
    }
    return self;
}

/* dummy */
- (void)onTapFamiliarListButton:(id)sender{
}

/* dummy */
- (void)onTapActivityRegisterButton:(id)sender{
}

@end
