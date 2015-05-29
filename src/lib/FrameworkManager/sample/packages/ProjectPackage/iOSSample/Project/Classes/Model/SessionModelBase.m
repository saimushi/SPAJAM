//
//  SessionModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "SessionModelBase.h"

@implementation SessionModelBase
{
    BOOL token_replaced;
    BOOL created_replaced;

}

@synthesize token;
@synthesize created;


-(void)setToken:(NSString *)argToken
{
    token = argToken;
    token_replaced = YES;
    replaced = YES;
}

-(void)setCreated:(NSString *)argCreated
{
    created = argCreated;
    created_replaced = YES;
    replaced = YES;
}



/* オーバーライド */
- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        modelName = @"session";
        token_replaced = NO;
        created_replaced = NO;

    }
    return self;
}

/* オーバーライド */
- (BOOL)save;
{
    if(YES == replaced){
        NSMutableDictionary *saveParams = [[NSMutableDictionary alloc] init];
        if(YES == token_replaced){
            [saveParams setValue:self.token forKey:@"token"];
        }
        if(YES == created_replaced){
            [saveParams setValue:self.created forKey:@"created"];
        }

        return [super _save:saveParams];
    }
    // 何もしないで終了
    return YES;
}

- (NSMutableDictionary *)convertModelData;
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    [newDic setObject:self.token forKey:@"token"];
    [newDic setObject:self.created forKey:@"created"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.token = [argDataDic objectForKey:@"token"];
    self.created = [argDataDic objectForKey:@"created"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    token_replaced = NO;
    created_replaced = NO;

    replaced = NO;
    return;
}

@end
