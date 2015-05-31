//
//  TopViewController.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "FamiliarRegisterViewController.h"
#import "FamiliarRegisterView.h"
#import "MCropImageView.h"
#import "FamiliarModel.h"
#import "UserModel.h"

@interface FamiliarRegisterViewController ()
{
    // Private
    FamiliarRegisterView *view;
    UIImage *hestiaImage;
    UIImage *editedHestiaImage;
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

- (id)initWithImage:(UIImage *)argImage;
{
    self = [self init];
    hestiaImage = argImage;
    return self;
}

- (void)loadView
{
    [super loadView];
    view = [[FamiliarRegisterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) WithDelegate:self];
    [self.view addSubview:view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 画像がプレビューできるように計算
    UIImageView *hestiaLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hestia_line"]];
    hestiaLineImageView.width = 320;
    hestiaLineImageView.x = (APPDELEGATE.window.frame.size.width - hestiaLineImageView.width) / 2.0f;
    hestiaLineImageView.y = (APPDELEGATE.window.frame.size.height - hestiaLineImageView.height) / 2.0f;
    MCropImageView *cropImageView = [[MCropImageView alloc] initWithFrame:APPDELEGATE.window.frame :hestiaImage :320 :360 :YES :hestiaLineImageView :^(MCropImageView *mcropImageView, BOOL finished, UIImage *argImage) {
        if(YES == finished && nil != argImage && [argImage isKindOfClass:NSClassFromString(@"UIImage")]){
            editedHestiaImage = [self addHimo:argImage :hestiaLineImageView.image];
            [view.imageView setImage:editedHestiaImage];
        }
        else {
            // キャンセル
            [self.navigationController popViewControllerAnimated:NO];
        }
        [mcropImageView dissmiss:YES];
    }];
    [APPDELEGATE.window addSubview:cropImageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 追加ボタンの追加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"追加" style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
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
    FamiliarModel *familiarModel = [[FamiliarModel alloc] init];
    familiarModel.info = view.familiarInfoTextView.text;
    familiarModel.name = view.familiarNameTextView.text;
    familiarModel.familiar_count = [NSString stringWithFormat:@"%d", ([familiarModel.familiar_count intValue] + 1)];
    [familiarModel save:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        // 成功したら画像アップ
        if (success){
            [familiarModel saveImage:editedHestiaImage :^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
                if (success) {
                    [self performSelector:@selector(saveUserFamiliar:) withObject:familiarModel.ID afterDelay:0.5f];
                }
            }];
        }
    }];
}

- (void)saveUserFamiliar:(NSString *)argFamiliarID
{
    UserModel *userModel = [[UserModel alloc] init];
    userModel.familiar_id = argFamiliarID;
    [userModel save:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if (success) {
            // 成功したらファミリア一覧に戻る
            [(TopViewController*)APPDELEGATE.topViewController setUserModel:userModel];
            APPDELEGATE.familiarID = argFamiliarID;
            [CustomAlert alertShow:@"ようこそ" message:[NSString stringWithFormat:@"%@・ファミリアへ！", view.familiarNameTextView.text]];
            [self.navigationController popViewControllerAnimated:YES];
            [(TopViewController*)APPDELEGATE.topViewController reloadFamiliarData];
        }
    }];
}

- (UIImage *)addHimo:(UIImage *)argImageBack :(UIImage *)argImageFront
{
    UIImage *image = nil;
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 360), 0.f, 0);
    
    // 塗りつぶす領域を決める
    [argImageBack drawInRect:CGRectMake(0, 0, 320, 360)];
    [argImageFront drawInRect:CGRectMake(0, 0, 320, 360)];
    //[argImageFront drawInRect:CGRectMake((320 - 250)/2.0f, (360 - argImageFront.size.height * (250.0f/320.0f)) / 2.0f, 250, argImageFront.size.height * (250.0f/320.0f))];
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)nameInput:(id)sender{
    FreewordInputViewController *freewordInputViewController = [[FreewordInputViewController alloc] init:@"" :view.familiarNameTextView.text :1 :1 :10 :self :@selector(updateNameText:)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:freewordInputViewController] animated:YES completion:nil];
}

- (void)infoInput:(id)sender{
    FreewordInputViewController *freewordInputViewController = [[FreewordInputViewController alloc] init:@"" :view.familiarInfoTextView.text :3 :1 :150 :self :@selector(updateInfoText:)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:freewordInputViewController] animated:YES completion:nil];
}

- (void)updateNameText:(NSString *)argText
{
    view.familiarNameTextView.text = argText;
    
    if (0 < view.familiarNameTextView.text.length && 0 < view.familiarNameTextView.text.length) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)updateInfoText:(NSString *)argText
{
    view.familiarInfoTextView.text = argText;
    
    if (0 < view.familiarInfoTextView.text.length && 0 < view.familiarInfoTextView.text.length) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }

}

@end
