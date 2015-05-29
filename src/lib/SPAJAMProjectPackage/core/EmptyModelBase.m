//
//  %modelName%ModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "%modelName%ModelBase.h"

@implementation %modelName%ModelBase
{
%flags%
}

%synthesize%

%accesser%

/* オーバーライド */
- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        modelName = @"%tableName%";
%init%
    }
    return self;
}

/* オーバーライド */
- (BOOL)save;
{
    if(YES == replaced){
        NSMutableDictionary *saveParams = [[NSMutableDictionary alloc] init];
%save%
        return [super _save:saveParams];
    }
    // 何もしないで終了
    return YES;
}

- (NSMutableDictionary *)convertModelData;
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
%convert%
    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
%set%
    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
%reset%
    replaced = NO;
    return;
}

@end
