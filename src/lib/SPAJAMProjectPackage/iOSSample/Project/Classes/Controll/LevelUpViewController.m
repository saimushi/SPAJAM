//
//  LevelUpViewController.m
//  Project
//
//  Created by n00886 on 2015/05/31.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "LevelUpViewController.h"

@interface LevelUpViewController ()
{
    // Private
}
@end

@implementation LevelUpViewController

- (id)init
{
    self = [super init];
    if(self != nil){
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    imageView.image = [UIImage imageNamed:@"vlcsnap-22.png"];
    [self.view addSubview:imageView];
    
    // アニメーション用画像を配列にセット
    NSMutableArray *imageList = [NSMutableArray array];
    for (int i = 1; i < 22; i++) {
        NSString *imagePath = [NSString stringWithFormat:@"vlcsnap-%d.png", i];
        UIImage *image = [UIImage imageNamed:imagePath];
        [imageList addObject:image];
    }
    
    // アニメーション用画像をセット
    imageView.animationImages = imageList;
    
    // アニメーションの速度
    imageView.animationDuration = 2.5;
    
    // アニメーションのリピート回数
    imageView.animationRepeatCount = 1;
    
    // アニメーション実行
    [imageView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end