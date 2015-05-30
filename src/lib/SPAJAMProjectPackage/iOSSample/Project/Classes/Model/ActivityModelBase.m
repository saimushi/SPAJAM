//
//  ActivityModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ActivityModelBase.h"

@implementation ActivityModelBase
{
    BOOL log_replaced;
    BOOL user_id_replaced;
    BOOL good_replaced;
    BOOL created_replaced;
    BOOL modified_replaced;
    BOOL available_replaced;

}

@synthesize log;
@synthesize user_id;
@synthesize good;
@synthesize created;
@synthesize modified;
@synthesize available;


-(void)setLog:(NSString *)argLog
{
    log = argLog;
    log_replaced = YES;
    replaced = YES;
}

-(void)setUser_id:(NSString *)argUser_id
{
    user_id = argUser_id;
    user_id_replaced = YES;
    replaced = YES;
}

-(void)setGood:(NSString *)argGood
{
    good = argGood;
    good_replaced = YES;
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
        modelName = @"activity";
        log_replaced = NO;
        user_id_replaced = NO;
        good_replaced = NO;
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
        if(YES == log_replaced){
            [saveParams setValue:self.log forKey:@"log"];
        }
        if(YES == user_id_replaced){
            [saveParams setValue:self.user_id forKey:@"user_id"];
        }
        if(YES == good_replaced){
            [saveParams setValue:self.good forKey:@"good"];
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
    [newDic setObject:self.log forKey:@"log"];
    [newDic setObject:self.user_id forKey:@"user_id"];
    [newDic setObject:self.good forKey:@"good"];
    [newDic setObject:self.created forKey:@"created"];
    [newDic setObject:self.modified forKey:@"modified"];
    [newDic setObject:self.available forKey:@"available"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.ID = [argDataDic objectForKey:@"id"];
    self.log = [argDataDic objectForKey:@"log"];
    self.user_id = [argDataDic objectForKey:@"user_id"];
    self.good = [argDataDic objectForKey:@"good"];
    self.created = [argDataDic objectForKey:@"created"];
    self.modified = [argDataDic objectForKey:@"modified"];
    self.available = [argDataDic objectForKey:@"available"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    log_replaced = NO;
    user_id_replaced = NO;
    good_replaced = NO;
    created_replaced = NO;
    modified_replaced = NO;
    available_replaced = NO;

    replaced = NO;
    return;
}

@end
