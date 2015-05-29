//
//  CustomAlert.m
//
//  Created by saimushi on 2015/05/25.
//  Copyright (c) 2015年 saimushi. All rights reserved.
//

#import "CustomAlert.h"

@implementation UICustomAlertView
@synthesize completionHandler;
@synthesize singleButtonMode;

- (id)init
{
    self = [super init];
    if (nil != self) {
        self.completionHandler = nil;
        self.singleButtonMode = YES;
    }
    return self;
}

@end


@implementation CustomAlert

static NSObject *_self = nil;

// 単純にアラートを出す。戻り処理無し
+ (void)alertShow:(NSString *)title message:(NSString *)message
{
    if(nil == title){
        title = @"";
    }
    if(nil == message){
        message = NSLocalizedString(@"Fatal Error!\rPlease try restart this application", @"Fatal Error!\rPlease try restart this application");
    }
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // i0S7以前の処理
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
    else {
        // iOS8の処理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        // OKボタン
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        // メインスレッドでpresentViewController！
        dispatch_async(dispatch_get_main_queue(), ^ {
            // 親ビューコンをなんとか検索
            UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
                baseView = baseView.presentedViewController;
            }
            [baseView presentViewController:alertController animated:YES completion:nil];
        });
    }
}

// アラート表示。戻り処理あり。ボタンはOKのみ
+ (void)alertShow:(NSString *)title message:(NSString *)message buttonCenter:(NSString *)buttonCenter completionHandler:(AlertCompletionHandler)completionHandler;
{
    if(nil == title){
        title = @"";
    }
    if(nil == message){
        message = NSLocalizedString(@"Fatal Error!\rPlease try restart this application", @"Fatal Error!\rPlease try restart this application");
    }
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // i0S7以前の処理
        _self = [[CustomAlert alloc] init];
        UICustomAlertView *alert = [[UICustomAlertView alloc] initWithTitle:title message:message
                                                       delegate:_self
                                              cancelButtonTitle:buttonCenter
                                              otherButtonTitles:nil];
        alert.completionHandler = completionHandler;
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        // OKボタン
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCenter style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if(completionHandler){
                completionHandler(YES);
            }
        }]];
        // メインスレッドでpresentViewController！
        dispatch_async(dispatch_get_main_queue(), ^ {
            // 親ビューコンをなんとか検索
            UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
                baseView = baseView.presentedViewController;
            }
            [baseView presentViewController:alertController animated:YES completion:nil];
        });
    }
}

// アラート表示。戻り処理あり。ボタンは渡す
+ (void)alertShow:(NSString *)title message:(NSString *)message buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight completionHandler:(AlertCompletionHandler)completionHandler;
{
    if(nil == title){
        title = @"";
    }
    if(nil == message){
        message = NSLocalizedString(@"Fatal Error!\rPlease try restart this application", @"Fatal Error!\rPlease try restart this application");
    }
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // i0S7以前の処理
        _self = [[CustomAlert alloc] init];
        UICustomAlertView *alert = [[UICustomAlertView alloc] initWithTitle:title message:message
                                                                   delegate:_self
                                                          cancelButtonTitle:buttonLeft
                                                          otherButtonTitles:buttonRight, nil];
        alert.singleButtonMode = NO;
        alert.completionHandler = completionHandler;
       [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        // キャンセルボタン
        [alertController addAction:[UIAlertAction actionWithTitle:buttonLeft style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if(completionHandler){
                completionHandler(NO);
            }
        }]];
        // OKボタン
        [alertController addAction:[UIAlertAction actionWithTitle:buttonRight style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if(completionHandler){
                completionHandler(YES);
            }
        }]];
        // メインスレッドでpresentViewController！
        dispatch_async(dispatch_get_main_queue(), ^ {
            // 親ビューコンをなんとか検索
            UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
                baseView = baseView.presentedViewController;
            }
            [baseView presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:NSClassFromString(@"UICustomAlertView")]) {
        UICustomAlertView *_alertVoew = (UICustomAlertView *)alertView;
        if(nil != _alertVoew.completionHandler){
            if (YES == _alertVoew.singleButtonMode) {
                _alertVoew.completionHandler(YES);
            }
            else {
                switch (buttonIndex) {
                    case 0:
                        // cancelボタンが押された時の処理
                        _alertVoew.completionHandler(NO);
                        break;
                    case 1:
                        _alertVoew.completionHandler(YES);
                        break;
                }
            }
        }
    }
}

@end
