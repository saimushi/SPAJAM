//
//  TopViewController.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "TopViewController.h"
#import "SampleModel.h"
#import "NodataCellView.h"
#import "SampleCellView.h"

@interface TopViewController ()
{
    // Private
    BOOL _loading;
    UITableView *dataListView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    SampleModel *data;
}
@end

@implementation TopViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        _loading = NO;
        // デフォルトのスクリーン名をセット
        screenName = @"トップ";
        // モデルクラス初期化
        data = [[SampleModel alloc] init];
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
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD", @"追加") style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
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
}

#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 < data.total) {
        return 50;
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
        [cell.contentView addSubview:[[SampleCellView alloc] initWithFrame:cellRect WithSampleModel:[data objectAtIndex:(int)indexPath.row]]];
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

@end
