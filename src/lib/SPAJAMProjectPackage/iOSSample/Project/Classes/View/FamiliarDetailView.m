//
//  GodMyPageView.m
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "GodMyPageView.h"

@implementation GodMyPageView

/* オーバーライド */
- (id)initWithFrame:(CGRect)argFrame WithDelegate:(id)delegate;
{
    self = [super initWithFrame:argFrame];
    if (self) {

        // テストボタン
        UIButton *button = [[UIButton alloc]init];
        button.frame = CGRectMake(0, 50, self.width, 50);
        button.backgroundColor = [UIColor blackColor];
        [button setTitle:@"start BLE" forState:UIControlStateNormal];
        [button addTarget:delegate
                action:@selector(onButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

@end
