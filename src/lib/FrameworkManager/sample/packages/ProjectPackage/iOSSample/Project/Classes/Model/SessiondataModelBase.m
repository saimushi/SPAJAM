//
//  SessiondataModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "SessiondataModelBase.h"

@implementation SessiondataModelBase
{
    BOOL identifier_replaced;
    BOOL data_replaced;
    BOOL modified_replaced;

}

@synthesize identifier;
@synthesize data;
@synthesize modified;


-(void)setIdentifier:(NSString *)argIdentifier
{
    identifier = argIdentifier;
    identifier_replaced = YES;
    replaced = YES;
}

-(void)setData:(NSString *)argData
{
    data = argData;
    data_replaced = YES;
    replaced = YES;
}

-(void)setModified:(NSString *)argModified
{
    modified = argModified;
    modified_replaced = YES;
    replaced = YES;
}



/* オーバーライド */
- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        modelName = @"sessiondata";
        identifier_replaced = NO;
        data_replaced = NO;
        modified_replaced = NO;

    }
    return self;
}

/* オーバーライド */
- (BOOL)save;
{
    if(YES == replaced){
        NSMutableDictionary *saveParams = [[NSMutableDictionary alloc] init];
        if(YES == identifier_replaced){
            [saveParams setValue:self.identifier forKey:@"identifier"];
        }
        if(YES == data_replaced){
            [saveParams setValue:self.data forKey:@"data"];
        }
        if(YES == modified_replaced){
            [saveParams setValue:self.modified forKey:@"modified"];
        }

        return [super _save:saveParams];
    }
    // 何もしないで終了
    return YES;
}

- (NSMutableDictionary *)convertModelData;
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    [newDic setObject:self.identifier forKey:@"identifier"];
    [newDic setObject:self.data forKey:@"data"];
    [newDic setObject:self.modified forKey:@"modified"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.identifier = [argDataDic objectForKey:@"identifier"];
    self.data = [argDataDic objectForKey:@"data"];
    self.modified = [argDataDic objectForKey:@"modified"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    identifier_replaced = NO;
    data_replaced = NO;
    modified_replaced = NO;

    replaced = NO;
    return;
}

@end
