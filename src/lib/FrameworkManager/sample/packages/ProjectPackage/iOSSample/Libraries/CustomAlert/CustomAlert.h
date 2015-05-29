//
//  CustomAlert.h
//
//  Created by saimushi on 2015/05/25.
//  Copyright (c) 2015年 saimushi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef void(^AlertCompletionHandler)(BOOL ok);

@interface UICustomAlertView : UIAlertView <UIAlertViewDelegate>
{
    AlertCompletionHandler completionHandler;
    BOOL singleButtonMode;
}
@property (strong, nonatomic) AlertCompletionHandler completionHandler;
@property (nonatomic) BOOL singleButtonMode;
@end


@interface CustomAlert : NSObject <UIAlertViewDelegate>

// 単純にアラートを表示する(アラートからの戻り処理無しで良い場合)
+ (void)alertShow:(NSString *)title message:(NSString *)message;
// アラート。戻り処理あり。(ハンドラー)
+ (void)alertShow:(NSString *)title message:(NSString *)message buttonCenter:(NSString *)buttonCenter completionHandler:(AlertCompletionHandler)completionHandler;
// アラート。戻り処理あり。(ハンドラー)
+ (void)alertShow:(NSString *)title message:(NSString *)message buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight completionHandler:(AlertCompletionHandler)completionHandler;

@end
