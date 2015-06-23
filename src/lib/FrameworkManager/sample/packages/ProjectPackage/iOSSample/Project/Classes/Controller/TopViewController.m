//
//  TopViewController.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "TopViewController.h"
#import "SampleModel.h"

@interface TopViewController ()
{
    // Private
    BOOL _loading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    SampleModel *data;
}
@end

@implementation TopViewController

- (void)viewDidLoad
{
    _loading = NO;
    // デフォルトのスクリーン名をセット
    screenName = self.navigationItem.title;
    // モデルクラス初期化
    data = [[SampleModel alloc] init];
    [super viewDidLoad];
    // PullDownToRefresh
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.dataListView.bounds.size.height, self.dataListView.frame.size.width, self.dataListView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [self.dataListView addSubview:_refreshHeaderView];
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
            [self.dataListView reloadData];
        }
        else {
            // エラー処理をするならココ
        }
        // Pull to Refleshを止める
        _loading = NO;
        [APPDELEGATE hideLoading];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.dataListView];
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
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topTableCell"].frame.size.height;
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
    UITableViewCell *cell = nil;
    if(0 < data.total){
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"topTableCell" forIndexPath:indexPath];
        }
        SampleModel *sampleModel = [data objectAtIndex:(int)indexPath.row];
        // レコード名
        ((UILabel *)[cell.contentView viewWithTag:1]).text = sampleModel.name;
        // 日時
        ((UILabel *)[cell.contentView viewWithTag:2]).text = sampleModel.modified;
    }
    else {
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NodataCell"];
        }
        UIView *NodataCellView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"NodataCellView" owner:nil options:0] firstObject];
        NodataCellView.width = tableView.width;
        NodataCellView.height = tableView.height;
        [cell.contentView addSubview:NodataCellView];
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択解除
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 < data.total && data.total < data.records){
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
