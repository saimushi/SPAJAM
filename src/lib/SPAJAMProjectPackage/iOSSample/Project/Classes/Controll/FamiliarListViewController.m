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
#import "FamiliarRegisterViewController.h"
#import "UserModel.h"

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
    
    UIImage *backgroundImage = [UIImage imageNamed:@"bg_2.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.view addSubview:background];
    
    // TableView
    dataListView = [[UITableView alloc] init];
    // フレー7
    dataListView.frame = CGRectMake(0, 65, self.view.width, self.view.height - 65);
    dataListView.delegate = self;
    dataListView.dataSource = self;
    dataListView.backgroundColor = [UIColor clearColor];
    dataListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataListView.scrollsToTop = YES;
    //dataListView.allowsSelection = NO;

    // PullDownToRefresh
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - dataListView.bounds.size.height, self.view.frame.size.width, dataListView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [dataListView addSubview:_refreshHeaderView];
    
    [self.view addSubview:dataListView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self dataListLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 追加ボタンの追加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"追加" style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
    if(APPDELEGATE.familiarID != nil && [@"0" isEqualToString:APPDELEGATE.familiarID]){
        self.navigationItem.hidesBackButton = YES;
    }else{
        self.navigationItem.hidesBackButton = NO;
    }
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

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択解除
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (nil != APPDELEGATE.familiarID && ![APPDELEGATE.familiarID isEqualToString:@"0"]){
        // 現在参加中のファミリアかどうか
        FamiliarModel *familiarModel = [data objectAtIndex:(int)indexPath.row];
        if (![familiarModel.ID isEqualToString:APPDELEGATE.familiarID]){
            [CustomAlert alertShow:@"本当に・・・？" message:@"所属するファミリアを変更しますか？" buttonLeft:@"Cancel" buttonRight:@"OK" completionHandler:^(BOOL ok) {
                if (ok) {
                    // ファミリア抜ける
                    FamiliarModel *familiar = [data search:@"id" :APPDELEGATE.familiarID];
                    familiar.familiar_count = [NSString stringWithFormat:@"%d", ([familiar.familiar_count intValue] - 1)];
                    [familiar save:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
                        // 新しいファミリアに入る
                        if (success) {
                            [self performSelector:@selector(saveUserFamiliar:) withObject:[data objectAtIndex:(int)indexPath.row] afterDelay:0.5f];
                        }
                    }];
                }
            }];
        }
    }
    else {
        // 新しいファミリアに入る
        [self performSelector:@selector(saveUserFamiliar:) withObject:[data objectAtIndex:(int)indexPath.row] afterDelay:0.5f];
    }
}

- (void)saveUserFamiliar:(FamiliarModel *)argFamiliar
{
    UserModel *userModel = [[UserModel alloc] init];
    userModel.familiar_id = argFamiliar.ID;
    [userModel save:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if (success) {
            // ファミリアID変更
            APPDELEGATE.familiarID = argFamiliar.ID;
            // 成功したらファミリア参加者をインクリメント
            argFamiliar.familiar_count = [NSString stringWithFormat:@"%d", ([argFamiliar.familiar_count intValue] + 1)];
            [argFamiliar save:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
                if (success) {
                    [(TopViewController*)APPDELEGATE.topViewController setUserModel:userModel];
                    [CustomAlert alertShow:@"ようこそ" message:[NSString stringWithFormat:@"%@・ファミリアへ！", argFamiliar.name]];
                    // マイページ
                    [self.navigationController popViewControllerAnimated:YES];
                    [(TopViewController*)APPDELEGATE.topViewController viewDidLoad];
                }
            }];
        }
    }];
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
    [picker dismissViewControllerAnimated:NO completion:^{
        [self.navigationController pushViewController:[[FamiliarRegisterViewController alloc] initWithImage:image] animated:YES];
    }];
}

//画像の選択がキャンセルされた時に呼ばれる
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
