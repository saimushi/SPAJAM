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
    BOOL familiar_id_replaced;
    BOOL familiar_count_replaced;
    BOOL exp_replaced;
    BOOL created_replaced;
    BOOL modified_replaced;
    BOOL available_replaced;

}

@synthesize name;
@synthesize uniq_name;
@synthesize familiar_id;
@synthesize familiar_count;
@synthesize exp;
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

-(void)setFamiliar_id:(NSString *)argFamiliar_id
{
    familiar_id = argFamiliar_id;
    familiar_id_replaced = YES;
    replaced = YES;
}

-(void)setFamiliar_count:(NSString *)argFamiliar_count
{
    familiar_count = argFamiliar_count;
    familiar_count_replaced = YES;
    replaced = YES;
}

-(void)setExp:(NSString *)argExp
{
    exp = argExp;
    exp_replaced = YES;
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
        familiar_id_replaced = NO;
        familiar_count_replaced = NO;
        exp_replaced = NO;
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
        if(YES == familiar_id_replaced){
            [saveParams setValue:self.familiar_id forKey:@"familiar_id"];
        }
        if(YES == familiar_count_replaced){
            [saveParams setValue:self.familiar_count forKey:@"familiar_count"];
        }
        if(YES == exp_replaced){
            [saveParams setValue:self.exp forKey:@"exp"];
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
    [newDic setObject:self.familiar_id forKey:@"familiar_id"];
    [newDic setObject:self.familiar_count forKey:@"familiar_count"];
    [newDic setObject:self.exp forKey:@"exp"];
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
    self.familiar_id = [argDataDic objectForKey:@"familiar_id"];
    self.familiar_count = [argDataDic objectForKey:@"familiar_count"];
    self.exp = [argDataDic objectForKey:@"exp"];
    self.created = [argDataDic objectForKey:@"created"];
    self.modified = [argDataDic objectForKey:@"modified"];
    self.available = [argDataDic objectForKey:@"available"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    name_replaced = NO;
    uniq_name_replaced = NO;
    familiar_id_replaced = NO;
    familiar_count_replaced = NO;
    exp_replaced = NO;
    created_replaced = NO;
    modified_replaced = NO;
    available_replaced = NO;

    replaced = NO;
    return;
}

@end
