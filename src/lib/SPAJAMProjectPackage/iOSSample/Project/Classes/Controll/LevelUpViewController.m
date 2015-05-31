//
//  LevelUpViewController.m
//  Project
//
//  Created by n00886 on 2015/05/31.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "LevelUpViewController.h"
#import "TopViewController.h"

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    imageView.image = [UIImage imageNamed:@"vlcsnap-28.png"];
    [self.view addSubview:imageView];
    
    // アニメーション用画像を配列にセット
    NSMutableArray *imageList = [NSMutableArray array];
    for (int i = 1; i < 28; i++) {
        NSString *imagePath = [NSString stringWithFormat:@"vlcsnap-%d.png", i];
        UIImage *image = [UIImage imageNamed:imagePath];
        [imageList addObject:image];
    }
    
    // アニメーション用画像をセット
    imageView.animationImages = imageList;
    
    // アニメーションの速度
    imageView.animationDuration = 10;
    
    // アニメーションのリピート回数
    imageView.animationRepeatCount = 1;
    
    // アニメーション実行
    [imageView startAnimating];
    
    UIView *touchView = [[UIView alloc]init];
    touchView.frame = CGRectMake(0, 0, 320, 568);
    touchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:touchView];
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchViewTapped:)];
    [touchView addGestureRecognizer:tapGesture];
}

- (void)touchViewTapped:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        // XXX ビーコンの待機状態とか変える？？
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end