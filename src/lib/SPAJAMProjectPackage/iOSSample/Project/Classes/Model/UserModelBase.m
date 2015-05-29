//
//  UserModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "UserModelBase.h"

@implementation UserModelBase
{
    BOOL name_replaced;
    BOOL uniq_name_replaced;
    BOOL created_replaced;
    BOOL modified_replaced;
    BOOL available_replaced;

}

@synthesize name;
@synthesize uniq_name;
@synthesize created;
@synthesize modified;
@synthesize available;


-(void)setName:(NSString *)argName
{
    name = argName;
    name_replaced = YES;
    replaced = YES;
}

-(void)setUniq_name:(NSString *)argUniq_name
{
    uniq_name = argUniq_name;
    uniq_name_replaced = YES;
    replaced = YES;
}

-(void)setCreated:(NSString *)argCreated
{
    created = argCreated;
    created_replaced = YES;
    replaced = YES;
}

-(void)setModified:(NSString *)argModified
{
    modified = argModified;
    modified_replaced = YES;
    replaced = YES;
}

-(void)setAvailable:(NSString *)argAvailable
{
    available = argAvailable;
    available_replaced = YES;
    replaced = YES;
}



/* オーバーライド */
- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        modelName = @"user";
        name_replaced = NO;
        uniq_name_replaced = NO;
        created_replaced = NO;
        modified_replaced = NO;
        available_replaced = NO;

    }
    return self;
}

/* オーバーライド */
- (BOOL)save;
{
    if(YES == replaced){
        NSMutableDictionary *saveParams = [[NSMutableDictionary alloc] init];
        if(YES == name_replaced){
            [saveParams setValue:self.name forKey:@"name"];
        }
        if(YES == uniq_name_replaced){
            [saveParams setValue:self.uniq_name forKey:@"uniq_name"];
        }
        if(YES == created_replaced){
            [saveParams setValue:self.created forKey:@"created"];
        }
        if(YES == modified_replaced){
            [saveParams setValue:self.modified forKey:@"modified"];
        }
        if(YES == available_replaced){
            [saveParams setValue:self.available forKey:@"available"];
        }

        return [super _save:saveParams];
    }
    // 何もしないで終了
    return YES;
}

- (NSMutableDictionary *)convertModelData;
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    [newDic setObject:self.ID forKey:@"id"];
    [newDic setObject:self.name forKey:@"name"];
    [newDic setObject:self.uniq_name forKey:@"uniq_name"];
    [newDic setObject:self.created forKey:@"created"];
    [newDic setObject:self.modified forKey:@"modified"];
    [newDic setObject:self.available forKey:@"available"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.ID = [argDataDic objectForKey:@"id"];
    self.name = [argDataDic objectForKey:@"name"];
    self.uniq_name = [argDataDic objectForKey:@"uniq_name"];
    self.created = [argDataDic objectForKey:@"created"];
    self.modified = [argDataDic objectForKey:@"modified"];
    self.available = [argDataDic objectForKey:@"available"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    name_replaced = NO;
    uniq_name_replaced = NO;
    created_replaced = NO;
    modified_replaced = NO;
    available_replaced = NO;

    replaced = NO;
    return;
}

@end
