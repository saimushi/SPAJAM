//
//  OperatorModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "OperatorModelBase.h"

@implementation OperatorModelBase
{
    BOOL name_replaced;
    BOOL mail_replaced;
    BOOL pass_replaced;
    BOOL permission_replaced;

}

@synthesize name;
@synthesize mail;
@synthesize pass;
@synthesize permission;


-(void)setName:(NSString *)argName
{
    name = argName;
    name_replaced = YES;
    replaced = YES;
}

-(void)setMail:(NSString *)argMail
{
    mail = argMail;
    mail_replaced = YES;
    replaced = YES;
}

-(void)setPass:(NSString *)argPass
{
    pass = argPass;
    pass_replaced = YES;
    replaced = YES;
}

-(void)setPermission:(NSString *)argPermission
{
    permission = argPermission;
    permission_replaced = YES;
    replaced = YES;
}



/* オーバーライド */
- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        modelName = @"operator";
        name_replaced = NO;
        mail_replaced = NO;
        pass_replaced = NO;
        permission_replaced = NO;

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
        if(YES == mail_replaced){
            [saveParams setValue:self.mail forKey:@"mail"];
        }
        if(YES == pass_replaced){
            [saveParams setValue:self.pass forKey:@"pass"];
        }
        if(YES == permission_replaced){
            [saveParams setValue:self.permission forKey:@"permission"];
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
    [newDic setObject:self.mail forKey:@"mail"];
    [newDic setObject:self.pass forKey:@"pass"];
    [newDic setObject:self.permission forKey:@"permission"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.ID = [argDataDic objectForKey:@"id"];
    self.name = [argDataDic objectForKey:@"name"];
    self.mail = [argDataDic objectForKey:@"mail"];
    self.pass = [argDataDic objectForKey:@"pass"];
    self.permission = [argDataDic objectForKey:@"permission"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    name_replaced = NO;
    mail_replaced = NO;
    pass_replaced = NO;
    permission_replaced = NO;

    replaced = NO;
    return;
}

@end
