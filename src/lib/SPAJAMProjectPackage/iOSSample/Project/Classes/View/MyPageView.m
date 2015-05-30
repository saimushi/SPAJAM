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
//            UIButton *famillia = [[UIButton alloc]initWithFrame:CGRectMake(10, 465, 100, 50)];
//            [famillia setTitle:@"一覧（仮）" forState:UIControlStateNormal];
//            famillia.backgroundColor = [UIColor blackColor];
//            [famillia addTarget:self action:@selector(onTapFamiliarListButton:)
//               forControlEvents:UIControlEventTouchDown];
//            [self addSubview:famillia];
//            
//            UIButton *activity = [[UIButton alloc]initWithFrame:CGRectMake(115, 465, 150, 50)];
//            [activity setTitle:@"モンスター（仮）" forState:UIControlStateNormal];
//            activity.backgroundColor = [UIColor blackColor];
//            [activity addTarget:self action:@selector(onTapActivityRegisterButton:)
//               forControlEvents:UIControlEventTouchDown];
//            [self addSubview:activity];
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
