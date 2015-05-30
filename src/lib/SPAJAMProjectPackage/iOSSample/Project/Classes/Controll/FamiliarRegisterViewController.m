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
{
    FamiliarRegisterView *view;
}
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
    view = [[FamiliarRegisterView alloc] initWithFrame:CGRectMake(0, 30, self.view.width, self.view.height - self.navigationController.navigationBar.frame.size.height - 64 - 5) WithDelegate:self];
    [self.view addSubview:view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}

- (void)nameInput:(id)sender{
    FreewordInputViewController *freewordInputViewController = [[FreewordInputViewController alloc] init:@"" :view.familiarNameInputLabel.text :1 :0 :10 :self :@selector(updateNameText:)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:freewordInputViewController] animated:YES completion:nil];
}

- (void)infoInput:(id)sender{
    FreewordInputViewController *freewordInputViewController = [[FreewordInputViewController alloc] init:@"" :view.familiarInfoInputLabel.text :1 :0 :30 :self :@selector(updateInfoText:)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:freewordInputViewController] animated:YES completion:nil];
}

- (void)updateNameText:(NSString *)argText
{
    view.familiarNameInputLabel.text = argText;
    
    if (0 < view.familiarNameInputLabel.text.length && 0 < view.familiarNameInputLabel.text.length) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)updateInfoText:(NSString *)argText
{
    view.familiarInfoInputLabel.text = argText;
    
    if (0 < view.familiarNameInputLabel.text.length && 0 < view.familiarNameInputLabel.text.length) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }

}
@end
