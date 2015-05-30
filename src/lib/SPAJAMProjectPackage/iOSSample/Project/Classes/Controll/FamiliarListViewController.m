//
//  TopViewController.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "FamiliarListViewController.h"
#import "FamiliarModel.h"
#import "NodataCellView.h"
#import "FamiliarCellView.h"
#import "MActionsheetButtonView.h"
#import <AVFoundation/AVFoundation.h>

@interface FamiliarListViewController ()
{
    // Private
    BOOL _loading;
    UITableView *dataListView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    FamiliarModel *data;
}
@end

@implementation FamiliarListViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        _loading = NO;
        // デフォルトのスクリーン名をセット
        screenName = @"ファミリア一覧";
        // モデルクラス初期化
        data = [[FamiliarModel alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
  
    // TableView
    dataListView = [[UITableView alloc] init];
    // フレーム
    dataListView.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.navigationController.navigationBar.frame.size.height - 64 - 5);
    dataListView.delegate = self;
    dataListView.dataSource = self;
    dataListView.backgroundColor = [UIColor clearColor];
    dataListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataListView.scrollsToTop = YES;
    dataListView.allowsSelection = NO;

    // PullDownToRefresh
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - dataListView.bounds.size.height, self.view.frame.size.width, dataListView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [dataListView addSubview:_refreshHeaderView];
    
    [self.view addSubview:dataListView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self dataListLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 追加ボタンの追加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataListLoad
{
    // デバイストークン取得
    [APPDELEGATE registerDeviceToken];
    _loading = YES;
    [APPDELEGATE showLoading];
    // 配列参照
    [data list:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if(YES == success){
            // 正常終了時 テーブルView Refresh
            [dataListView reloadData];
        }
        else {
            // エラー処理をするならココ
        }
        // Pull to Refleshを止める
        _loading = NO;
        [APPDELEGATE hideLoading];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:dataListView];
    }];
}

/**
 * 追加読み込み
 */
- (void)dataListAddLoad
{
    [self dataListLoad];
}

/**
 * データ追加
 */
- (void)addData
{
    NSLog(@"add");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // アクションシート表示
        [MActionsheetButtonView showActionsheetButtonView:[NSArray arrayWithObjects:@"写真を撮影する", @"カメラロールから選択", nil]
                                           isCancelButton:YES
                                               completion:^(NSInteger buttonIndex) {
                                                   // １番上のボタンを押した時
                                                   if (buttonIndex == 1) {
                                                       NSLog(@"first button pushed");
                                                       AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                                       if((status == AVAuthorizationStatusRestricted) || (status == AVAuthorizationStatusDenied)) {
                                                           if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
                                                               // i0S7以前の処理
                                                               [CustomAlert alertShow:@"" message:@"カメラへのアクセスが未許可です。\n設定でカメラの使用を許可してください。"];
                                                           }
                                                           else {
                                                               // iOS8の処理
                                                               [CustomAlert alertShow:@"" message:@"カメラへのアクセスが未許可です。\n設定でカメラの使用を許可してください。" buttonLeft:@"キャンセル" buttonRight:@"OK" completionHandler:^(BOOL result) {
                                                                   if(result){
                                                                       // OKを押したら設定画面に遷移
                                                                       NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                       [[UIApplication sharedApplication] openURL:url];
                                                                       return;
                                                                   }
                                                               }];
                                                           }
                                                           return;
                                                       }
                                                       picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                   }
                                                   // ２番めのボタンを押した時
                                                   else if (buttonIndex == 2) {
                                                       picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                       NSLog(@"second button pushed");
                                                   }
                                                   [self presentViewController:picker animated:YES completion:nil];
                                               }];
    }
    else {
        // 無条件でカメラロール表示
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 < data.total) {
        return 64;
    }
    // デフォルトのEmpty表示用
    return tableView.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 < data.total) {
        return data.total;
    }
    // デフォルトのEmpty表示用
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Identifier-%d-%d", (int) indexPath.section, (int)indexPath.row]];
    CGRect cellRect = CGRectMake(0, 0, self.view.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.backgroundColor = [UIColor clearColor];
    if(0 < data.total){
        // SampleModelデータ表示用Viewをセット
        [cell.contentView addSubview:[[FamiliarCellView alloc] initWithFrame:cellRect WithSampleModel:[data objectAtIndex:(int)indexPath.row]]];
    }
    else {
        // 0件表示用Viewをセット
        [cell.contentView addSubview:[[NodataCellView alloc] initWithFrame:cellRect]];
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 < data.total && data.total < data.records){
//        int rowMax = (int)tableView.height / (int)[self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        if(YES == (((int)indexPath.row) + 1 >= data.total)){
            // 追加読み込み
            [self dataListAddLoad];
        }
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    // テーブルView Refresh
    [self dataListLoad];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _loading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - UIImagePickerControllerDelegate Methods

//画像が選択された時に呼ばれるデリゲートメソッド
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
    // ヘスティアの紐と合成するぉ。
//    int cropImageWidth = 300;
//    int cropImageHeight = 300;
//    UIView *trimingOverlayView = [[UIView alloc] initWithFrame:APPDELEGATE.window.frame];
//    trimingOverlayView.userInteractionEnabled = NO;
//    if([currentImageField isEqualToString:@"main_image"]){
//        cropImageWidth = 320;
//        cropImageHeight = 300;
//        // トリムボーダーをオーバーレイ
//        UIView *trimBorderView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width - 320.0f) / 2.0f, (APPDELEGATE.window.frame.size.height - (175.0 * (300.0 / 320.0))) / 2.0, 320, 175.0 * (300.0 / 320.0))];
//        [trimBorderView.layer setBorderColor:[UIColor colorWithRed:1.00 green:0.27 blue:0.27 alpha:1.0].CGColor];
//        [trimBorderView.layer setBorderWidth:1.0];
//        trimBorderView.userInteractionEnabled = NO;
//        [trimingOverlayView addSubview:trimBorderView];
//        trimBorderView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width - 320.0f) / 2.0f, (APPDELEGATE.window.frame.size.height - 300)/2.0, 320, 300)];
//        [trimBorderView.layer setBorderColor:[UIColor whiteColor].CGColor];
//        [trimBorderView.layer setBorderWidth:1.0];
//        trimBorderView.userInteractionEnabled = NO;
//        [trimingOverlayView addSubview:trimBorderView];
//        // メインの時はトリミング画面にメッセージをオーバーレイ
//        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, APPDELEGATE.window.frame.size.height - 85, self.view.width, 25)];
//        labelView.text = @"   白線：詳細画面で表示されるエリア　赤線：リストで表示されるエリア";
//        labelView.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:9];
//        [labelView setTextColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
//        labelView.textAlignment = NSTextAlignmentLeft;
//        labelView.backgroundColor = [UIColor colorWithRed:0.90 green:0.91 blue:0.89 alpha:1.0];
//        labelView.userInteractionEnabled = NO;
//        [trimingOverlayView addSubview:labelView];
//    }
//    else {
//        // トリムボーダーをオーバーレイ
//        UIView *trimBorderView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2.0, (APPDELEGATE.window.frame.size.height - 300)/2.0, 300, 300)];
//        [trimBorderView.layer setBorderColor:[UIColor whiteColor].CGColor];
//        [trimBorderView.layer setBorderWidth:1.0];
//        trimBorderView.userInteractionEnabled = NO;
//        [trimingOverlayView addSubview:trimBorderView];
//    }
//    // トリミングを呼ぶ
//    [APPDELEGATE addSubviewFirstFront:[[MCropImageView alloc] initWithFrame:APPDELEGATE.window.frame :image :cropImageWidth :cropImageHeight :YES :trimingOverlayView :^(MCropImageView *mcropImageView, BOOL finished, UIImage *image) {
//        if(YES == finished && nil != image && [image isKindOfClass:NSClassFromString(@"UIImage")]){
//            // 画像保存処理
//            [APPDELEGATE showLoading:self.view];
//            if([currentImageField isEqualToString:@"main_image"]){
//                // main画像の保存
//                [APPDELEGATE.myprofile setMain_img_check:@"1"];
//                [APPDELEGATE.myprofile saveMainImage:image :^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
//                    [APPDELEGATE hideLoading:self.view];
//                    if (YES == success) {
//                        // 再描画
//                        [self showProfileDetail];
//                    }
//                    _editing = NO;
//                }];
//            }
//            else if([currentImageField isEqualToString:@"sub2_image"]){
//                // サブ画像の保存
//                [APPDELEGATE.myprofile setSub2_img_check:@"1"];
//                [APPDELEGATE.myprofile saveSub2Image:image :^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
//                    [APPDELEGATE hideLoading:self.view];
//                    if (YES == success) {
//                        // 再描画
//                        [self showProfileDetail];
//                    }
//                    _editing = NO;
//                }];
//            }
//            else if([currentImageField isEqualToString:@"sub3_image"]){
//                // サブ画像の保存
//                [APPDELEGATE.myprofile setSub3_img_check:@"1"];
//                [APPDELEGATE.myprofile saveSub3Image:image :^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
//                    [APPDELEGATE hideLoading:self.view];
//                    if (YES == success) {
//                        // 再描画
//                        [self showProfileDetail];
//                    }
//                    _editing = NO;
//                }];
//            }
//            else if([currentImageField isEqualToString:@"sub4_image"]){
//                // サブ画像の保存
//                [APPDELEGATE.myprofile setSub4_img_check:@"1"];
//                [APPDELEGATE.myprofile saveSub4Image:image :^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
//                    [APPDELEGATE hideLoading:self.view];
//                    if (YES == success) {
//                        // 再描画
//                        [self showProfileDetail];
//                    }
//                    _editing = NO;
//                }];
//            }
//        }
//        else {
//            _editing = NO;
//        }
//        // トリミング画面非表示
//        [mcropImageView dissmiss:YES];
//        [APPDELEGATE removeFromFirstFrontSubview:mcropImageView];
//    }]];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

//画像の選択がキャンセルされた時に呼ばれる
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
