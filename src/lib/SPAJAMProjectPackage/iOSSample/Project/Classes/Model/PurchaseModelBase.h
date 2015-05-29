//
//  PurchaseModelBase.h
//  GMatch
//
//  Created by saimushi on 2014/10/28.
//

#import "ProjectModelBase.h"
#import "MProductAgent.h"
#import "MPurchaseAgent.h"

@interface PurchaseModelBase : ProjectModelBase <MPurchaseDelegate>
{
    // 必ずセットして下さい！
    NSString *sharedSecret;
}

/* 購入処理の登録(実際の購入処理は走らない！) 実装を参考に、場合によっては継承して独自で実装をして下さい！ */
/* ※課金のトランザクションアップデート(ユーザーの購入アクショントリガーでは無いトリガー)によって、処理を走らせなければならない場合があるので、事前に購入処理のブロック登録をする */
- (void)entryPurchase:(NSString *)argProductID :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplationBlock :(MPurchaseDelegateBlock)argRestoreComplationBlock;
/* 購入処理 実装を参考に、場合によっては継承して独自で実装をして下さい！ */
- (void)purchase:(NSString *)argProductID :(MProductType)argProductType :(MPurchaseDelegateBlock)argPurchaseComplationBlock :(MPurchaseDelegateBlock)argRestoreComplationBlock;
/* 購入処理 事前に購入処理ブロック登録されている前提で、購入処理を即開始する 実装を参考に、場合によっては継承して独自で実装をして下さい！ */
- (void)purchase:(NSString *)argProductID;
/* リストア処理 事前に購入処理ブロック登録されているプロダクトで、リストア出来るものを全てリストアする */
- (void)restore;

@end
