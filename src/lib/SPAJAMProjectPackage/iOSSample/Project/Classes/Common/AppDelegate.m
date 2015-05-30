//
//  AppDelegate.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize topViewController;
@synthesize ownerID;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 実行環境のダンプ
#ifdef DEPROY_SETTING
    NSLog(@"DEPROY_SETTING=%@", DEPROY_SETTING);
#endif

    // Google Analyticsの初期化
    [self initializeGoogleAnalytics];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        //アプリが起動していないときにpush通知からアプリが起動された時
    }

    // アプリ全体のステータスバーのスタイルを変更(用plistのView controller-based status bar = NO)
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    // ナビゲーションバーのスタイルを定義しておく
    // ナビゲーションバーの全体の色指定
    //[[UINavigationBar appearance] setBarTintColor:RGBA(16, 50, 64, 0.73)];
    // ナビゲーションバーのボタンアイテムのテキストカラー指定
    //[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // ナビゲーションバーのタイトルテキストカラー指定
    //[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    // TabbarItemの数だけUINavigationControllerのインスタンスを生成
    self.topViewController = [[LevelUpViewController alloc] init];
    UINavigationController *topNavigationController = [[UINavigationController alloc] initWithRootViewController:self.topViewController];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"bg_header.png"];
    [topNavigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    //topNavigationController.navigationBar.barStyle = UIBarStyleBlack;

    // Windowを表示
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:topNavigationController];
    [self.window makeKeyAndVisible];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: self.proximityUUID
                                                               identifier:@"net.otkr.shokumachi"];
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // requestAlwaysAuthorizationメソッドが利用できる場合(iOS8以上の場合)
            // 位置情報の取得許可を求めるメソッド
            [self.locationManager requestAlwaysAuthorization];
        } else {
            // requestAlwaysAuthorizationメソッドが利用できない場合(iOS8未満の場合)
            [self.locationManager startMonitoringForRegion: self.beaconRegion];
        }
    } else {
        // iBeaconが利用できない端末の場合
        NSLog(@"iBeaconを利用できません。");
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // バックグラウンドPushを使わない場合の通知受け取りの実装
    NSLog(@"userinfo %@",userInfo);
    if (application.applicationState == UIApplicationStateActive){
        //アプリがフォアグラウンドにいる時にpush通知を受け取った
    }
    else if (application.applicationState == UIApplicationStateInactive){
        // 通知からの復帰
    }
    else if (application.applicationState == UIApplicationStateBackground) {
        // バックグラウンドでの通知の受け取り
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // バックグラウンドPushを使う場合の通知受け取りの実装
    [self application:application didReceiveRemoteNotification:userInfo];
    // completionHandlerはダウンロードのような時間がかかる処理では非同期に呼ぶ。
    // 同期処理でも呼ばないとログにWarning出力されるので注意。
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - デバイストークンDelegate関連

// デバイストークンの受取
- (void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)token
{
    [ProjectModelBase saveDeviceTokenData:token];
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // i0S7以前の処理
        // XXX 通知のOFFかも知れない場合の処理
    }
    else {
        // iOS8の処理
        UIUserNotificationSettings *currentSettings = [[UIApplication
                                                        sharedApplication] currentUserNotificationSettings];
        // types:0 通知off
        if(currentSettings.types != 0){
            // XXX 通知のOFFの場合の処理
        }
    }
}

- (void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(NSError*)err{
    NSLog(@"Errorinregistration.Error:%@",err);
}

- (void)registerDeviceToken;
{
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // i0S7以前の処理
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
    else {
        // iOS8の処理
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    }
}

#pragma mark - プライベートメソッド関連

#pragma mark - パブリックメソッド関連

- (void)initializeGoogleAnalytics
{
    
//    // Optional: automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    
//    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//    [GAI sharedInstance].dispatchInterval = 20;
//    
//    // Optional: set Logger to VERBOSE for debug information.
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
//    
//    // Initialize tracker. Replace with your tracking ID.
//    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_TRACKING_ID];
//    
//    // Enable IDFA collection.
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker setAllowIDFACollection:YES];
}

- (BOOL)isSimulator;
{
    return [[[UIDevice currentDevice] model] hasSuffix:@"Simulator"];
}

#pragma mark - ローディング関連

- (void)showLoading:(NSString *)argLoadingMessage;
{
    if (nil == argLoadingMessage || [argLoadingMessage isEqualToString:@""]){
        argLoadingMessage = NSLocalizedString(@"Loading...", @"読み込み中...");
    }
    // ステータスバーの通信インジケータを表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // ローディングを表示
    [MProgress showProgressWithLoadingText:argLoadingMessage];
}

- (void)showLoading;
{
    // ステータスバーの通信インジケータを表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // ローディングを表示
    [MProgress showProgressWithLoadingText:NSLocalizedString(@"Loading...", @"読み込み中...")];
}

- (void)hideLoading;
{
    // ステータスバーの通信インジケータを非表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // ローディングを非表示
    [MProgress dismissProgress];
}


#pragma mark - UITabbarDelegate関連

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // 選択されたタブのルートをtopViewControllerとしてしまっておく
    self.topViewController  = [((UINavigationController *)viewController).viewControllers objectAtIndex:0];
}


#pragma mark - ModelDelegate関連

- (void)didReceiveMustUpdate:(NSString *)argUpdateURL;
{
    // 強制アップデートを受信
}

- (void)didReceiveAppBadgeNum:(NSString *)argBadgeNumStr;
{
    // アプリアイコンバッジを受信
    [UIApplication sharedApplication].applicationIconBadgeNumber = [argBadgeNumStr intValue];
}

- (void)didReceiveNotifyMessage:(NSString *)argNotifyMessage;
{
    NSLog(@"Notify Message=%@", argNotifyMessage);
    NSMutableArray *messageArr = [SBJsonAgent parseArr:argNotifyMessage];
    for (int messageIdx=0; messageIdx < messageArr.count; messageIdx++) {
        NSMutableDictionary *messageDic = [messageArr objectAtIndex:messageIdx];
        // 旧TSMessages風のナビゲーションバー通知表示
        if (nil != [messageDic objectForKey:@"message"] && 0 < [[messageDic objectForKey:@"message"] length] && nil != [messageDic objectForKey:@"notify_id"] && 0 < [[messageDic objectForKey:@"notify_id"] length] &&nil != [messageDic objectForKey:@"type"] && 0 < [[messageDic objectForKey:@"type"] length]) {
            [MMessages showMessage:[messageDic objectForKey:@"notify_id"] :[messageDic objectForKey:@"message"] :[((NSString *)[messageDic objectForKey:@"type"]) intValue]-1 :[messageDic objectForKey:@"schema"] completion:^(NSString *messageIdentifier) {
                NSLog(@"dispatched notifyID=%@", messageIdentifier);
            }];
        }
    }
}

/* アップロード・ダウンロードプログレス通知 */
/* XXX rootViewControllerのナビゲーションバーにプログレスを表示します */
- (void)didChangeProgress:(ModelBase*)model :(ProgressAgent *)progressAgent;
{
    NSLog(@"[bytesSent] %f, [totalBytesSent] %f, [totalBytesExpectedToSend] %f", progressAgent.packetSentBytes, progressAgent.totalSentBytes, progressAgent.totalBytes);
//    double progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
    // performSelectorOnMainThreadで描画スレッドに行ってね♪
    [MStatusbarProgress show:progressAgent.totalSentBytes :progressAgent.totalBytes];
}

#pragma mark - CLLocationManagerDelegate methods

// ユーザの位置情報の許可状態を確認するメソッド
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
    } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        // ユーザが位置情報の使用を常に許可している場合
        [self.locationManager startMonitoringForRegion: self.beaconRegion];
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        [self.locationManager startMonitoringForRegion: self.beaconRegion];
    }
}

// 領域計測が開始した場合
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Start Monitoring Region");
}

// 指定した領域に入った場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter Region");
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit Region");
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// 領域内にいるかどうかを確認する処理
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    switch (state) {
        case CLRegionStateInside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
                NSLog(@"Enter %@",region.identifier);
                //Beacon の範囲内に入った時に行う処理を記述する
                NSLog(@"Already Entering");
            }
            break;
            
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            break;
    }
}

// Beacon信号を検出した場合
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        self.nearestBeacon = beacons.firstObject;
        NSString *str = [[NSString alloc] initWithFormat:@"%f [m]", self.nearestBeacon.accuracy];
        if(self.nearestBeacon.accuracy < 5.0f){
            //一旦5mいないに入ったらLog出力
            NSLog(@"5m以内にはいりました");
        }
        
        NSLog(@"%@", str);
    }
}



@end
