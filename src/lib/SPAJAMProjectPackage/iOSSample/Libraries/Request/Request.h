//
//  Request.h
//
//  ローディング表示にまつわることは何もしません。
//  ローディング表示はシステムのよってその表示ポリシーが違う為です。
//  その変わり、RequestはDelegateを提供します。
//  Delegateを利用して、システムに合ったローディング表示を実施して下さい。
//
//  Created by saimushi on 14/06/16.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

typedef void(^RequestCompletionHandler)(BOOL success, NSInteger statusCode, NSHTTPURLResponse *responseHeader, NSString *responseBody, NSError* error);

#define DEFAULT_TIMEOUT 40
#define DEFAULT_COOKIE_EXPIRED @"3600"

@protocol RequestDelegate;

@interface Request : NSObject <NSURLSessionTaskDelegate>
{
	id <RequestDelegate> delegate;
    RequestCompletionHandler completion;
}

@property (strong, nonatomic) id<RequestDelegate> delegate;
@property (strong, nonatomic) RequestCompletionHandler completion;
@property (strong, nonatomic) NSString *userAgent;

// 通常のリクエスト処理
// NSMutableDictionary内のvalueはstringのみ
- (void)start:(NSString *)requestURL :(NSString *)method :(NSMutableDictionary *)requestParams;
// 通常のリクエスト処理に加えて、マルチパートでファイルをPOST(PUT)する
// XXX 大きいファイルのアップロードは次のメソッド- (void)start:(NSString *)requestURL :(NSString *)method :(NSMutableDictionary *)requestParams :(NSURL *)uploadFilePath;を使ってアップロードタスクで実行して下さい！
- (void)start:(NSString *)requestURL :(NSString *)method :(NSMutableDictionary *)requestParams :(NSData *)uploadData :(NSString *)fileName :(NSString *)contentType :(NSString *)dataKeyName;
// 通常のリクエスト処理に加えて、マルチパートでファイルをPOST(PUT)する
// ファイルをアップロードする
// XXX PUTメソッドでアップロードした場合、サーバー側でファイル以外に送信されたPOSTデータを判別出来なくなる事に注意して下さい！
- (void)start:(NSString *)requestURL :(NSString *)method :(NSMutableDictionary *)requestParams :(NSURL *)uploadFilePath;

// 以下スタティックメソッド定義
// アプリ固有のユーザーエージェンを作成
+ (NSString *)createUserAgent;

// support RESTful
// GET リソース参照
+ (void)get:(id)calledClass :(NSString *)requestURL;
+ (void)get:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams;
+ (void)get:(id)calledClass :(NSString *)requestURL withCompletion:(RequestCompletionHandler)argCompletion;
+ (void)get:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams withCompletion:(RequestCompletionHandler)argCompletion;;
// POST リソース追加・更新・インクリメント・デクリメント
+ (void)post:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams;
+ (void)post:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSData *)uploadData :(NSString *)fileName :(NSString *)contentType :(NSString *)dataKeyName;
+ (void)post:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams withCompletion:(RequestCompletionHandler)argCompletion;
+ (void)post:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSData *)uploadData :(NSString *)fileName :(NSString *)contentType :(NSString *)dataKeyName withCompletion:(RequestCompletionHandler)argCompletion;
// ファイルアップロード
+ (void)post:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSURL *)uploadFilePath;
+ (void)post:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSURL *)uploadFilePath withCompletion:(RequestCompletionHandler)argCompletion;
// PUT リソース追加・更新
+ (void)put:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams;
+ (void)put:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSData *)uploadData :(NSString *)fileName :(NSString *)contentType :(NSString *)dataKeyName;
+ (void)put:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams withCompletion:(RequestCompletionHandler)argCompletion;
+ (void)put:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSData *)uploadData :(NSString *)fileName :(NSString *)contentType :(NSString *)dataKeyName withCompletion:(RequestCompletionHandler)argCompletion;
// ファイルアップロード
+ (void)put:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSURL *)uploadFilePath;
+ (void)put:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams :(NSURL *)uploadFilePath withCompletion:(RequestCompletionHandler)argCompletion;
// DELETE リソース削除
+ (void)delete:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams;
+ (void)delete:(id)calledClass :(NSString *)requestURL :(NSMutableDictionary *)requestParams withCompletion:(RequestCompletionHandler)argCompletion;
// HEAD リソース定義参照
+ (void)head:(id)calledClass :(NSString *)requestURL;
+ (void)head:(id)calledClass :(NSString *)requestURL withCompletion:(RequestCompletionHandler)argCompletion;

// Cookie関連
// CookieをCookieStorageにセットする(簡易設定版)
+ (void)setCookie:(NSString *)value forKey:(NSString *)key domain:(NSString *)domain;
// CookieをCookieStorageにセットする(詳細設定版)
+ (void)setCookie:(NSString *)value forKey:(NSString *)key domain:(NSString *)domain cookiePath:(NSString *)path expires:(NSString *)expires;
// CookieをNSUserDefaultから復帰する
+ (void)loadCookie;
// CookieをNSUserDefaultに保存し、永続化する
+ (void)saveCookie;

@end


@protocol RequestDelegate  <NSObject>
@optional
- (void)setSessionDataTask:(NSURLSessionTask *)task;
- (void)didFinishSuccess:(NSHTTPURLResponse *)responseHeader :(NSString *)responseBody;
- (void)didFinishError:(NSHTTPURLResponse *)responseHeader :(NSString *)responseBody :(NSError *)failedHandler;
- (void)didChangeProgress:(double)packetBytesSent :(double)totalBytesSent :(double)totalBytesExpectedToSend;

@end
