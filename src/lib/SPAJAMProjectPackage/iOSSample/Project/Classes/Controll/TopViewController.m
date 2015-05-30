//
//  TopViewController.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "TopViewController.h"
#import "SampleModel.h"
#import "ActivityModel.h"
#import "FamiliarModel.h"
#import "FamiliarListViewController.h"
#import "MyPageView.h"
#import "DeviceModel.h"
#import "ActivityCellView.h"
#import "UserModel.h"

@interface TopViewController ()
{
    // Private
    BOOL _loading;
    UITableView *dataListView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    FamiliarModel *familiarData;
    ActivityModel *activityData;
    MyPageView *myPageView;
    UserModel *userModel;
}
@end

@implementation TopViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        _loading = NO;
        // デフォルトのスクリーン名をセット
        screenName = @"arimoファミリア";
        // モデルクラス初期化
        activityData = [[ActivityModel alloc] init];
        familiarData = [[FamiliarModel alloc] init];
        userModel    = [[UserModel alloc] init];
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
    dataListView.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.navigationController.navigationBar.frame.size.height - 5);
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
    
    UIButton *famillia = [[UIButton alloc]initWithFrame:CGRectMake(10, 465, 100, 50)];
    [famillia setTitle:@"一覧（仮）" forState:UIControlStateNormal];
    famillia.backgroundColor = [UIColor blackColor];
    [famillia addTarget:self action:@selector(onTapFamiliarListButton:)
       forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:famillia];

    UIButton *activity = [[UIButton alloc]initWithFrame:CGRectMake(115, 465, 150, 50)];
    [activity setTitle:@"モンスター（仮）" forState:UIControlStateNormal];
    activity.backgroundColor = [UIColor blackColor];
    [activity addTarget:self action:@selector(onTapActivityRegisterButton:)
       forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:activity];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // ユーザーをセットする
    DeviceModel *mydevice = [[DeviceModel alloc] init];
    [mydevice load:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if(YES == success){
            APPDELEGATE.ownerID = mydevice.owner_id;
            // ownerIDからModelの情報を取得する
            userModel = [[UserModel alloc] init];
            [userModel load:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
                
                
                if(userModel.total > 0){
                    
                    NSLog(@"familiar_id:%@",userModel.familiar_id);
                    
                    // ファミリアIDが0ならファミリア一覧に遷移する
                    if( [@"0" isEqual:userModel.familiar_id] ){
                        
                        // XXX にーやんさん待ちBackボタンがない版のFamiliarListViewControllerを表示
                        NSLog(@"にーやんさん待ち");
                        [self.navigationController pushViewController:[[FamiliarListViewController alloc] init] animated:YES];
                        
                    }
                    // ファミリアIDがあれば登録済み、ファミリア情報を取る
                    else{
                        
                        [self familiarDataLoad];
                        
                    }
                    
                }
                else{
                    NSLog(@"ここはこないと信じる");
                }
                
            }];
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 追加ボタンの追加
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD", @"追加") style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)familiarDataLoad
{
    // ここで自分の所属ファミリアを取得する！
    
    // デバイストークン取得
    [APPDELEGATE registerDeviceToken];
    _loading = YES;
    [APPDELEGATE showLoading];
    // 配列参照
    [familiarData list:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if(YES == success){
            if(familiarData.total > 0){
                // 正常終了時 テーブルViewのヘッダーにViewを入れる
                myPageView = [[MyPageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 360) WithDelegate:self];
                [dataListView setTableHeaderView:myPageView];
                // 自分の所属ファミリアが取れたので、続いてActivity一覧を取得する
                [self activityDataLoad];
            }
            else{
                // 自分の所属ファミリアが取れないので、ファミリア登録に遷移する
                // XXX
                
            }
        }
        _loading = NO;
        [APPDELEGATE hideLoading];
    }];
}

- (void)activityDataLoad
{
    // ここでActivity一覧を取得する！

    // デバイストークン取得
    [APPDELEGATE registerDeviceToken];
    _loading = YES;
    [APPDELEGATE showLoading];
    // 配列参照
    [activityData list:^(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError *error) {
        if(YES == success){
            // 正常終了時 テーブルView Refresh
            [dataListView reloadData];
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
    [self activityDataLoad];
}

/**
 * データ追加
 */
- (void)addData
{
    NSLog(@"add");
}

#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 < activityData.total) {
        return 50;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 < activityData.total) {
        return activityData.total;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Identifier-%d-%d", (int) indexPath.section, (int)indexPath.row]];
    CGRect cellRect = CGRectMake(0, 0, self.view.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.backgroundColor = [UIColor clearColor];
    if(0 < activityData.total){
        // SampleModelデータ表示用Viewをセット
        [cell.contentView addSubview:[[ActivityCellView alloc] initWithFrame:cellRect WithSampleModel:[activityData objectAtIndex:(int)indexPath.row]]];
    }
    else {
        // 0件
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 < activityData.total && activityData.total < activityData.records){
        if(YES == (((int)indexPath.row) + 1 >= activityData.total)){
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
    [self activityDataLoad];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _loading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

-(void)onTapFamiliarListButton:(UIButton*)button{
    [self.navigationController pushViewController:[[FamiliarListViewController alloc] init] animated:YES];
}
-(void)onTapActivityRegisterButton:(UIButton*)button{
    NSLog(@"まだないよ");
}

@end
