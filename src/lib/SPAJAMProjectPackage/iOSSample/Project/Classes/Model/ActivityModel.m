//
//  ActivityModel.m
//  自由に拡張可能です
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import "ActivityModel.h"

@implementation ActivityModel

/* オーバーライド */
- (id)init;
{
    self = [super init:PROTOCOL :DOMAIN_NAME :URL_BASE :COOKIE_TOKEN_NAME :SESSION_CRYPT_KEY :SESSION_CRYPT_IV :DEVICE_TOKEN_KEY_NAME :TIMEOUT];
    return self;
}

- (BOOL)load:(RequestCompletionHandler)argCompletionHandler;
{
    myResourcePrefix = @"";
    completionHandler = argCompletionHandler;
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setValue:APPDELEGATE.ownerID forKey:@"user_id"];
    return [self _load:listedResource :query];
}

@end
