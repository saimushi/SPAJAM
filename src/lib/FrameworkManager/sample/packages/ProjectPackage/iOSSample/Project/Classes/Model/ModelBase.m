//
//  ModelBase.m
//
//  Created by saimushi on 2014/06/17.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ModelBase.h"
#import "AES.h"
#import "SecureUDID.h"
#import "SBJsonAgent.h"
#import "CustomAlert.h"

@implementation ProgressAgent
@synthesize packetSentBytes;
@synthesize totalSentBytes;
@synthesize totalBytes;
@end


@implementation ModelBase

@synthesize sessionDataTask;
@synthesize modelName;
@synthesize ID;
@synthesize index;
@synthesize total;
@synthesize records;
@synthesize delegate;


#pragma mark - モデルをシングルトンインスタンス化する

+ (id)getInstance;
{
	static id sharedInstance = nil;
	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}


#pragma mark - 初期化処理

- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init];
    if(nil != self){
        // 初期化処理
        protocol = argProtocol;
        domain = argDomain;
        urlbase = argURLBase;
        timeout = 10;
        cryptKey = nil;
        cryptIV = nil;
        tokenKeyName = argTokenKeyName;
        deviceTokenKeyName = @"devicetoken";
        modelName = nil;
        ID = nil;
        // 自分のリソースを参照する場合に、特別な修飾子が必要なRESTAPI（例えっばFacebook）の場合に利用し、適宜実装クラスで変更を加えて下さい！
        // XXX デフォルトではme/とします。
        myResourcePrefix = @"me/";
        statusCode = 0;
        index = 0;
        total = 0;
        records = 0;
        replaced = NO;
        // ハンドラBlockは標準ではnilである！
        completionHandler = nil;
        // delegateは標準ではnilである！
        delegate = nil;
        sessionDataTask = nil;
    }
    return self;
}

- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName :(int)argTimeout;
{
    self = [self init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        timeout = argTimeout;
    }
    return self;
}

- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName :(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    self = [self init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        cryptKey = argCryptKey;
        cryptIV = argCryptIV;
    }
    return self;
}

- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName :(NSString *)argCryptKey :(NSString *)argCryptIV :(int)argTimeout;
{
    self = [self init:argProtocol :argDomain :argURLBase :argTokenKeyName :argTimeout];
    if(nil != self){
        cryptKey = argCryptKey;
        cryptIV = argCryptIV;
    }
    return self;
}

- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName :(NSString *)argCryptKey :(NSString *)argCryptIV :(NSString *)argDeviceTokenKeyName :(int)argTimeout;
{
    self = [self init:argProtocol :argDomain :argURLBase :argTokenKeyName :argTimeout];
    if(nil != self){
        cryptKey = argCryptKey;
        cryptIV = argCryptIV;
        deviceTokenKeyName = argDeviceTokenKeyName;
    }
    return self;
}


#pragma mark - 通信処理

/* RESTfulURLの生成*/
- (NSString *)createURLString:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argMyResourcePrefix :(NSString *)argModelName :(NSString *)argResourceID;
{
    NSString *url = @"";
    if(nil != argResourceID){
        // 更新(Put)
        url = [NSString stringWithFormat:@"%@://%@%@%@%@/%@.json", argProtocol, argDomain, argURLBase, argMyResourcePrefix, argModelName, argResourceID];
    }
    else{
        // 新規(POST)
        url = [NSString stringWithFormat:@"%@://%@%@%@%@.json", argProtocol, argDomain, argURLBase, argMyResourcePrefix, argModelName];
    }
    return url;
}

/* モデルを参照する */
- (BOOL)load;
{
//    if(nil == self.ID){
//        // ID無指定は単一モデル参照エラー
//        return NO;
//    }
    return [self _load:myResource :nil];
}

- (BOOL)load:(RequestCompletionHandler)argCompletionHandler;
{
//    if(nil == self.ID){
//        // ID無指定は単一モデル参照エラー
//        return NO;
//    }
    completionHandler = argCompletionHandler;
    return [self _load:myResource :nil];
}

- (BOOL)list;
{
    return [self _load:listedResource :nil];
}

- (BOOL)list:(RequestCompletionHandler)argCompletionHandler;
{
    completionHandler = argCompletionHandler;
    return [self _load:listedResource :nil];
}

- (BOOL)query:(NSMutableDictionary *)argWhereParams;
{
    return [self _load:automaticResource :argWhereParams];
}

- (BOOL)query:(NSMutableDictionary *)argWhereParams :(RequestCompletionHandler)argCompletionHandler;
{
    completionHandler = argCompletionHandler;
    return [self _load:automaticResource :argWhereParams];
}

/* モデルを読み込む */
- (BOOL)_load:(int)argLoadResourceMode :(NSMutableDictionary *)argSaveParams;
{
    // モデルの読み込み(RESTful)
    // 認証を先ずチェック
    if(NO == [self isCertification]){
        // 認証が生きて居ないので、ローカルで認証用のトークンを生成する(登録はREST-APIが勝手にやってくれるバージョンを採用している)
        NSLog(@"no certify");
        NSString *token = [self createToken];
        [Request setCookie:token forKey:tokenKeyName domain:domain];
        [Request saveCookie];
    }
    if(nil != [ModelBase loadDeviceToken]){
        [argSaveParams setObject:[ModelBase loadDeviceToken] forKey:deviceTokenKeyName];
#ifdef DEBUG
        // 通知先はSANDBOXの端末である
        [argSaveParams setObject:@"1" forKey:@"sandbox_enabled"];
#else
        // 通知先はSANDBOXでは無い！端末である
        [argSaveParams setObject:@"0" forKey:@"sandbox_enabled"];
#endif
    }
    // 保存モデルのRESTfulURLを作成
    NSString *url = @"";
    // 通信
    statusCode = 0;
    requested = NO;
    if(myResource == argLoadResourceMode){
        // 単一モデル参照
        url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :self.ID];
        NSLog(@"get url=%@", url);
        if (nil != requestMethod) {
            if ([requestMethod isEqualToString:@"POST"]){
                [Request post:self :url :argSaveParams];
            }
            else if ([requestMethod isEqualToString:@"PUT"]){
                [Request put:self :url :argSaveParams];
            }
        }
        else {
            [Request get:self :url :argSaveParams];
        }
    }
    else if(listedResource == argLoadResourceMode){
        // 配列モデル参照
        url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :nil];
        NSLog(@"get url=%@", url);
        if (nil != requestMethod) {
            if ([requestMethod isEqualToString:@"POST"]){
                [Request post:self :url :argSaveParams];
            }
            else if ([requestMethod isEqualToString:@"PUT"]){
                [Request put:self :url :argSaveParams];
            }
        }
        else {
            [Request get:self :url :argSaveParams];
        }
    }
    else if(nil != self.ID){
        // 単一モデル参照
        url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :self.ID];
        NSLog(@"get url=%@", url);
        if (nil != requestMethod) {
            if ([requestMethod isEqualToString:@"POST"]){
                [Request post:self :url :argSaveParams];
            }
            else if ([requestMethod isEqualToString:@"PUT"]){
                [Request put:self :url :argSaveParams];
            }
        }
        else {
            [Request get:self :url :argSaveParams];
        }
    }
    else {
        // 配列モデル参照
        url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :nil];
        NSLog(@"get url=%@", url);
        if (nil != requestMethod) {
            if ([requestMethod isEqualToString:@"POST"]){
                [Request post:self :url :argSaveParams];
            }
            else if ([requestMethod isEqualToString:@"PUT"]){
                [Request put:self :url :argSaveParams];
            }
        }
        else {
            [Request get:self :url :argSaveParams];
        }
    }
    requestMethod = nil;

    if(nil != completionHandler || nil != delegate){
        // completionHandlerが指定されているので、通信の終了は待たずに正常終了する
        // delegateが指定されているので、通信の終了は待たずに正常終了する
        return YES;
    }
    
    if(NO == requested){
        // 終了を待つ
        float timecount = 0.0f;
        do {
            // 0.2秒置きに通信の終了をチェック
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            timecount += 0.2;
            if(timeout <= (int)timecount){
                // タイムアウト
                break;
            }
        } while (!requested);
    }
    
    NSLog(@"end url=%@", url);
    BOOL returned = NO;
    
    if(YES == requested && YES == (statusCode == 200 || statusCode == 201 || statusCode == 202)){
        returned = YES;
    }
    
    return returned;
}

/* モデルを保存する */
/* // XXX 必ずモデル側でオーバーライド実装して下さい！ */
- (BOOL)save;
{
    return NO;
}

-/* モデルを保存する(BlockでHandlerを受け取れるバージョン) */
 (BOOL)save:(RequestCompletionHandler)argCompletionHandler;
{
    completionHandler = argCompletionHandler;
    return [self save];
}

/* モデルを保存する */
- (BOOL)_save:(NSMutableDictionary *)argSaveParams;
{
    // モデルの保存
    // 認証を先ずチェック
    if(NO == [self isCertification]){
        // 認証が生きて居ないので、ローカルで認証用のトークンを生成する(登録はREST-APIが勝手にやってくれるバージョンを採用している)
        NSLog(@"no certify");
        NSString *token = [self createToken];
        [Request setCookie:token forKey:tokenKeyName domain:domain];
        [Request saveCookie];
    }
    if(nil != [ModelBase loadDeviceToken]){
        [argSaveParams setObject:[ModelBase loadDeviceToken] forKey:deviceTokenKeyName];
#ifdef DEBUG
        // 通知先はSANDBOXの端末である
        [argSaveParams setObject:@"1" forKey:@"sandbox_enabled"];
#else
        // 通知先はSANDBOXでは無い！端末である
        [argSaveParams setObject:@"0" forKey:@"sandbox_enabled"];
#endif
    }
    // 保存モデルのRESTfulURLを作成
    NSString *url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :self.ID];
    // 通信
    statusCode = 0;
    requested = NO;
    if(nil != self.ID){
        // 更新(Put)
        NSLog(@"put url=%@", url);
        if (nil != requestMethod || [requestMethod isEqualToString:@"POST"]){
            [Request post:self :url :argSaveParams];
        }
        else {
            [Request put:self :url :argSaveParams];
        }
    }
    else{
        // 新規(POST)
        NSLog(@"post url=%@", url);
        if (nil != requestMethod || [requestMethod isEqualToString:@"PUT"]){
            [Request put:self :url :argSaveParams];
        }
        else {
            [Request post:self :url :argSaveParams];
        }
    }
    requestMethod = nil;

    if(nil != completionHandler || nil != delegate){
        // completionHandlerが指定されているので、通信の終了は待たずに正常終了する
        // delegateが指定されているので、通信の終了は待たずに正常終了する
        return YES;
    }

    NSLog(@"timeout=%d",timeout);
    if(NO == requested){
        // 終了を待つ
        float timecount = 0.0f;
        do {
            // 0.2秒置きに通信の終了をチェック
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            timecount += 0.2;
            NSLog(@"timecount=%f",timecount);
            if(timeout <= (int)timecount){
                // タイムアウト
                break;
            }
        } while (!requested);
    }

    NSLog(@"end url=%@", url);
    BOOL returned = NO;

    if(YES == requested && YES == (statusCode == 200 || statusCode == 201 || statusCode == 202)){
        returned = YES;
    }
    
    return returned;
}

/* モデルを保存する(ファイルアップロード付き) */
/* XXX 大きいファイルのアップロードには- (BOOL)_save:(NSMutableDictionary *)argSaveParams :(NSURL *)argUploadFilePath;を使って下さい！ */
- (BOOL)_save:(NSMutableDictionary *)argSaveParams :(NSData *)argUploadData :(NSString *)argUploadDataName :(NSString *)argUploadDataContentType :(NSString *)argUploadDataKey;
{
    // モデルの保存
    // 認証を先ずチェック
    if(NO == [self isCertification]){
        // 認証が生きて居ないので、ローカルで認証用のトークンを生成する(登録はREST-APIが勝手にやってくれるバージョンを採用している)
        NSLog(@"no certify");
        NSString *token = [self createToken];
        [Request setCookie:token forKey:tokenKeyName domain:domain];
        [Request saveCookie];
    }
    if(nil != [ModelBase loadDeviceToken]){
        [argSaveParams setObject:[ModelBase loadDeviceToken] forKey:deviceTokenKeyName];
#ifdef DEBUG
        // 通知先はSANDBOXの端末である
        [argSaveParams setObject:@"1" forKey:@"sandbox_enabled"];
#else
        // 通知先はSANDBOXでは無い！端末である
        [argSaveParams setObject:@"0" forKey:@"sandbox_enabled"];
#endif
    }
    // 保存モデルのRESTfulURLを作成
    NSString *url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :self.ID];
    // 通信
    statusCode = 0;
    requested = NO;
    if(nil != self.ID){
        // 更新(Put)
        NSLog(@"put url=%@", url);
        if (nil != requestMethod || [requestMethod isEqualToString:@"POST"]){
            [Request post:self :url :argSaveParams :argUploadData :argUploadDataName :argUploadDataContentType :argUploadDataKey];
        }
        else {
            [Request put:self :url :argSaveParams :argUploadData :argUploadDataName :argUploadDataContentType :argUploadDataKey];
        }
    }
    else{
        // 新規(POST)
        NSLog(@"post url=%@", url);
        if (nil != requestMethod || [requestMethod isEqualToString:@"PUT"]){
            [Request put:self :url :argSaveParams :argUploadData :argUploadDataName :argUploadDataContentType :argUploadDataKey];
        }
        else {
            [Request post:self :url :argSaveParams :argUploadData :argUploadDataName :argUploadDataContentType :argUploadDataKey];
        }
    }
    requestMethod = nil;

    if(nil != completionHandler || nil != delegate){
        // completionHandlerが指定されているので、通信の終了は待たずに正常終了する
        // delegateが指定されているので、通信の終了は待たずに正常終了する
        return YES;
    }
    
    if(NO == requested){
        // 終了を待つ
        float timecount = 0.0f;
        do {
            // 0.2秒置きに通信の終了をチェック
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            timecount += 0.2;
            if(timeout <= (int)timecount){
                // タイムアウト
                break;
            }
        } while (!requested);
    }
    
    NSLog(@"end url=%@", url);
    BOOL returned = NO;
    
    if(YES == requested && YES == (statusCode == 200 || statusCode == 201)){
        returned = YES;
    }

    return returned;
}

/* ファイルを一つのモデルリソースと見立てて保存(アップロード)する */
/* PUTメソッドでのアップロード処理を強制します！ */
- (BOOL)_save:(NSMutableDictionary *)argSaveParams :(NSURL *)argUploadFilePath;
{
    // モデルの保存
    // 認証を先ずチェック
    if(NO == [self isCertification]){
        // 認証が生きて居ないので、ローカルで認証用のトークンを生成する(登録はREST-APIが勝手にやってくれるバージョンを採用している)
        NSLog(@"no certify");
        NSString *token = [self createToken];
        [Request setCookie:token forKey:tokenKeyName domain:domain];
        [Request saveCookie];
    }
    if(nil != [ModelBase loadDeviceToken]){
        [argSaveParams setObject:[ModelBase loadDeviceToken] forKey:deviceTokenKeyName];
#ifdef DEBUG
        // 通知先はSANDBOXの端末である
        [argSaveParams setObject:@"1" forKey:@"sandbox_enabled"];
#else
        // 通知先はSANDBOXでは無い！端末である
        [argSaveParams setObject:@"0" forKey:@"sandbox_enabled"];
#endif
    }
    // 保存モデルのRESTfulURLを作成
    NSString *url = [self createURLString:protocol :domain :urlbase :myResourcePrefix :self.modelName :self.ID];
    // 通信
    statusCode = 0;
    requested = NO;
    if(nil != self.ID){
        // 新規 or 更新(Put)
        NSLog(@"put url=%@", url);
        if (nil != requestMethod || [requestMethod isEqualToString:@"POST"]){
            [Request post:self :url :argSaveParams :argUploadFilePath];
        }
        else {
            [Request put:self :url :argSaveParams :argUploadFilePath];
        }
    }
    else{
        // XXX ID無しのファイルアップロードは出来ない！
        return NO;
    }
    requestMethod = nil;

    if(nil != completionHandler || nil != delegate){
        // completionHandlerが指定されているので、通信の終了は待たずに正常終了する
        // delegateが指定されているので、通信の終了は待たずに正常終了する
        return YES;
    }

    if(NO == requested){
        NSLog(@"timeout=%d",timeout);
        // 終了を待つ
        float timecount = 0.0f;
        do {
            // 0.2秒置きに通信の終了をチェック
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            timecount += 0.2;
            if(timeout <= (int)timecount){
                // タイムアウト
                break;
            }
        } while (!requested);
    }

    NSLog(@"end url=%@", url);
    BOOL returned = NO;

    if(YES == requested && YES == (statusCode == 200 || statusCode == 201 || statusCode == 202)){
        returned = YES;
    }

    return returned;
}

/* 特殊なメソッド1 インクリメント(加算) */
- (BOOL)increment;
{
    return YES;
}
- (BOOL)_increment:(NSMutableDictionary *)argSaveParams;
{
    if(nil != self.ID){
        return [self _save:argSaveParams];
    }
    // インクリメントはID指定ナシはエラー！
    return NO;
}

/* 特殊なメソッド2 デクリメント(減算) */
- (BOOL)decrement;
{
    return YES;
}

- (BOOL)_decrement:(NSMutableDictionary *)argSaveParams;
{
    if(nil != self.ID){
        return [self _save:argSaveParams];
    }
    // インクリメントはID指定ナシはエラー！
    return NO;
}


#pragma mark - 認証関連

/* ログイン認証チェック */
- (BOOL)isCertification;
{
    BOOL expired = NO;
    NSHTTPCookieStorage *aStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [aStorage cookies];
    
    for (NSHTTPCookie *aCookie in cookies) {
        NSDictionary *prop = [aCookie properties];
        NSLog(@"cookie=%@", [prop description]);
        NSString *cookieDomain = [prop objectForKey:NSHTTPCookieDomain];
        NSString *cookieName = [prop objectForKey:NSHTTPCookieName];
        NSLog(@"cookie=%@&%@", cookieDomain, domain);
        if (cookieDomain && ([cookieDomain isEqualToString:domain] || [cookieDomain isEqualToString:[NSString stringWithFormat:@".%@", domain]])) {
            NSString *cookieValue = [prop objectForKey:NSHTTPCookieValue];
            NSLog(@"cookieValue=%@", [cookieValue description]);
            NSLog(@"cookieValueLen=%d", (int)cookieValue.length-14);
            if(cookieName && [cookieName isEqualToString:tokenKeyName] && 40 < cookieValue.length ){
                // 現在日時
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                // 和暦回避
                [dateFormatter setLocale:[NSLocale systemLocale]];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                NSDate *nowdate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:-5]]];
                NSLog(@"now=%@", [nowdate description]);

                // 期限日時
                NSDateFormatter *expireDateFormatter = [[NSDateFormatter alloc] init];
                // 和暦回避
                [expireDateFormatter setLocale:[NSLocale systemLocale]];
                [expireDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [expireDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [expireDateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                NSDate *expiredate = [expireDateFormatter dateFromString:[expireDateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:-1*[DEFAULT_COOKIE_EXPIRED intValue]]]];
                NSLog(@"expire=%@", [expiredate description]);

                // トークンの日付取得
                NSString *tokenExpiredDateStr = [cookieValue substringFromIndex:cookieValue.length - 14];
                NSLog(@"token=%@", tokenExpiredDateStr);
                NSDateFormatter* tokenDateFormatter = [[NSDateFormatter alloc] init];
                // 和暦回避
                [tokenDateFormatter setLocale:[NSLocale systemLocale]];
                [tokenDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [tokenDateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
                [tokenDateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                NSDate* tokenExpired = [tokenDateFormatter dateFromString:tokenExpiredDateStr];
                NSLog(@"tokenExpired=%@", [tokenExpired description]);

                // 日付比較
                NSComparisonResult tokenResult = [tokenExpired compare:nowdate];
                NSComparisonResult expireResult = [tokenExpired compare:expiredate];
                if(NO == expired && tokenResult != NSOrderedAscending && expireResult != NSOrderedAscending){
                    // 有効期限内
                    NSLog(@"Expire!");
                    expired = YES;
                }
                else{
                    // 要らないCookieは消す
                    [prop setValue:[NSDate dateWithTimeIntervalSinceNow:-3600] forKey:NSHTTPCookieExpires];
                    NSHTTPCookie *newCookie = [[NSHTTPCookie alloc] initWithProperties:prop];
                    [aStorage setCookie:newCookie];
                    [aStorage deleteCookie:aCookie];
                }
            }
        }
    }
    
    return expired;
}

- (NSString *)createToken;
{
    // UUIDを使ってOnetimeトークンを発行
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    // 和暦回避
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setCalendar:calendar];
    NSString *gmtdatetime = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"gmtdatetime=%@", gmtdatetime);
    
    NSString *identifier = [SecureUDID UDIDForDomain:domain usingKey:cryptKey];
    [ModelBase saveIdentifier:identifier :cryptKey :cryptIV];
    NSLog(@"identifier=%@", identifier);
    NSLog(@"plainToken=%@", [NSString stringWithFormat:@"%@%@", identifier, gmtdatetime]);
    // 固有識別子を元にトークンを作る
    NSString *token = [NSString stringWithFormat:@"%@%@", [AES encryptHex:[NSString stringWithFormat:@"%@%@", [AES encryptHex:identifier :cryptKey :cryptIV], gmtdatetime] :cryptKey :cryptIV], gmtdatetime];
    NSLog(@"token=%@", token);
    
    // Cookie内のtokenを一旦クリア
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    // Cookie処理ループ
    for(NSHTTPCookie *cookie in [storage cookies]){
        NSDictionary *cookieProperty = [cookie properties];
        if([[cookieProperty objectForKey:NSHTTPCookieDomain] isEqualToString:domain] || [[cookieProperty objectForKey:NSHTTPCookieDomain] isEqualToString:[NSString stringWithFormat:@".%@", domain]]){
            NSLog(@"cookie=%@", [cookie description]);
            [storage deleteCookie:cookie];
        }
    }
    return token;
}

+ (void)saveIdentifier:(NSString *)argIdentifier :(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    [[NSUserDefaults standardUserDefaults] setObject:[AES encryptHex:argIdentifier :argCryptKey :argCryptIV]
                                              forKey:@"identifier"];
}

+ (NSString *)loadIdentifier:(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"identifier"];
    if(nil != identifier){
        return [AES decryptHex:identifier :argCryptKey :argCryptIV];
    }
    return nil;
}

+ (void)saveOwnerID:(NSString *)argIdentifier :(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    if(nil == [ModelBase loadOwnerID:argCryptKey :argCryptIV]){
        [[NSUserDefaults standardUserDefaults] setObject:[AES encryptHex:argIdentifier :argCryptKey :argCryptIV]
                                                  forKey:@"ownerID"];
    }
}

+ (NSString *)loadOwnerID:(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ownerID"];
    if(nil != identifier){
        return [AES decryptHex:identifier :argCryptKey :argCryptIV];
    }
    return nil;
}

+ (void)saveOwnerName:(NSString *)argIdentifier :(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    if(nil == [ModelBase loadOwnerName:argCryptKey :argCryptIV]){
        [[NSUserDefaults standardUserDefaults] setObject:[AES encryptHex:argIdentifier :argCryptKey :argCryptIV]
                                                  forKey:@"ownerName"];
    }
}

+ (NSString *)loadOwnerName:(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ownerName"];
    if(nil != identifier){
        return [AES decryptHex:identifier :argCryptKey :argCryptIV];
    }
    return nil;
}

+ (void)saveOwnerImageURL:(NSString *)argIdentifier :(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    if(nil == [ModelBase loadOwnerImageURL:argCryptKey :argCryptIV]){
        [[NSUserDefaults standardUserDefaults] setObject:[AES encryptHex:argIdentifier :argCryptKey :argCryptIV]
                                                  forKey:@"ownerImageURL"];
    }
}

+ (NSString *)loadOwnerImageURL:(NSString *)argCryptKey :(NSString *)argCryptIV;
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ownerImageURL"];
    if(nil != identifier){
        return [AES decryptHex:identifier :argCryptKey :argCryptIV];
    }
    return nil;
}


#pragma mark - デバイストークン関連

/* デバイストークンの保存 */
+ (void)saveDeviceTokenString:(NSString *)argDeviceToken;
{
    [[NSUserDefaults standardUserDefaults] setObject:argDeviceToken forKey:@"devicetoken"];
}

+ (void)saveDeviceTokenData:(NSData *)argDeviceTokenData;
{
    NSString *deviceToken = [[[[argDeviceTokenData description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
							  stringByReplacingOccurrencesOfString:@">" withString:@""]
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"deviceToken: %@", deviceToken);
    [[self class] saveDeviceTokenString:deviceToken];
}

/* デバイストークンの読み込み */
+ (NSString *)loadDeviceToken;
{
    NSLog(@"devicetoken=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"];
}


#pragma mark - 配列モデルの各種操作

- (BOOL)next;
{
    self.index++;
    if(self.index < self.total){
        [self setModelData:list :self.index];
        return YES;
    }
    // Indexを元に戻す
    self.index--;
    return NO;
}

- (id)objectAtIndex:(int)argIndex;
{
    if(0 < self.total && argIndex <= self.total){
        id nextModel = [[[self class] alloc] init:protocol :domain :urlbase  :tokenKeyName :cryptKey :cryptIV :timeout];
        [nextModel setModelData:list :argIndex];
        [nextModel setRecords:self.records];
        return nextModel;
    }
    return nil;
}

- (void)insertObject:(ModelBase *)argModel :(int)argIndex;
{
    NSMutableArray *newList = [list mutableCopy];
    [newList insertObject:[[argModel convertModelData] mutableCopy] atIndex:argIndex];
    list = newList;
    self.total = (int)[list count];
}

- (void)replaceObject:(ModelBase *)argModel :(int)argIndex;
{
    NSMutableArray *newList = [list mutableCopy];
    [newList replaceObjectAtIndex:argIndex withObject:[[argModel convertModelData] mutableCopy]];
    list = newList;
    self.total = (int)[list count];
}

- (void)addObject:(ModelBase *)argModel;
{
    NSMutableArray *newList = [list mutableCopy];
    [newList addObject:[[argModel convertModelData] mutableCopy]];
    list = newList;
    self.total = (int)[list count];
}

- (void)removeObjectAtIndex:(int)argIndex
{
    NSMutableArray *newList = [list mutableCopy];
    [newList removeObjectAtIndex:argIndex];
    list = newList;
    self.total = (int)[list count];
}

/* 廃止? */
- (id)search:(NSString *)argSearchKey :(NSString *)argSearchValue;
{
    NSPredicate *patternMatchFilter = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d){
        NSDictionary *data = obj;
        if (![[data allKeys] containsObject:argSearchKey] || [[data objectForKey:argSearchKey] isEqual:[NSNull null]]) {
            return NO;
        }
        NSRange range = [[data objectForKey:argSearchKey] rangeOfString:argSearchValue];
        return (range.location != NSNotFound);
    }];
    NSUInteger filteredIndex = [list indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [patternMatchFilter evaluateWithObject:obj];
    }];
    NSLog(@"index=%d", (int)filteredIndex);
    return [self objectAtIndex:(int)filteredIndex];
}

/* モデル側で必ず実装して下さい！ */
- (NSMutableDictionary *)convertModelData;
{
    return nil;
}

- (void)setModelData:(NSMutableArray *)argDataArray;
{
    requestMethod = nil;
    response = nil;
    list = [argDataArray mutableCopy];
    self.total = (int)[list count];
    if(0 < [list count]){
        response = [list objectAtIndex:0];
        [self _setModelData:response];
    }
}

- (void)setModelData:(NSMutableArray *)argDataArray :(int)argIndex;
{
    requestMethod = nil;
    response = nil;
    list = [argDataArray mutableCopy];
    self.total = (int)[list count];
    if(argIndex < [list count]){
        response = [list objectAtIndex:argIndex];
        self.index = argIndex;
        [self _setModelData:response];
    }
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
}

/* モデル側で必ず実装して下さい！ */
- (void)resetReplaceFlagment;
{
    return;
}


#pragma mark - スタティックメソッド系

+(void)showRequestError:(int)argStatusCode;
{
    NSString *errorMsg = NSLocalizedString(@"Time out", @"インターネット接続に失敗しました。");
    if(0 < argStatusCode){
        errorMsg = NSLocalizedString(@"Internal Server Error", @"ご迷惑をお掛けします。\n\nサーバーが致命的なエラーを発生させました。\n最初からやり直すか、それでも改善しない場合はシステム管理会社に問い合わせをして下さい。");
        if(400 == argStatusCode){
            errorMsg = NSLocalizedString(@"Error code 400\rBad Request", @"エラーコード400\n\nデータの入力にあやまりがあるか\nサーバー側の問題により、処理を正常に受付出来ませんでした。\n最初からやり直すか、それでも改善しない場合はシステム管理会社に問い合わせをして下さい。");
        }
        if(401 == argStatusCode){
            errorMsg = NSLocalizedString(@"Error code 401\rUnauthorized", @"エラーコード401\n\n何らかの理由により、認証に失敗しました。\n最初からやり直すか、それでも改善しない場合はシステム管理会社に問い合わせをして下さい。");
        }
        if(404 == argStatusCode){
            errorMsg = NSLocalizedString(@"Error code 404\rNot Found", @"エラーコード404\n\n要求したデータが既に存在しませんでした。\n最初からやり直すか、それでも改善しない場合はシステム管理会社に問い合わせをして下さい。");
        }
        if(503 == argStatusCode){
            errorMsg = NSLocalizedString(@"Error code 503\rService Unavailable", @"エラーコード503\n\nご迷惑をお掛けします。\nサーバーが現在メンテナンス中です。\nしばらく経ってから再度実行して下さい。");
        }
    }
    [CustomAlert alertShow:nil message:errorMsg];
}


#pragma mark - RequestのDelegate関連

// RequestクラスのDelegateメソッド
- (void)didFinishSuccess:(NSHTTPURLResponse *)responseHeader :(NSString *)responseBody;
{
    // Headerにアクセス日時があれば取得
    NSDictionary *headerInfo = responseHeader.allHeaderFields;
    if( [headerInfo.allKeys containsObject:@"Accessed"] ){
        NSString *accessed = [headerInfo objectForKey:@"Accessed"];
        // アクセス日時を更新
        [[NSUserDefaults standardUserDefaults] setObject:accessed forKey:@"accessed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // Headerに強制アップデートフラグがあれば取得
    if( [headerInfo.allKeys containsObject:@"AppMustUpdate"] ){
        NSString *mustUp = [headerInfo objectForKey:@"AppMustUpdate"];
        NSString *mustUpURL = nil;
        if ([headerInfo.allKeys containsObject:@"AppMustUpdateURL"] && 0 < [[headerInfo objectForKey:@"AppMustUpdateURL"] length]) {
            mustUpURL = [headerInfo objectForKey:@"AppMustUpdateURL"];
        }
        // フラグが1なら強制アップデート
        if([mustUp isEqualToString:@"1"]){
            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(didReceiveMustUpdate:)]){
                [[UIApplication sharedApplication].delegate performSelector:@selector(didReceiveMustUpdate:) withObject:mustUpURL];
            }
            else {
                // 通知メソッドが実装されていなければ、アラートを出す
                // XXX URL移動のデレゲート処理は後日！
                [CustomAlert alertShow:nil message:NSLocalizedString(@"Please update new version.", @"アプリケーションを最新版に更新して下さい。")];
            }
        }
    }
    // Headerにバッジ数があれば取得
    if( [headerInfo.allKeys containsObject:@"AppBadgeNum"] ){
        NSString *badgeNum = [headerInfo objectForKey:@"AppBadgeNum"];
        if(0 < badgeNum.length && 0 < [badgeNum intValue]){
            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(didReceiveAppBadgeNum:)]){
                [[UIApplication sharedApplication].delegate performSelector:@selector(didReceiveAppBadgeNum:) withObject:badgeNum];
            }
        }
    }
    // Headerに通知メッセージがあれば取得
    if( [headerInfo.allKeys containsObject:@"AppNotifyMessage"] ){
        NSString *headerMessage = [headerInfo objectForKey:@"AppNotifyMessage"];
        if(0 < headerMessage.length){
            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(didReceiveNotifyMessage:)]){
                [[UIApplication sharedApplication].delegate performSelector:@selector(didReceiveNotifyMessage:) withObject:headerMessage];
            }
        }
    }
    
    NSLog(@"responseBody=%@", responseBody);
    BOOL success = NO;
    statusCode = 500;
    if(nil != responseBody && 0 < [responseBody length]){
        // 通信結果を格納
        statusCode = (int)[responseHeader statusCode];
        // jsonをパース(HBOPのRESTリソースモデルのJSON形式に準拠)
        if(200 == statusCode){
            // 成功時だけ、データの差し替えを行う
            NSMutableArray *data = [[NSMutableArray alloc] init];
            NSMutableDictionary *dic = [SBJsonAgent parse:responseBody];
            if([dic isKindOfClass:NSClassFromString(@"NSMutableDictionary")]){
                [data setObject:dic atIndexedSubscript:0];
            }
            else {
                data = (NSMutableArray *)dic;
            }
            [self setModelData:data];
        }
        else {
            // 元の状態に戻す！
            [self setModelData:list];
        }
        // delegateを呼んで上げる
        if(nil != delegate && [delegate respondsToSelector:@selector(didFinishSuccess:::)]){
            [delegate didFinishSuccess:self :responseHeader :responseBody];
        }
        // ハンドラの実行
        if (nil != completionHandler){
            if(200 == statusCode || 201 == statusCode || 202 == statusCode){
                success = YES;
            }
            completionHandler(success, statusCode, responseHeader, responseBody, nil);
        }
        // 通信終了
        requested = YES;
        // 正常通信だった場合はココで処理終了！
        return;
    }
    // 通信終了(異常)
    requested = YES;
    NSRange range = [responseBody rangeOfString:@",\"validate_error\":"];
    if (range.location != NSNotFound) {
        NSMutableDictionary*json = [SBJsonAgent parse:responseBody];
        [CustomAlert alertShow:nil message:[json objectForKey:@"validate_error"]];
    }
    else {
        [ModelBase showRequestError:statusCode];
    }
    // ハンドラの実行
    if (nil != completionHandler){
        completionHandler(success, statusCode, responseHeader, responseBody, nil);
    }
}

- (void)didFinishError:(NSHTTPURLResponse *)responseHeader :(NSString *)responseBody :(NSError *)failedHandler;
{
    // 元の状態に戻す！
    [self setModelData:list];
    if(nil != delegate && [delegate respondsToSelector:@selector(didFinishError::::)]){
        // delegateを呼んで上げる
        [delegate didFinishError:self :responseHeader :responseBody :failedHandler];
        // delegate指定の場合はココで終了
        return;
    }
    else{
        if(nil != responseHeader){
            // RESTfulな自動的なエラーメッセージハンドリング
            statusCode = (int)responseHeader.statusCode;
        }
        // 通信終了
        requested = YES;
        NSRange range = [responseBody rangeOfString:@",\"validate_error\":"];
        if (range.location != NSNotFound) {
            NSMutableDictionary*json = [SBJsonAgent parse:responseBody];
            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(didReceiveValidateError:)]){
                [[UIApplication sharedApplication].delegate performSelector:@selector(didReceiveValidateError:) withObject:[json objectForKey:@"validate_error"]];
            }
            else {
                // 通知メソッドが実装されていなければ、アラートを出す
                if(json != nil && ![@"" isEqualToString:[json objectForKey:@"validate_error"]]){
                    [CustomAlert alertShow:nil message:[json objectForKey:@"validate_error"]];
                }else{
                    [CustomAlert alertShow:nil message:NSLocalizedString(@"Time out", @"network error")];
                }
            }
        }
        else {
            [ModelBase showRequestError:statusCode];
        }
    }
    // ハンドラの実行
    if (nil != completionHandler){
        completionHandler(NO, statusCode, responseHeader, responseBody, failedHandler);
    }
}

- (void)didChangeProgress:(double)packetBytesSent :(double)totalBytesSent :(double)totalBytesExpectedToSend;
{
    NSLog(@"[bytesSent] %f, [totalBytesSent] %f, [totalBytesExpectedToSend] %f", packetBytesSent, totalBytesSent, totalBytesExpectedToSend);
    NSLog(@"[progress] %f％", ((double)totalBytesSent / (double)totalBytesExpectedToSend) * 100);
    ProgressAgent *progress = [[ProgressAgent alloc] init];
    progress.packetSentBytes = packetBytesSent;
    progress.totalSentBytes = totalBytesSent;
    progress.totalBytes = totalBytesExpectedToSend;
    if(nil != delegate && [delegate respondsToSelector:@selector(didChangeProgress::)]){
        // delegateを呼んで上げる
        [delegate didChangeProgress:self :progress];
    }
    if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(didChangeProgress::)]){
        // delegateを呼んで上げる
        [[UIApplication sharedApplication].delegate performSelector:@selector(didChangeProgress::) withObject:self withObject:progress];
    }
}

@end
