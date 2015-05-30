//
//  GodMyPageViewController.m
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "FamiliarRegisterViewController.h"
#import "FamiliarRegisterView.h"

@interface FamiliarRegisterViewController ()
@end


@implementation FamiliarRegisterViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        // デフォルトのスクリーン名をセット
        screenName = @"ファミリア登録";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    FamiliarRegisterView *view = [[FamiliarRegisterView alloc] initWithFrame:CGRectMake(0, 30, self.view.width, self.view.height - self.navigationController.navigationBar.frame.size.height - 64 - 5) WithDelegate:self];
    [self.view addSubview:view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}
@end
