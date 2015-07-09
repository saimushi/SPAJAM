//
//  FwmuserModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "FwmuserModelBase.h"

@implementation FwmuserModelBase
{
    BOOL name_replaced;
    BOOL mail_replaced;
    BOOL pass_replaced;

}

@synthesize name;
@synthesize mail;
@synthesize pass;


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



/* オーバーライド */
- (id)init:(NSString *)argProtocol :(NSString *)argDomain :(NSString *)argURLBase :(NSString *)argTokenKeyName;
{
    self = [super init:argProtocol :argDomain :argURLBase :argTokenKeyName];
    if(nil != self){
        modelName = @"fwmuser";
        name_replaced = NO;
        mail_replaced = NO;
        pass_replaced = NO;

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

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.ID = [argDataDic objectForKey:@"id"];
    self.name = [argDataDic objectForKey:@"name"];
    self.mail = [argDataDic objectForKey:@"mail"];
    self.pass = [argDataDic objectForKey:@"pass"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    name_replaced = NO;
    mail_replaced = NO;
    pass_replaced = NO;

    replaced = NO;
    return;
}

@end
