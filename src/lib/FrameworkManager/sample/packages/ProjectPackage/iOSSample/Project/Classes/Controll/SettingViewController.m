//
//  SettingViewController.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
{
    // Private
}
@end

@implementation SettingViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        // デフォルトのスクリーン名をセット
        screenName = @"設定";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
