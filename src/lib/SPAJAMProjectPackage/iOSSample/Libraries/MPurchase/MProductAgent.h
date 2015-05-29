//
//  MProductAgent.h
//
//  Created by saimushi on 2014/11/27.
//  Version:1.0


#import <StoreKit/StoreKit.h>


// ローカライズ用のキー定義
#define STORE_GET_ITEM_ERROR_KEY @"store get item error"


// 課金アイテム種別
typedef enum{
    MProductConsumable,// 消耗型
    MProductNonConsumable,// 非消耗型
    MProductAutoRenewableSubscriptions,// 自動更新有料購読
    MProductFreeSubscription,// 無料購読
    MProductNonRenewingSubscription,// 有料購読
} MProductType;


@interface MProductAgent : NSObject<SKProductsRequestDelegate>

//アイテムの情報を取得（複数指定）
+ (id)productsWithProductIdentifiers:(NSSet *)productIdentifiers
                       completeBlock:(void (^)(SKProductsResponse *response))cBlock
                          errorBlock:(void (^)(NSError *error))eBlock;

//アイテムの情報を取得（1つ指定）
+ (id)productWithProductIdentifier:(NSString *)productIdentifier
                     completeBlock:(void (^)(SKProductsResponse *response, SKProduct *product))cBlock
                        errorBlock:(void (^)(NSError *error))eBlock;

@end
