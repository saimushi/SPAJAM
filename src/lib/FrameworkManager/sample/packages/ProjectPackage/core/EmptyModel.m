//
//  %modelName%Model.m
//  自由に拡張可能です
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import "%modelName%Model.h"

@implementation %modelName%Model

/* オーバーライド */
- (id)init;
{
    self = [super init:PROTOCOL :DOMAIN_NAME :URL_BASE :COOKIE_TOKEN_NAME :SESSION_CRYPT_KEY :SESSION_CRYPT_IV :DEVICE_TOKEN_KEY_NAME :TIMEOUT];
    return self;
}

@end
