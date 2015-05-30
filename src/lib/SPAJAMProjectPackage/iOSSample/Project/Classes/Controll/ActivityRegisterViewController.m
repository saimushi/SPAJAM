//
//  ActivityRegisterViewController.m
//  Project
//
//  Created by n00886 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "ActivityRegisterViewController.h"
#import "ActivityModel.h"

@interface ActivityRegisterViewController ()
{
    // Private
    UITextView *activityTextView;
    UITextView *timeTextView;
}
@end

@implementation ActivityRegisterViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        // デフォルトのスクリーン名をセット
        screenName = @"モンスター討伐記録";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"bg_3.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.view addSubview:background];
    
    UILabel *activityLabel = [[UILabel alloc] init];
    activityLabel.frame = CGRectMake(85, 85, 150, 24);
    activityLabel.textColor = RGBA(230, 197, 107, 1);
    activityLabel.font = [UIFont boldSystemFontOfSize:15];
    activityLabel.textAlignment = NSTextAlignmentCenter;
    activityLabel.text = @"モンスター討伐概要";
    [self.view addSubview:activityLabel];
    
    UIImage *logo1Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo1 = [[UIImageView alloc] initWithImage:logo1Image];
    logo1.x = activityLabel.x - logo1.width;
    logo1.y = activityLabel.y + 6;
    [self.view addSubview:logo1];
    
    UIImage *logo2Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo2 = [[UIImageView alloc] initWithImage:logo2Image];
    logo2.x = activityLabel.x + activityLabel.width;
    logo2.y = activityLabel.y + 6;
    [self.view addSubview:logo2];
    
    UIImage *activityTextViewBackgroundImage = [UIImage imageNamed:@"form_big.png"];
    UIImageView *activityTextViewBackground = [[UIImageView alloc] initWithImage:activityTextViewBackgroundImage];
    activityTextViewBackground.frame = CGRectMake(27.5, 115, activityTextViewBackground.frame.size.width, activityTextViewBackground.frame.size.height);
    [self.view addSubview:activityTextViewBackground];
    
    activityTextView = [[UITextView alloc] init];
    activityTextView.frame = CGRectMake(35, 122, 250, 115);
    activityTextView.editable = NO;
    activityTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:activityTextView];
    
    UIButton *activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    activityButton.frame = CGRectMake(35, 122, 250, 115);
    [activityButton addTarget:self action:@selector(showActivityInput:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:activityButton];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(100, 260, 120, 24);
    timeLabel.textColor = RGBA(230, 197, 107, 1);
    timeLabel.font = [UIFont boldSystemFontOfSize:15];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text = @"討伐までの時間";
    [self.view addSubview:timeLabel];
    
    UIImage *logo3Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo3 = [[UIImageView alloc] initWithImage:logo3Image];
    logo3.x = timeLabel.x - logo1.width;
    logo3.y = timeLabel.y + 6;
    [self.view addSubview:logo3];
    
    UIImage *logo4Image = [UIImage imageNamed:@"icon_leaf.png"];
    UIImageView *logo4 = [[UIImageView alloc] initWithImage:logo4Image];
    logo4.x = timeLabel.x + timeLabel.width;
    logo4.y = timeLabel.y + 6;
    [self.view addSubview:logo4];
    
    UIImage *timeTextViewBackgroundImage = [UIImage imageNamed:@"form_small.png"];
    UIImageView *timeTextViewBackground = [[UIImageView alloc] initWithImage:timeTextViewBackgroundImage];
    timeTextViewBackground.frame = CGRectMake(27.5, 290, timeTextViewBackground.frame.size.width, timeTextViewBackground.frame.size.height);
    [self.view addSubview:timeTextViewBackground];
    
    timeTextView = [[UITextView alloc] init];
    timeTextView.frame = CGRectMake(35, 297, 230, 31.5);
    timeTextView.editable = NO;
    timeTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:timeTextView];
    
    UIButton *timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timeButton.frame = CGRectMake(35, 297, 250, 31.5);
    [timeButton addTarget:self action:@selector(showTimeInput:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:timeButton];
    
    UILabel *hourLabel = [[UILabel alloc] init];
    hourLabel.frame = CGRectMake(275, 301, 20, 24);
    hourLabel.textColor = [UIColor blackColor];
    hourLabel.alpha = 0.6;
    hourLabel.font = [UIFont boldSystemFontOfSize:15];
    hourLabel.textAlignment = NSTextAlignmentLeft;
    hourLabel.text = @"h";
    [self.view addSubview:hourLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 追加ボタンの追加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"追加" style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * データ追加
 */
- (void)addData
{
    ActivityModel *activityModel = [[ActivityModel alloc] init];
    [activityModel setUser_id:APPDELEGATE.ownerID];
    [activityModel setFamiliar_id:APPDELEGATE.familiarID];
    [activityModel setLog:activityTextView.text];
    [activityModel setTime:timeTextView.text];
    [activityModel save:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if(YES == success){
            // マイページ
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            // エラー処理をするならココ
        }
    }];
}

- (void)showActivityInput:(id)sender
{
    FreewordInputViewController *freewordInputViewController = [[FreewordInputViewController alloc] init:@"" :activityTextView.text :3 :0 :150 :self :@selector(updateActivityText:)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:freewordInputViewController] animated:YES completion:nil];
}

- (void)showTimeInput:(id)sender
{
    FreewordInputViewController *freewordInputViewController = [[FreewordInputViewController alloc] init:@"" :timeTextView.text :1 :0 :5 :self :@selector(updateTimeTextView:)];
    [freewordInputViewController setKeyboardType:UIKeyboardTypeNumberPad];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:freewordInputViewController] animated:YES completion:nil];
}


- (void)updateActivityText:(NSString *)argText
{
    activityTextView.text = argText;
    
    if (0 < activityTextView.text.length && 0 < timeTextView.text.length) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)updateTimeTextView:(NSString *)argText
{
    timeTextView.text = argText;
    
    if (0 < activityTextView.text.length && 0 < timeTextView.text.length) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

@end