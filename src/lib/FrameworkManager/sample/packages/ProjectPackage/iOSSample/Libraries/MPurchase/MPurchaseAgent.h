//
//  MPurchaseAgent.h
//
//  Created by saimushi on 2014/11/27.
//  Version:1.0
/**
 * (!)
 * プロジェクト設定のbuild settings -> Search Paths -> Header Search Paths
 * に
 * $(PROJECT_DIR)/Libraries/MPurchase/vendor/include
 * を、追加し
 * OpenSSLのライブラリを使える用にする必要があります！
 *
 * (!!)
 * StoreKit.frameworkを「Link Binary with Librarise」に追加する必要があります！
 *
 *
 *
 *  [How To Use]
 
 // 消耗型の単純な購入処理(ローカルレシートチェックする場合)
 [[MPurchaseAgent sharedInstance] purchaseWithProductID:@"text_purchase_point_1000" :MProductConsumable :^(SKPaymentTransaction *transaction, NSString *verifyStatus, NSString *base64Receipt, BOOL expiered, NSString *expierDateGMTStr, MPurchaseReturnDelegateBlock finishTransaction) {
    // 購入処理の登録
    // トランザクションが成功していれば、購入履歴の送信を持って、プレミアム会員とする
    if (nil != transaction && nil != transaction.payment.productIdentifier && nil != verifyStatus && [verifyStatus isEqualToString:@"0"] && nil != base64Receipt){
        // 購入完了
    }
    else{
        // 購入失敗
    }
    // トランザクションを閉じる
    finishTransaction();

 } :nil];
 *
 */

/* ローカルレシートチェック*/
#import "MVerifyStoreReceipt.h"

/* ストアアイテム参照ライブラリを利用 */
#import "MProductAgent.h"


// ローカライズ用のキー定義
#define PURCHASE_ERROR_KEY @"購入に失敗しました。再度手続きしてください。"
#define STORE_SESSION_ERROR_KEY @"AppStoreとの接続に失敗しました。再度手続きしてください。"
#define RESTORE_ERROR_KEY @"復元処理に失敗しました。再度お手続きをしてください。"
#define RESTORE_CHANCEL_KEY @"復元処理がキャンセルされました。再度お手続きをしてください。"
#define RESTORE_COMPLETE_KEY @"購入を復元しました。\r\n他の全ての復元可能なアイテムを復元しました。"
#define RESTORE_COMPLETE_ALL_KEY @"全ての復元可能なアイテムを復元しました。"
#define RESTORE_COMPLETE_ERROR_KEY @"復元可能なアイテムがありませんでした。"
#define PURCHASE_LIMITED_ERROR_KEY @"アプリ内でのアイテム購入が制限されています。"
#define PURCHASE_NOW_WAIT_KEY @"購入手続き中..."
#define PURCHASE_WAIT_KEY @"APP STOREに確認中..."
#define PURCHASE_FINISH_WAIT_KEY @"購入履歴チェック中..."
#define PURCHASE_CHANCEL_KEY @"購入処理がキャンセルされました。再度お手続きをしてください。"

@class SKPaymentTransaction;
@protocol MPurchaseDelegate;
typedef void (*send_type)(void*, SEL, void*, void*, void*, void*, void*);
typedef void (^MPurchaseReturnDelegateBlock)();
typedef void (^MPurchaseDelegateBlock)(SKPaymentTransaction *transaction, NSString *verifyStatus, NSString *base64Receipt, BOOL expiered, NSString *expierDateGMTStr, MPurchaseReturnDelegateBlock finishTransaction);


@interface MPurchaseAgent : NSObject

// 強参照
@property (nonatomic, unsafe_unretained) NSObject<MPurchaseDelegate>*delegate;

/* インスタンス化メソッド(ローカルレシートチェックを行います) */
+ (id)sharedInstance;
/* リモート(Appleサーバ)レシートチェックを利用する場合のインスタンス化メソッド */
+ (id)sharedInstance:(NSString *)argSharedSecret;

/* スタティックメソッド群:外からの使用も可 */
/* オブザーバーが未スタートだったらスタートさせる(事前登録用) */
+ (void)startPaymentTransactionObserver;
/* 指定トランザクションを終了させられるインターフェース用(トランザクションクローズをコントロールしたい人向け) */
+ (void)finishTransaction:(SKPaymentTransaction *)argTransaction;
/* 外部から全てのトランザクションアラートを非表示に出来るインターフェースを用意 */
+ (void)hideAlerts;

/* レシートチェック(SharedSecretが指定されている場合はリモートチェック or ローカル 自動判別) */
- (void)verifyReceipt:(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
/* リモートレシートチェック */
- (void)verifyReceiptForRemote:(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;
/* ローカルレシートチェック */
- (void)verifyReceiptForLocal:(SKPaymentTransaction *)argTransaction :(BOOL)argRestored :(void (^)(NSDictionary *receiptDic))argCompletion;

/* 購入処理実行(SKProduct) */
- (void)purchaseWithProduct:(SKProduct *)argProduct :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
/* 購入処理実行(プロダクトID文字列) */
- (void)purchaseWithProductID:(NSString *)argProductID :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
/* 事前にentryされたプロダクトの購入処理実行(SKProduct) */
- (void)purchaseWithProduct:(SKProduct *)argProduct;
/* 事前にentryされたプロダクトIDの購入処理実行(プロダクトID文字列) */
- (void)purchaseWithProductID:(NSString *)argProductID;
/* リストア処理実行 */
- (void)restore;

/*
 ※AppDelegateにて、コンプリートブロックと、エラーブロックを、プロダクトID分それぞれ先に登録しておく為のメソッドを提供します。
 この機能は、アップルの購入トランザクションの中断等に置いて、アプリケーションの復帰時に、中断された購入処理を再開し、完了する事に利用出来ます。
 */
/* 購入の登録(SKProduct) */
- (void)entryWithProduct:(SKProduct *)argProduct :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;
/* 購入の登録(プロダクトID文字列) */
- (void)entryWithProductID:(NSString *)argProductID :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplation :(MPurchaseDelegateBlock)argRestoreComplation;

@end


@protocol MPurchaseDelegate  <NSObject>
@optional

/* SKRequestのデレゲートをチェーン */
/* プロダクトID問い合わせ失敗エラー */
- (void)notifySKRequestFailWithError:(NSError *)argError;
/* 購入制限エラー */
- (void)notifyPurchaseLimitedError:(NSString *)argErrorMsg;
/* リストアの失敗、キャンセルエラー */
- (void)notifyRestoreError:(SKPaymentQueue *)argQueue :(NSError *)argError;
/* 全てのリストアの終了通知 */
- (void)notifyRestoreCompleate:(SKPaymentQueue *)argQueue :(NSNumber*)argRestoreCntNumber;

/* MPurchaseの拡張デレゲート */
/* 購入開始通知 */
- (void)notifyStartPurchaseTransaction:(SKProduct *)product;
/* リストア開始通知 */
- (void)notifyStartRestoreTransaction:(SKProduct *)product;
/* 購入完了デレゲートをチェーン */
- (void)notifyFinishPurchaseTransaction:(SKPaymentTransaction *)transaction :(NSString *)verifyStatus :(NSString *)base64Receipt :(BOOL)expiered :(NSDate *)expierDate;
/* 購入失敗デレゲートをチェーン */
- (void)notifyFinishFaildTransaction:(SKPaymentTransaction *)transaction;
/* リストア完了デレゲートをチェーン */
- (void)notifyFinishRestoreTransaction:(SKPaymentTransaction *)transaction :(NSString *)verifyStatus :(NSString *)base64Receipt :(BOOL)expiered :(NSDate *)expierDate;
/* キャンセル完了デレゲートをチェーン */
- (void)notifyFinishCancelTransaction:(SKPaymentTransaction *)transaction;
/* 承認待ちデレゲートをチェーン */
- (void)notifyFinishDeferredTransaction:(SKPaymentTransaction *)transaction;

@end
