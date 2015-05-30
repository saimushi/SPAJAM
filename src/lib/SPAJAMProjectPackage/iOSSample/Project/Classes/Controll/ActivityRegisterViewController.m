//
//  ActivityRegisterViewController.m
//  Project
//
//  Created by n00886 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "ActivityRegisterViewController.h"

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
        screenName = @"モンスター討伐記録登録";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UILabel *activityLabel = [[UILabel alloc] init];
    activityLabel.frame = CGRectMake(10, 15, 300, 24);
    activityLabel.textColor = [UIColor blackColor];
    activityLabel.font = [UIFont fontWithName:@"AppleGothic" size:14];
    activityLabel.textAlignment = NSTextAlignmentLeft;
    activityLabel.text = @"モンスター討伐記録";
    [self.view addSubview:activityLabel];
    
    activityTextView = [[UITextView alloc] init];
    activityTextView.frame = CGRectMake(10, 40, 300, 100);
    activityTextView.editable = NO;
    activityTextView.backgroundColor = [UIColor redColor];
    [self.view addSubview:activityTextView];
    
    UIButton *activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    activityButton.frame = CGRectMake(10, 40, 300, 100);
    [activityButton addTarget:self action:@selector(showActivityInput:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:activityButton];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(10, 155, 300, 24);
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.font = [UIFont fontWithName:@"AppleGothic" size:14];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.text = @"探索時間";
    [self.view addSubview:timeLabel];
    
    timeTextView = [[UITextView alloc] init];
    timeTextView.frame = CGRectMake(10, 180, 240, 40);
    timeTextView.editable = NO;
    timeTextView.backgroundColor = [UIColor redColor];
    [self.view addSubview:timeTextView];
    
    UIButton *timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timeButton.frame = CGRectMake(10, 180, 240, 40);
    [timeButton addTarget:self action:@selector(showTimeInput:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:timeButton];
    
    UILabel *hourLabel = [[UILabel alloc] init];
    hourLabel.frame = CGRectMake(250, 200, 20, 24);
    hourLabel.textColor = [UIColor blackColor];
    hourLabel.font = [UIFont fontWithName:@"AppleGothic" size:14];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD", @"追加") style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
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
    NSLog(@"add");
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