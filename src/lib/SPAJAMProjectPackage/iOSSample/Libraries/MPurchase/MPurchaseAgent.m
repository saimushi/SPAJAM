
#import <StoreKit/StoreKit.h>
#import "MPurchaseAgent.h"
#import "SBJSON.h"
#import "MProductAgent.h"


#pragma mark - Protected interfaces

@interface MSKReceiptRefreshRequest : SKReceiptRefreshRequest
- (id)init:(id)argDelegate :(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
- (void)finishRefresh;
@end


@interface MPurchaseAgent ()<SKPaymentTransactionObserver, UIAlertViewDelegate, SKRequestDelegate>
{
    SKProduct *currentProduct;
    BOOL startObserver;
    NSMutableDictionary *purchaseFinishDic;
    NSMutableDictionary *restoreFinishDic;
    NSMutableDictionary *productTypeDic;
    int restoreAll;
    int restoreCnt;
    int restoredCnt;
    SKPaymentQueue *lastRestoreQueue;
}

/* Protected */
- (void)finishPurchaseTransaction:(SKPaymentTransaction *)transaction;
- (void)finishRestoreTransaction:(SKPaymentTransaction *)transaction;
- (void)finishCancelTransaction:(SKPaymentTransaction *)transaction;
- (void)finishDeferredTransaction:(SKPaymentTransaction *)transaction;

@end


#pragma mark - Start implementation

@implementation MSKReceiptRefreshRequest
{
    SKPaymentTransaction *transaction;
    BOOL restored;
    void(^_compBlock)(NSDictionary *receiptDic);
}

- (id)init:(id)argDelegate :(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
{
    self = [super init];
    if (self){
        transaction = argTransaction;
        restored = argRestored;
        _compBlock = argCompletion;
        self.delegate = argDelegate;
    }
    return self;
}

- (void)finishRefresh
{
    [[MPurchaseAgent sharedInstance] verifyReceiptForLocal:transaction :restored :_compBlock];
}

- (void)finishFail
{
    [[MPurchaseAgent sharedInstance] finishCancelTransaction:transaction];
}

@end


@implementation MPurchaseAgent

@synthesize delegate;


#pragma mark - Life Cycle

static MPurchaseAgent *sharedInstance = nil;
static NSString *sharedSecret = nil;
// 表示アラートスタック用
static NSMutableDictionary *alerts = nil;

/* オーバーライド シングルトン */
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

/* オーバーライド */
- (id)init
{
    self = [super init];
    if(nil != self){
        self.delegate = nil;
        currentProduct = nil;
        startObserver = NO;
        purchaseFinishDic = [[NSMutableDictionary alloc] init];
        restoreFinishDic = [[NSMutableDictionary alloc] init];
        productTypeDic = [[NSMutableDictionary alloc] init];
        alerts = [[NSMutableDictionary alloc] init];
        restoreAll = 0;
        restoreCnt = 0;
        restoredCnt = 0;
        lastRestoreQueue = nil;
    }
    return self;
}

/* シングルトン用の拡張スタティックメソッド */
+ (id)sharedInstance;
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance = [[self alloc] init];
        }
    }
	return sharedInstance;
}

/* 定期購読機能用 シングルトン用の拡張スタティックメソッド */
+ (id)sharedInstance :(NSString *)argSharedSecret;
{
    MPurchaseAgent *purchase = [MPurchaseAgent sharedInstance];
    if(!sharedSecret){
        sharedSecret = argSharedSecret;
    }
    return purchase;
}

/* インスタンスの開放 */
- (void)dealloc{
    if (YES == startObserver) {
        // オブザーバーを破棄
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
}

/* オブザーバーが未スタートだったらスタートさせる(事前登録用) */
+ (void)startPaymentTransactionObserver;
{
    [[MPurchaseAgent sharedInstance] startPaymentTransactionObserver];
}

/* 指定トランザクションを終了させられるインターフェース用 */
+ (void)finishTransaction:(SKPaymentTransaction *)argTransaction;
{
    [[SKPaymentQueue defaultQueue] finishTransaction:argTransaction];
}


#pragma mark - Verify Receipt

/* レシートチェック */
- (void)verifyReceipt:(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
{
    // sharedSecretが定義されている場合、リモートでレシートをチェックします
    if (nil != sharedSecret){
        // appleリモートサーバでレシートチェックします
        [self verifyReceiptForRemote:argTransaction :argRestored :argCompletion];
        return;
    }
    else {
        // sharedSecretが無いのでローカルレシートチェックとします
        [self verifyReceiptForLocal:argTransaction :argRestored :argCompletion];
        return;
    }
}

/* リモートレシートチェック */
- (void)verifyReceiptForRemote:(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
{
    //APPLEサーバへのレシートベリファイ
    NSString *urlsting = @"https://buy.itunes.apple.com/verifyReceipt";
    //リクエスト生成
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlsting]];
    NSString *jsonString = [NSString stringWithFormat:
                            @"{\"receipt-data\":\"%@\", \"password\":\"%@\"}", [[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0]
                            , sharedSecret];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    //通信、レスポンス処理
    NSData *decodeData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *receipt = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [receipt JSONValue];
    
    if ([[dic objectForKey:@"status"] intValue] == 21007 || [[dic objectForKey:@"status"] intValue] == 21008){
        // URLをかえて再リクエスト
        switch ([[dic objectForKey:@"status"] intValue]) {
            case 21007:
                // テスト環境のレシートを、実稼働環境に送信して検証しようとしました。これはテスト環境に送信してください。
                urlsting = @"https://sandbox.itunes.apple.com/verifyReceipt";
                break;
            case 21008:
                // 実稼働環境のレシートを、テスト環境に送信して検証しようとしました。これは実稼働環境に送信してください。
                urlsting = @"https://buy.itunes.apple.com/verifyReceipt";
                break;
            default:
                break;
        }
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlsting]];
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        //通信、レスポンス処理
        decodeData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        receipt = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
        dic = [receipt JSONValue];
    }
    if (nil != dic && nil != [dic objectForKey:@"status"]){
        [dic setValue:[NSString stringWithFormat:@"%d", [[dic objectForKey:@"status"] intValue]] forKey:@"status"];
    }
    // レシートステータスチェック
    if (nil != dic && nil != [dic objectForKey:@"status"] && [[dic objectForKey:@"status"] isEqualToString:@"0"]) {
        // チェックは一旦成功なので成功statusを付加する
        restoredCnt++;
        // 購読アイテムかどうか
        NSString *productType = (NSString *)[productTypeDic objectForKey:argTransaction.payment.productIdentifier];
        if(nil != [dic objectForKey:@"latest_receipt_info"] && nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]] && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductNonConsumable]]){
            // 購読アイテムだったら購読期間の確認を行う
            // 定期購読型のプロダクトのレシートの場合、expirdateを探し出し、有効期限内かどうかを判定する
            NSArray *result = [[dic objectForKey:@"latest_receipt_info"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"product_id == %@", argTransaction.payment.productIdentifier]];
            if (nil != result && 0 < result.count){
                // 購読アイテムだったら購読期間の確認を行う
                NSNumber *expiresDateMax = [[NSNumber alloc] init];
                for (NSDictionary *latestReceiptInfo in result) {
                    // NSDate変換
                    NSNumber *expiresDate = [latestReceiptInfo objectForKey:@"expires_date_ms"];
                    if ([expiresDateMax doubleValue] < [expiresDate doubleValue]){
                        expiresDateMax = expiresDate;
                    }
                }
                // 最長購読期限をGMTで保存
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSDate *lastExpiredDate = [NSDate dateWithTimeIntervalSince1970:[expiresDateMax doubleValue] / 1000];
                // 和暦回避
                [dateFormatter setLocale:[NSLocale systemLocale]];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                // 出力フォーマット指定
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                // 保存用に文字列に変換
                NSString *gmtdatetime = [dateFormatter stringFromDate:lastExpiredDate];
                // しまっておく
                [dic setValue:gmtdatetime forKey:@"last_expired_date"];
                // 購読期間の期限切れをチェック
                NSTimeInterval old = [[NSDate date] timeIntervalSinceDate:lastExpiredDate];
                // 現在日時
                dateFormatter = [[NSDateFormatter alloc] init];
                // 和暦回避
                [dateFormatter setLocale:[NSLocale systemLocale]];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                NSDate *nowdate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                NSTimeInterval now = [[NSDate date] timeIntervalSinceDate:nowdate];
                NSLog(@"old=%f %@", old, [lastExpiredDate description]);
                NSLog(@"now=%f %@", now, [nowdate description]);
                if (old > now){
                    // リストア成功のカウントに入れるのをヤメ
                    restoredCnt--;
                    // 期限切れ
                    [dic setValue:@"1" forKey:@"expired"];
                }
                else {
                    // 期限内
                    [dic setValue:@"0" forKey:@"expired"];
                }
                NSLog(@"%@", dic);
                // 定期購読Verifyの正常終了
                argCompletion(dic);
                return;
            }
            // Verify異常終了
            argCompletion(nil);
            return;
        }
        // Verify終了
        argCompletion(dic);
        return;
    }
    // Verify異常終了
    argCompletion(nil);
    return;
}

/* ローカルレシートチェック */
- (void)verifyReceiptForLocal:(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
{
    static BOOL refreshed = NO;
    if (nil != argTransaction){
//        if (YES == argRestored && NO == refreshed){
//            // 復元の場合は、先にレシートの最新を取得
//            refreshed = YES;
//            [[[MSKReceiptRefreshRequest alloc] init:sharedInstance :argTransaction :argRestored :argCompletion] start];
//            return;
//        }
        // ローカルチェック開始
        setAppleRootCert(getAppleRootCert());
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        if (verifyReceiptAtPath(receiptURL.path)) {
            NSDictionary *dic = dictionaryWithAppStoreReceipt(receiptURL.path);
            if (nil != dic && nil != [dic objectForKey:@"InApp"]){
                // トランザクションに紐付くレシートの存在チェック
                NSString *productType = (NSString *)[productTypeDic objectForKey:argTransaction.payment.productIdentifier];
                NSLog(@"TransactionIdentifier=%@", argTransaction.transactionIdentifier);
                NSLog(@"ProductIdentifier=%@", argTransaction.payment.productIdentifier);
                NSLog(@"productType=%@", productType);
//                NSArray *result = [[dic objectForKey:@"InApp"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"TransactionIdentifier == %@ and ProductIdentifier == %@", argTransaction.transactionIdentifier, argTransaction.payment.productIdentifier]];
                NSArray *result = [[dic objectForKey:@"InApp"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ProductIdentifier == %@", argTransaction.payment.productIdentifier]];
//                if (YES == argRestored){
//                    // リストアの場合は、ProductIdentifierのみをNSPredicateの対象とする(リストアトランザクションはトランザクションIDに紐付くレシートが無い為)
//                    result = [[dic objectForKey:@"InApp"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ProductIdentifier == %@", argTransaction.payment.productIdentifier]];
//                }
                if(nil != productType && [productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]]){
                    // 消耗型アイテムは、トランザクションIDも見る
                    result = [[dic objectForKey:@"InApp"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"TransactionIdentifier == %@ and ProductIdentifier == %@", argTransaction.transactionIdentifier, argTransaction.payment.productIdentifier]];
                }
                if (nil != result && 0 < result.count){
                    // チェックは一旦成功なので成功statusを付加する
                    [dic setValue:@"0" forKey:@"status"];
                    restoredCnt++;
                    // 購読アイテムかどうか
                    if(nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]] && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductNonConsumable]]){
                        // 購読アイテムだったら購読期間の確認を行う
                        NSDateFormatter *dateFormatter;
                        NSDate *lastExpiredDate;
                        NSTimeInterval expires;
                        for (NSDictionary *inApp in result) {
                            // NSDate変換
                            lastExpiredDate =[MPurchaseAgent getNSDateFromRFC3339String:[inApp objectForKey:@"SubExpDate"]];
                            // 数値比較
                            NSTimeInterval e = [[NSDate date] timeIntervalSinceDate:lastExpiredDate];
                            if (expires < e) {
                                // SubExpDateの最大値
                                expires = e;
                            }
                        }
                        // 最長購読期限をGMTで保存
                        dateFormatter = [[NSDateFormatter alloc] init];
                        // 和暦回避
                        [dateFormatter setLocale:[NSLocale systemLocale]];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                        // 出力フォーマット指定
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        // 保存用に文字列に変換
                        NSString *gmtdatetime = [dateFormatter stringFromDate:lastExpiredDate];
                        // しまっておく
                        [dic setValue:gmtdatetime forKey:@"last_expired_date"];
                        // 購読期間の期限切れをチェック
                        NSTimeInterval old = [[NSDate date] timeIntervalSinceDate:lastExpiredDate];
                        // 現在日時
                        dateFormatter = [[NSDateFormatter alloc] init];
                        // 和暦回避
                        [dateFormatter setLocale:[NSLocale systemLocale]];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                        NSDate *nowdate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                        NSTimeInterval now = [[NSDate date] timeIntervalSinceDate:nowdate];
                        NSLog(@"old=%f %@", old, [lastExpiredDate description]);
                        NSLog(@"now=%f %@", now, [nowdate description]);
                        if (old > now){
                            // リストア成功のカウントに入れるのをヤメ
                            restoredCnt--;
                            if(NO == refreshed) {
                                refreshed = YES;
                                // 該当レシートがローカルで見つからないので、レシートのリフレッシュリクエストをしてみる
                                [[[MSKReceiptRefreshRequest alloc] init:sharedInstance :argTransaction :argRestored :argCompletion] start];
                                return;
                            }
                            // 期限切れ
                            [dic setValue:@"1" forKey:@"expired"];
                        }
                        else {
                            // 期限内
                            [dic setValue:@"0" forKey:@"expired"];
                        }
                    }
                    NSLog(@"%@", dic);
                    // Verify終了
                    argCompletion(dic);
                    refreshed = NO;
                    return;
                }
                else if(NO == refreshed) {
                    refreshed = YES;
                    // 該当レシートがローカルで見つからないので、レシートのリフレッシュリクエストをしてみる
                    [[[MSKReceiptRefreshRequest alloc] init:sharedInstance :argTransaction :argRestored :argCompletion] start];
                    return;
                }
            }
        }
    }
    // Verify異常終了
    argCompletion(nil);
    refreshed = NO;
    return;
}


#pragma mark - Alert Controll

/* アラートを表示し、アラートメッセージをキーにアラートをスタックする */
+ (void)showAlert:(NSString *)argErrorMsg :(BOOL)argFinishing;
{
    // メインスレッドでアラート表示
    NSString *finishBtnStr = nil;
    if (YES == argFinishing) {
        finishBtnStr = NSLocalizedString(@"OK", @"OK");
    }
    if (nil == argErrorMsg || [argErrorMsg isEqualToString:@""]) {
        argErrorMsg = NSLocalizedString(PURCHASE_ERROR_KEY, @"購入に失敗しました。再度手続きしてください。");
    }
//    __block NSMutableDictionary *_alerts = [alerts mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^ {
        // アラートインスタンス生成&スタック
        if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
            // i0S7以前の処理
            if ([[alerts objectForKey:argErrorMsg] isKindOfClass:NSClassFromString(@"UIAlertView")]) {
                // 一旦閉じる
                //dispatch_async(dispatch_get_main_queue(), ^ {
                    //[(UIAlertView *)[alerts objectForKey:argErrorMsg] dismissWithClickedButtonIndex:0 animated:NO];
                //});
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@""
                                          message:argErrorMsg
                                          delegate:[MPurchaseAgent sharedInstance]
                                          cancelButtonTitle:finishBtnStr
                                          otherButtonTitles:nil];
                [alerts setObject:alertView forKey:argErrorMsg];
                // i0S7以前の処理
                [(UIAlertView *)[alerts objectForKey:argErrorMsg] show];
            }
        }
        else {
            // iOS8の処理
            if ([[alerts objectForKey:argErrorMsg] isKindOfClass:NSClassFromString(@"UIAlertController")] && nil != ((UIAlertController *)[alerts objectForKey:argErrorMsg]).presentingViewController) {
                // 表示をスキップ
//              // 一旦閉じる
                //dispatch_async(dispatch_get_main_queue(), ^ {
//                if (nil != ((UIAlertController *)[alerts objectForKey:argErrorMsg]).presentingViewController) {
//                    [(UIAlertController *)[alerts objectForKey:argErrorMsg] dismissViewControllerAnimated:NO completion:nil];
//                }
                //});
            }
            else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:argErrorMsg preferredStyle:UIAlertControllerStyleAlert];
                if (YES == argFinishing) {
                    // OKボタン
                    [alertVC addAction:[UIAlertAction actionWithTitle:finishBtnStr style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [alerts removeObjectForKey:argErrorMsg];
                        [MPurchaseAgent hideAlerts];
                    }]];
                }
                [alerts setObject:alertVC forKey:argErrorMsg];
                // iOS8の処理
                UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
                while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
                    baseView = baseView.presentedViewController;
                }
                if ([baseView isKindOfClass:NSClassFromString(@"UITabBarController")]) {
                    baseView = ((UITabBarController *)baseView).selectedViewController;
                }
                if ([baseView isKindOfClass:NSClassFromString(@"UINavigationController")]) {
                    baseView = [((UINavigationController *)baseView).viewControllers objectAtIndex:((UINavigationController *)baseView).viewControllers.count -1];
                }
                [baseView presentViewController:(UIAlertController *)[alerts objectForKey:argErrorMsg] animated:YES completion:nil];
            }
        }
    });
}

/* 表示しているアラートを全て閉じる */
+ (void)hideAlerts;
{
    // 全てのアラートを閉じる
    dispatch_async(dispatch_get_main_queue(), ^ {
        if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
            // i0S7以前の処理
            for (id key in [[[alerts allKeys] reverseObjectEnumerator] allObjects]){
                UIAlertView *alert = [alerts valueForKey:key];
                if (nil != alert && [[alerts valueForKey:key] isKindOfClass:NSClassFromString(@"UIAlertView")]) {
                    [alert dismissWithClickedButtonIndex:0 animated:NO];
                }
                if (nil != alert) {
                    [alerts removeObjectForKey:key];
                }
            }
        }
        else {
            // iOS8の処理
            for (id key in [[[alerts allKeys] reverseObjectEnumerator] allObjects]) {
                UIAlertController *alert = [alerts valueForKey:key];
                if (nil != alert) {
                    [alerts removeObjectForKey:key];
                }
                if (nil != alert && [alert isKindOfClass:NSClassFromString(@"UIAlertController")]) {
                    [alert dismissViewControllerAnimated:YES completion:^{
                        // リカーシブ
                        [self hideAlerts];
                    }];
                    break;
                }
            }
        }
    });
}

/* iOS7以下用アラートデレゲート */
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 表示しているアラートを全て閉じる
    [MPurchaseAgent hideAlerts];
}


#pragma mark - Purchase

/* 購入の実質的な開始処理(購入判定・プライベートメソッド) */
- (void)purchase:(SKProduct *)argProduct
{
    // オブザーバーが未スタートだったらスタートさせる
    [self startPaymentTransactionObserver];

    // 購入前のリストアチェック
    currentProduct = argProduct;
    
    // 購読アイテムかどうか
    NSString *productType = (NSString *)[productTypeDic objectForKey:argProduct.productIdentifier];
    if(nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]]){
        // リストアの開始を通知
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyStartRestoreTransaction:)]){
            // リストア開始を通知(メインスレッドで実行)
            [self.delegate  performSelectorOnMainThread:@selector(notifyStartRestoreTransaction:) withObject:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...") waitUntilDone:NO];
        }
        else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyStartRestoreTransaction:)]){
            // 購入開始の通知(メインスレッドで実行)
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication].delegate performSelector:@selector(notifyStartRestoreTransaction:) withObject:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...")];
            });
        }
        else {
            // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
            [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...") :NO];
        }
        // リストアキューを登録し、先ずリストア出来るかどうか確認する
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        return;
    }

    // 購入手続きに以降
    [self startPurchase:argProduct];
}

/* 購入の実質的な開始処理(プライベートメソッド) */
- (void)startPurchase:(SKProduct *)argProduct
{
    SKPayment *payment = [SKPayment paymentWithProduct:argProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    // 購入開始を通知
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyStartPurchaseTransaction:)]){
        // 購入開始の通知(メインスレッドで実行)
        [self.delegate performSelectorOnMainThread:@selector(notifyStartPurchaseTransaction:) withObject:argProduct waitUntilDone:NO];
    }
    else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyStartPurchaseTransaction:)]){
        // 購入開始の通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication].delegate performSelector:@selector(notifyStartPurchaseTransaction:) withObject:argProduct];
        });
    }
    else {
        // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
        [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_NOW_WAIT_KEY, @"購入手続き中...") :NO];
    }
    // 購入を開始したのでもう不要
    currentProduct = nil;
}

/* 購入処理実行(SKProduct) */
- (void)purchaseWithProduct:(SKProduct *)argProduct :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
{
    // 直接購入を呼んだ時は、entryを更新する
    [self entryWithProduct:argProduct :argProductType :argPurchaseComplation :argRestoreComplation];
    // 購入実行
    [self purchaseWithProduct:argProduct];
}

/* 購入処理実行(プロダクトID文字列) */
- (void)purchaseWithProductID:(NSString *)argProductID :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
{
    // 直接購入を呼んだ時は、entryを更新する
    [self entryWithProductID:argProductID :argProductType :argPurchaseComplation :argRestoreComplation];
    // 直接購入を実行
    [self purchaseWithProductID:argProductID];
}

/* 事前にentryされたプロダクトの購入処理実行(SKProduct) */
- (void)purchaseWithProduct:(SKProduct *)argProduct;
{
    // アイテム購入開始
    if (![SKPaymentQueue canMakePayments])
    {
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyPurchaseLimitedError:)]){
            // 購入制限エラーを通知(メインスレッドで実行)
            [self.delegate performSelectorOnMainThread:@selector(notifyPurchaseLimitedError:) withObject:NSLocalizedString(PURCHASE_LIMITED_ERROR_KEY, @"アプリ内でのアイテム購入が制限されています。") waitUntilDone:NO];
        }
        else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyPurchaseLimitedError:)]){
            // 購入開始の通知(メインスレッドで実行)
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication].delegate performSelector:@selector(notifyPurchaseLimitedError:) withObject:NSLocalizedString(PURCHASE_LIMITED_ERROR_KEY, @"アプリ内でのアイテム購入が制限されています。")];
            });
        }
        else {
            // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
            [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_LIMITED_ERROR_KEY, @"アプリ内でのアイテム購入が制限されています。") :YES];
        }
        // 異常終了
        return;
    }
    // 購入開始
    [self performSelectorInBackground:@selector(purchase:) withObject:argProduct];
}

/* 事前にentryされたプロダクトIDの購入処理実行(プロダクトID文字列) */
- (void)purchaseWithProductID:(NSString *)argProductID;
{
    // アイテム購入開始
    if (![SKPaymentQueue canMakePayments])
    {
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyPurchaseLimitedError:)]){
            // 購入制限エラーを通知(メインスレッドで実行)
            [self.delegate performSelectorOnMainThread:@selector(notifyPurchaseLimitedError:) withObject:NSLocalizedString(PURCHASE_LIMITED_ERROR_KEY, @"アプリ内でのアイテム購入が制限されています。") waitUntilDone:NO];
        }
        else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyPurchaseLimitedError:)]){
            // 購入開始の通知(メインスレッドで実行)
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication].delegate performSelector:@selector(notifyPurchaseLimitedError:) withObject:NSLocalizedString(PURCHASE_LIMITED_ERROR_KEY, @"アプリ内でのアイテム購入が制限されています。")];
            });
        }
        else {
            // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
            [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_LIMITED_ERROR_KEY, @"アプリ内でのアイテム購入が制限されています。") :YES];
        }
        // 異常終了
        return;
    }
    // プロダクト情報をアップルから取得
    [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...") :NO];
    [MProductAgent productWithProductIdentifier:argProductID completeBlock:^(SKProductsResponse *response, SKProduct *product) {
        // 返送情報がnilであれば処理無し
        if (response == nil){
            if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifySKRequestFailWithError:)]){
                // プロダクトID問い合わせ失敗エラーを通知(メインスレッドで実行)
                [self.delegate  performSelectorOnMainThread:@selector(notifySKRequestFailWithError:) withObject:nil waitUntilDone:NO];
            }
            else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifySKRequestFailWithError:)]){
                // 購入開始の通知(メインスレッドで実行)
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(notifySKRequestFailWithError:) withObject:nil];
                });
            }
            else {
                // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
                [MPurchaseAgent showAlert:NSLocalizedString(STORE_SESSION_ERROR_KEY, @"AppStoreとの接続に失敗しました。再度手続きしてください。") :YES];
            }
            // 異常終了
            return;
        }
        //正しいプロダクトIDであれば、引き続き購入処理
        if ([response.products count] > 0){
            // 購入処理へ遷移
            [self purchase:[response.products objectAtIndex:0]];
        }
    } errorBlock:^(NSError *error) {
        //SKRequestの失敗を、appDelegateに通知
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifySKRequestFailWithError:)]){
            // プロダクトID問い合わせ失敗エラーを通知(メインスレッドで実行)
            [self.delegate  performSelectorOnMainThread:@selector(notifySKRequestFailWithError:) withObject:error waitUntilDone:NO];
        }
        else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifySKRequestFailWithError:)]){
            // 購入開始の通知(メインスレッドで実行)
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication].delegate performSelector:@selector(notifySKRequestFailWithError:) withObject:error];
            });
        }
        else {
            // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
            [MPurchaseAgent showAlert:error.localizedDescription :YES];
        }
        // 異常終了
        return;
    }];
}

/* リストア処理実行 */
- (void)restore;
{
    currentProduct = nil;
    // リストア成功数を初期化
    restoreAll = 0;
    restoreCnt = 0;
    restoredCnt = 0;
    lastRestoreQueue = nil;
    // リストアの開始を通知
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyStartRestoreTransaction:)]){
        // リストア開始を通知(メインスレッドで実行)
        [self.delegate  performSelectorOnMainThread:@selector(notifyStartRestoreTransaction:) withObject:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...") waitUntilDone:NO];
    }
    else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyStartRestoreTransaction:)]){
        // 購入開始の通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication].delegate performSelector:@selector(notifyStartRestoreTransaction:) withObject:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...")];
        });
    }
    else {
        // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
        [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...") :NO];
    }
    // オブザーバーが未スタートだったらスタートさせる
    [self startPaymentTransactionObserver];
    // リストアキューを登録し、リストア処理を開始して貰う
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

/* 購入の登録(SKProduct) */
- (void)entryWithProduct:(SKProduct *)argProduct :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
{
    //プロダクトIDと完了時に呼ぶブロックを保持・永続化
    if (argPurchaseComplation){
        [purchaseFinishDic setObject:[argPurchaseComplation copy] forKey:argProduct.productIdentifier];
    }
    if (argRestoreComplation){
        [restoreFinishDic setObject:[argRestoreComplation copy] forKey:argProduct.productIdentifier];
    }
    [productTypeDic setObject:[NSString stringWithFormat:@"%d", argProductType] forKey:argProduct.productIdentifier];
}

/* 購入の登録(プロダクトID文字列) */
- (void)entryWithProductID:(NSString *)argProductID :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
{
    //プロダクトIDと完了時に呼ぶブロックを保持・永続化
    if (argPurchaseComplation){
        [purchaseFinishDic setObject:[argPurchaseComplation copy] forKey:argProductID];
    }
    if (argRestoreComplation){
        [restoreFinishDic setObject:[argRestoreComplation copy] forKey:argProductID];
    }
    [productTypeDic setObject:[NSString stringWithFormat:@"%d", argProductType] forKey:argProductID];
}

/* オブザーバーが未スタートだったらスタートさせる(事前登録用) */
- (void)startPaymentTransactionObserver;
{
    if (NO == startObserver) {
        // オブザーバーが未スタートだったらスタートさせる
        startObserver = YES;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:sharedInstance];
    }
}


#pragma mark - Payment Transaction Methods

/* 購入・定期購読更新の終了処理 */
- (void)finishPurchaseTransaction:(SKPaymentTransaction *)transaction
{
    // 排他制御 他のスレッドから2重でこのメソッドを呼べないようにして実行
//    @synchronized(self)
    {
        // トランザクション判定
        NSLog(@"productID=%@", transaction.payment.productIdentifier);
        NSLog(@"transactionID=%@", transaction.transactionIdentifier);
        NSLog(@"%@", transaction.payment.requestData.JSONValue);
        if (![transaction isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
            // アラートを全て閉じる
            [MPurchaseAgent hideAlerts];
            // トランザクションが無いので無視して終了
            return;
        }
        // アラート出てないかもしれないので出しとく(既に出てたら出ない)
        [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_FINISH_WAIT_KEY, @"購入履歴チェック中...") :NO];
        //APPLEベリファイ
        [self verifyReceipt:transaction :NO :^(NSDictionary *receiptDic) {
            // 一旦、アラートを全て閉じる
            //[MPurchaseAgent hideAlerts];
            // 購入終了判定
            NSLog(@"PURCHASE FINISH : %@", receiptDic);
            if (nil != receiptDic){
                // Purchaseの終了通知
                if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyFinishPurchaseTransaction:::::)]){
                    // 購入完了を通知(メインスレッドで実行)
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.delegate notifyFinishPurchaseTransaction:transaction :[receiptDic objectForKey:@"status"] :[[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0] :((nil ==[receiptDic objectForKey:@"expired"] || [[receiptDic objectForKey:@"expired"] isEqualToString:@"1"]) ? YES : NO) :[receiptDic objectForKey:@"last_expired_date"]];
                    });
                }
                else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyFinishPurchaseTransaction:::::)]){
                    // 購入完了を通知(メインスレッドで実行)
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [(NSObject<MPurchaseDelegate>*)[UIApplication sharedApplication].delegate notifyFinishPurchaseTransaction:transaction :[receiptDic objectForKey:@"status"] :[[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0] :((nil ==[receiptDic objectForKey:@"expired"] || [[receiptDic objectForKey:@"expired"] isEqualToString:@"1"]) ? YES : NO) :[receiptDic objectForKey:@"last_expired_date"]];
                    });
                }
                // 購入完了ブロックを実行
                MPurchaseDelegateBlock block = (MPurchaseDelegateBlock)[purchaseFinishDic objectForKey:transaction.payment.productIdentifier];
                if (block){
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                            block(transaction, [receiptDic objectForKey:@"status"], [[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0], ((nil ==[receiptDic objectForKey:@"expired"] || [[receiptDic objectForKey:@"expired"] isEqualToString:@"1"]) ? YES : NO), [receiptDic objectForKey:@"last_expired_date"], ^{
                                NSLog(@"finishPurchaseTransaction=%@", [transaction description]);
                                NSLog(@"productID=%@", transaction.payment.productIdentifier);
                                NSLog(@"transactionID=%@", transaction.transactionIdentifier);
                                // アラートを全て閉じる
                                [MPurchaseAgent hideAlerts];
                                // トランザクションをクローズ
                                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                            });
                        }];
                        [op start];
                    });
                }
                // XXX 購入トランザクションの場合、購入完了ブロックが実行 or 明示的なトランザクションクローズが実行されるまで、自動トランザクションクローズはしない！
            }
            else {
                // それ以外は無効なレシートとしてエラー処理
                NSLog(@"faild productID=%@", transaction.payment.productIdentifier);
                NSLog(@"faild transactionID=%@", transaction.transactionIdentifier);
                NSLog(@"%@", transaction.payment.requestData.JSONValue);
                // Purchaseの失敗通知
                if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyFinishFaildTransaction:)]){
                    // 購入失敗を通知(メインスレッドで実行)
                    [self.delegate performSelectorOnMainThread:@selector(notifyFinishFaildTransaction:) withObject:transaction waitUntilDone:NO];
                }
                else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyFinishFaildTransaction:)]){
                    // 購入失敗を通知(メインスレッドで実行)
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [[UIApplication sharedApplication].delegate performSelector:@selector(notifyFinishFaildTransaction:) withObject:transaction];
                    });
                }
                else {
                    // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
                    [MPurchaseAgent showAlert:transaction.error.localizedDescription :YES];
                }
                // 失敗ブロックを実行
                MPurchaseDelegateBlock block = (MPurchaseDelegateBlock)[purchaseFinishDic objectForKey:transaction.payment.productIdentifier];
                if (block)
                {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                            block(transaction, nil, nil, YES, nil, ^{
                                NSLog(@"finishFaildTransaction=%@", [transaction description]);
                                NSLog(@"productID=%@", transaction.payment.productIdentifier);
                                NSLog(@"transactionID=%@", transaction.transactionIdentifier);
                                // アラートを全て閉じる
                                //[MPurchaseAgent hideAlerts];
                                // トランザクションをクローズ
                                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                            });
                        }];
                        [op start];
                    });
                }
                // XXX 購入トランザクションの場合、購入完了ブロックが実行 or 明示的なトランザクションクローズが実行されるまで、自動トランザクションクローズはしない！
                // XXX ココを経由する場合、単純にレシートベリファイのタイムアウトもあり得るので、トランザクションは活かしておいて上げている
            }
        }];
    }
}

/* リストアの終了処理 */
- (void)finishRestoreTransaction:(SKPaymentTransaction *)transaction
{
    // トランザクション判定
    NSLog(@"productID=%@", transaction.payment.productIdentifier);
    NSLog(@"transactionID=%@", transaction.transactionIdentifier);
    NSLog(@"%@", transaction.payment.requestData.JSONValue);
    //トランザクションを終了
    if (![transaction isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
        // アラートを全て閉じる
        [MPurchaseAgent hideAlerts];
        // トランザクションが無いので無視して終了
        return;
    }
    // アラート出てないかもしれないので出しとく(既に出てたら出ない)
    [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_WAIT_KEY, @"APP STOREに確認中...") :NO];
    // APPLEベリファイ（レシートの中身を取得するため）
    [self verifyReceipt:transaction :YES :^(NSDictionary *receiptDic) {
        // 一旦、アラートを全て閉じる
        //[MPurchaseAgent hideAlerts];
        // リストア終了判定
        NSLog(@"RESTORE FINISH : %@", receiptDic);
        if (nil != receiptDic){
            // リストアの終了通知
            if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyFinishRestoreTransaction:::::)]){
                // 購入の正常完了を通知(メインスレッドで実行)
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.delegate notifyFinishRestoreTransaction:transaction :[receiptDic objectForKey:@"status"] :[[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0] :((nil ==[receiptDic objectForKey:@"expired"] || [[receiptDic objectForKey:@"expired"] isEqualToString:@"1"]) ? YES : NO) :[receiptDic objectForKey:@"last_expired_date"]];
                });
            }
            else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyFinishRestoreTransaction:::::)]){
                // 購入開始の通知(メインスレッドで実行)
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [(NSObject<MPurchaseDelegate>*)[UIApplication sharedApplication].delegate notifyFinishRestoreTransaction:transaction :[receiptDic objectForKey:@"status"] :[[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0] :((nil ==[receiptDic objectForKey:@"expired"] || [[receiptDic objectForKey:@"expired"] isEqualToString:@"1"]) ? YES : NO) :[receiptDic objectForKey:@"last_expired_date"]];
                });
            }
            // リストア完了ブロックを実行
            MPurchaseDelegateBlock block = (MPurchaseDelegateBlock)[restoreFinishDic objectForKey:transaction.payment.productIdentifier];
            if (block){
                dispatch_async(dispatch_get_main_queue(), ^ {
                    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                        block(transaction, [receiptDic objectForKey:@"status"], [[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] base64EncodedStringWithOptions:0], ((nil ==[receiptDic objectForKey:@"expired"] || [[receiptDic objectForKey:@"expired"] isEqualToString:@"1"]) ? YES : NO), [receiptDic objectForKey:@"last_expired_date"], ^{
                            NSLog(@"finishRestoreTransaction=%@", [transaction description]);
                            NSLog(@"productID=%@", transaction.payment.productIdentifier);
                            NSLog(@"transactionID=%@", transaction.transactionIdentifier);
                            // トランザクションをクローズ
                            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                            // 全てのリストアが終了したかどうかを判定
                            restoreCnt++;
                            if (0 < restoreAll && restoreAll == restoreCnt) {
                                // paymentQueueRestoreCompletedTransactionsFinishedをもう一度呼ぶ
                                [self paymentQueueRestoreCompletedTransactionsFinished];
                            }
                        });
                    }];
                    [op start];
                });
            }
            else {
                // ゴミトランザクションなので、クローズしてしまう
                // エラーとはしない
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // 全てのリストアが終了したかどうかを判定
                restoreCnt++;
                if (0 < restoreAll && restoreAll == restoreCnt) {
                    // paymentQueueRestoreCompletedTransactionsFinishedをもう一度呼ぶ
                    [self paymentQueueRestoreCompletedTransactionsFinished];
                }
            }
        }
        else {
            // ゴミトランザクションなので、クローズしてしまう
            // エラーとはしない
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // 全てのリストアが終了したかどうかを判定
            restoreCnt++;
            if (0 < restoreAll && restoreAll == restoreCnt) {
                // paymentQueueRestoreCompletedTransactionsFinishedをもう一度呼ぶ
                [self paymentQueueRestoreCompletedTransactionsFinished];
            }
        }
    }];
}

/* キャンセル処理 */
- (void)finishCancelTransaction:(SKPaymentTransaction *)transaction
{
    // キャンセル
    NSLog(@"productID=%@", transaction.payment.productIdentifier);
    NSLog(@"transactionID=%@", transaction.transactionIdentifier);
    NSLog(@"%@", transaction.payment.requestData.JSONValue);
    //トランザクションが残っていたら削除
    if (![transaction isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
        // アラートを全て閉じる
        [MPurchaseAgent hideAlerts];
        // トランザクションが無いので無視して終了
        return;
    }
    // アラートを全て閉じる
//    [MPurchaseAgent hideAlerts];
    // キャンセル通知
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyFinishCancelTransaction:)]){
        // キャンセル終了を通知(メインスレッドで実行)
        // XXX キャンセルのインターフェースはトランザクション、プロダクトタイプ じゃね？？
        [self.delegate performSelectorOnMainThread:@selector(notifyFinishCancelTransaction:) withObject:transaction waitUntilDone:NO];
    }
    else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyFinishCancelTransaction:)]){
        // 購入開始の通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication].delegate performSelector:@selector(notifyFinishCancelTransaction:) withObject:transaction];
        });
    }
    else {
        // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
//        [MPurchaseAgent showAlert:transaction.error.localizedDescription :YES];
        [MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_CHANCEL_KEY, @"購入処理がキャンセルされました。再度お手続きをしてください。") :YES];
    }
    // 失敗ブロックを実行
    MPurchaseDelegateBlock block = (MPurchaseDelegateBlock)[purchaseFinishDic objectForKey:transaction.payment.productIdentifier];
    if (block)
    {
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                block(transaction, nil, nil, YES, nil, ^{
                    NSLog(@"finishCancelTransaction=%@", [transaction description]);
                    NSLog(@"productID=%@", transaction.payment.productIdentifier);
                    NSLog(@"transactionID=%@", transaction.transactionIdentifier);
                    // トランザクションをクローズ
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                });
            }];
            [op start];
        });
    }
    else {
        // トランザクションをクローズ
        // エラーとはしない
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

/* 購入承認待処理 */
- (void)finishDeferredTransaction:(SKPaymentTransaction *)transaction
{
    // 購入承認待
    NSLog(@"productID=%@", transaction.payment.productIdentifier);
    NSLog(@"transactionID=%@", transaction.transactionIdentifier);
    NSLog(@"%@", transaction.payment.requestData.JSONValue);

    // トランザクションは終了させない！！

    // アラートを全て閉じる
//    [MPurchaseAgent hideAlerts];
    // 承認待ち通知
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyFinishDeferredTransaction:)]){
        // 承認待ちを受け取って終了した事を通知(メインスレッドで実行)
        [self.delegate performSelectorOnMainThread:@selector(notifyFinishDeferredTransaction:) withObject:transaction waitUntilDone:NO];
    }
    else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyFinishDeferredTransaction:)]){
        // 購入開始の通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication].delegate performSelector:@selector(notifyFinishDeferredTransaction:) withObject:transaction];
        });
    }
    else {
        // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
        [MPurchaseAgent showAlert:transaction.error.localizedDescription :YES];
    }
}


#pragma mark - SKPaymentQueue Transaction delegate

/* トランザクションの更新通知 デレゲート */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    // uncomplateを何度も処理しない為の配列
    NSMutableDictionary *unComplateProductIDs = [[NSMutableDictionary alloc] init];

    // 下記のケースでAppleからトランザクションが渡される。渡される順番は保証されていない？過去分から？
    // - アプリ起動時に中断されたトランザクションがある
    // - 購入トランザクション開始
    // - リストアトランザクション開始（リストア可能アイテムの購入分全て）
    // - 定期購読で更新分のトランザクションが通知された場合（要は毎月,SandBoxなら約５分毎）

    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"status =%d", (int)transaction.transactionState);
        NSLog(@"status product=%@", transaction.payment.productIdentifier);
        NSLog(@"transactionID=%@", transaction.transactionIdentifier);

        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                // 購入時のトランザクションの場合、またはその再開
                //[MPurchaseAgent showAlert:NSLocalizedString(PURCHASE_NOW_WAIT_KEY, @"購入手続き中...") :NO];
                break;
            case SKPaymentTransactionStatePurchased:
                // 購入時のトランザクションの場合、またはその再開
                if (![[unComplateProductIDs objectForKey:transaction.payment.productIdentifier] isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
                    // 消耗型以外は何度も処理しないように制御
                    NSString *productType = (NSString *)[productTypeDic objectForKey:transaction.payment.productIdentifier];
                    if(nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]]){
                        [unComplateProductIDs setObject:transaction forKey:transaction.payment.productIdentifier];
                    }
                    [self performSelectorInBackground:@selector(finishPurchaseTransaction:) withObject:transaction];
                }
                else {
                    // ゴミトランザクションなので終了してしまう
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                }
                break;
            case SKPaymentTransactionStateRestored:
                restoreAll++;
                // リストア時のトランザクションの場合、またはその再開
                if (![[unComplateProductIDs objectForKey:transaction.payment.productIdentifier] isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
                    // 消耗型以外は何度も処理しないように制御
                    NSString *productType = (NSString *)[productTypeDic objectForKey:transaction.payment.productIdentifier];
                    if(nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]]){
                        [unComplateProductIDs setObject:transaction forKey:transaction.payment.productIdentifier];
                    }
                    [self performSelectorInBackground:@selector(finishRestoreTransaction:) withObject:transaction];
                }
                else {
                    // ゴミトランザクションなので終了してしまう
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    restoreCnt++;
                }
                break;
            case SKPaymentTransactionStateFailed:
                // キャンセルボタンを押下した場合、またはその他のエラーが発生した場合
                if (![[unComplateProductIDs objectForKey:transaction.payment.productIdentifier] isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
                    // 消耗型以外は何度も処理しないように制御
                    NSString *productType = (NSString *)[productTypeDic objectForKey:transaction.payment.productIdentifier];
                    if(nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]]){
                        [unComplateProductIDs setObject:transaction forKey:transaction.payment.productIdentifier];
                    }
                    [self performSelectorInBackground:@selector(finishCancelTransaction:) withObject:transaction];
                    //[self performSelectorInBackground:@selector(removeUncompleteTransactionWithIdentifier:) withObject:transaction.transactionIdentifier];
                }
                break;
            case SKPaymentTransactionStateDeferred:
                // 家族共有で承認待ち状態になった場合
                // キャンセルボタンを押下した場合、またはその他のエラーが発生した場合
                if (![[unComplateProductIDs objectForKey:transaction.payment.productIdentifier] isKindOfClass:NSClassFromString(@"SKPaymentTransaction")]) {
                    // 消耗型以外は何度も処理しないように制御
                    NSString *productType = (NSString *)[productTypeDic objectForKey:transaction.payment.productIdentifier];
                    if(nil != productType && ![productType isEqualToString:[NSString stringWithFormat:@"%d", MProductConsumable]]){
                        [unComplateProductIDs setObject:transaction forKey:transaction.payment.productIdentifier];
                    }
                    // とりあえず挙動が分からないのでキャンセルアクション、復帰はリストアに任せる
                    [self performSelectorInBackground:@selector(finishDeferredTransaction:) withObject:transaction];
                    //[self performSelectorInBackground:@selector(removeUncompleteTransactionWithIdentifier:) withObject:transaction.transactionIdentifier];
                }
                break;
            default:
                break;
        }
    }
}

/* リストアの失敗 デレゲート */
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    //SKRequestの失敗を、appDelegateに通知
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyRestoreError::)]){
        // リストアの失敗を通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.delegate notifyRestoreError:queue :error];
        });
    }
    else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyRestoreError::)]){
        // 購入開始の通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication].delegate performSelector:@selector(notifyRestoreError::) withObject:queue withObject:error];
        });
    }
    else {
        // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
        [MPurchaseAgent showAlert:NSLocalizedString(RESTORE_CHANCEL_KEY, @"復元処理がキャンセルされました。再度お手続きをしてください。") :YES];
    }
}

/* 全てのリストアの終了 デレゲート */
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    // queueを保存
    lastRestoreQueue = queue;
    NSLog(@"restoreCnt=%d", restoreCnt);
    NSLog(@"restoredCnt=%d", restoredCnt);
    NSLog(@"restoreAll=%d", restoreAll);
    if (0 == restoreAll && 0 == restoreAll && 0 == restoreCnt) {
        // 初回購入扱いとする
        NSLog(@"first purchase!");
        [self paymentQueueRestoreCompletedTransactionsFinished];
    }
    // 実際のリストア処理と同期が取れていないので、一旦終了とする
    return;
}

/* 実際の全てのリストアの終了通知 */
- (void)paymentQueueRestoreCompletedTransactionsFinished
{
//    if (nil == lastRestoreQueue){
//        // 再起動時などは、paymentQueueRestoreCompletedTransactionsFinishedが呼ばれないのでココで擬似的に再現させる
//        // 再起動時はリストアトランザクションが一つ勝手に増える。なので、ココで擬似再現してしまても問題ない
//        [self paymentQueueRestoreCompletedTransactionsFinished:[SKPaymentQueue defaultQueue]];
//        // 擬似再現して終了
//        return;
//    }
    NSLog(@"restoreCnt=%d", restoreCnt);
    NSLog(@"restoredCnt=%d", restoredCnt);
    NSLog(@"restoreAll=%d", restoreAll);

    if (nil != lastRestoreQueue && nil != currentProduct){
        BOOL restore = NO;
        if (0 < restoredCnt){
            for (SKPaymentTransaction *transaction in lastRestoreQueue.transactions) {
                NSLog(@"transaction.payment.productIdentifier=%@", transaction.payment.productIdentifier);
                NSLog(@"currentProduct.productIdentifier=%@", currentProduct.productIdentifier);
                // プロダクトIDが一致した場合
                if ([transaction.payment.productIdentifier isEqualToString:currentProduct.productIdentifier]) {
                    // 復元出来るので、復元処理をする
                    restore = YES;
                }
            }
        }
        if (NO == restore){
            //購入手続きに移行
            [self startPurchase:currentProduct];
            // 購入を開始したので、リストア処理を終了
            return;
        }
    }

    // リストアの終了通知
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(notifyRestoreCompleate::)]){
        // 全てのリストアの終了を通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.delegate notifyRestoreCompleate:lastRestoreQueue :[NSNumber numberWithInt:restoredCnt]];
        });
    }
    else if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(notifyRestoreCompleate::)]){
        // 購入開始の通知(メインスレッドで実行)
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication].delegate performSelector:@selector(notifyRestoreCompleate::) withObject:lastRestoreQueue withObject:[NSNumber numberWithInt:restoredCnt]];
        });
    }
    else {
        // 通知先のメソッドが無い場合は、ステータスアラートを取り敢えず出しておいてあげる
        // 全リストア成功 or リストア可能なアイテムナシ
        NSString *baseMsg = NSLocalizedString(RESTORE_COMPLETE_ERROR_KEY, @"復元可能なアイテムがありませんでした。");
        if (0 < restoredCnt) {
            // リストア可能なプロダクトがなかった場合
            baseMsg = NSLocalizedString(RESTORE_COMPLETE_ALL_KEY, @"全ての復元可能なアイテムを復元しました。");
            if (nil != lastRestoreQueue && nil != currentProduct){
                baseMsg = NSLocalizedString(RESTORE_COMPLETE_KEY, @"購入を復元しました。\r\n他の全ての復元可能なアイテムを復元しました。");
            }
        }
        [MPurchaseAgent showAlert:baseMsg :YES];
    }
}


#pragma mark - SKReceiptRefreshRequest delegate

- (void)requestDidFinish:(MSKReceiptRefreshRequest *)request
{
    NSLog(@"request.receiptProperties.count=%d", (int)request.receiptProperties.count);
    [request finishRefresh];
}

- (void)request:(MSKReceiptRefreshRequest *)request didFailWithError:(NSError *)error
{
    [request finishFail];
}

#pragma mark - Private static methods

+ (NSDate *)getNSDateFromRFC3339String:(NSString *)rfc3339
{
    // Date and Time representation in RFC3399:
    // Pattern #1: "YYYY-MM-DDTHH:MM:SSZ"
    //                      1
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|Z]
    //
    // Pattern #2: "YYYY-MM-DDTHH:MM:SS.sssZ"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|.|s|s|s|Z]
    //   NOTE: The number of digits in the "sss" part is not defined.
    //
    // Pattern #3: "YYYY-MM-DDTHH:MM:SS+HH:MM"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|+|H|H|:|M|M]
    //
    // Pattern #4: "YYYY-MM-DDTHH:MM:SS.sss+HH:MM"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|.|s|s|s|+|H|H|:|M|M]
    //   NOTE: The number of digits in the "sss" part is not defined.
    
    // NSDate format: "YYYY-MM-DD HH:MM:SS +HHMM".
    
    NSCharacterSet *setOfT = [NSCharacterSet characterSetWithCharactersInString:@"tT"];
    NSRange tMarkPos = [rfc3339 rangeOfCharacterFromSet:setOfT];
    if (tMarkPos.location == NSNotFound) return nil;
    
    // extract date and time part:
    NSString *datePart = [rfc3339 substringToIndex:tMarkPos.location];
    NSString *timePart = [rfc3339 substringWithRange:NSMakeRange(tMarkPos.location + tMarkPos.length, 8)];
    NSString *restPart = [rfc3339 substringFromIndex:tMarkPos.location + tMarkPos.length + 8];
    
    // extract time offset part:
    NSString *tzSignPart, *tzHourPart, *tzMinPart;
    NSCharacterSet *setOfZ = [NSCharacterSet characterSetWithCharactersInString:@"zZ"];
    NSRange tzPos = [restPart rangeOfCharacterFromSet:setOfZ];
    if (tzPos.location == NSNotFound) { // Pattern #3 or #4
        NSCharacterSet *setOfSign = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
        NSRange tzSignPos = [restPart rangeOfCharacterFromSet:setOfSign];
        if (tzSignPos.location == NSNotFound) return nil;
        
        tzSignPart = [restPart substringWithRange:tzSignPos];
        tzHourPart = [restPart substringWithRange:NSMakeRange(tzSignPos.location + tzSignPos.length, 2)];
        tzMinPart = [restPart substringFromIndex:tzSignPos.location + tzSignPos.length + 2 + 1];
    } else { // Pattern #1 or #2
        // "Z" means UTC.
        tzSignPart = @"+";
        tzHourPart = @"00";
        tzMinPart = @"00";
    }
    
    // construct a date string in the NSDate format
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@ %@%@%@", datePart, timePart, tzSignPart, tzHourPart, tzMinPart];

    // 現在日時
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 和暦回避
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss %@%@%@", tzSignPart, tzHourPart, tzMinPart]];

    return [dateFormatter dateFromString:dateStr];
}

@end

