//
//  DeviceModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "DeviceModelBase.h"

@implementation DeviceModelBase
{
    BOOL udid_replaced;
    BOOL owner_id_replaced;
    BOOL type_replaced;
    BOOL device_token_replaced;
    BOOL created_replaced;
    BOOL modified_replaced;
    BOOL available_replaced;

}

@synthesize udid;
@synthesize owner_id;
@synthesize type;
@synthesize device_token;
@synthesize created;
@synthesize modified;
@synthesize available;


-(void)setUdid:(NSString *)argUdid
{
    udid = argUdid;
    udid_replaced = YES;
    replaced = YES;
}

-(void)setOwner_id:(NSString *)argOwner_id
{
    owner_id = argOwner_id;
    owner_id_replaced = YES;
    replaced = YES;
}

-(void)setType:(NSString *)argType
{
    type = argType;
    type_replaced = YES;
    replaced = YES;
}

-(void)setDevice_token:(NSString *)argDevice_token
{
    device_token = argDevice_token;
    device_token_replaced = YES;
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
        modelName = @"device";
        udid_replaced = NO;
        owner_id_replaced = NO;
        type_replaced = NO;
        device_token_replaced = NO;
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
        if(YES == udid_replaced){
            [saveParams setValue:self.udid forKey:@"udid"];
        }
        if(YES == owner_id_replaced){
            [saveParams setValue:self.owner_id forKey:@"owner_id"];
        }
        if(YES == type_replaced){
            [saveParams setValue:self.type forKey:@"type"];
        }
        if(YES == device_token_replaced){
            [saveParams setValue:self.device_token forKey:@"device_token"];
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
    [newDic setObject:self.udid forKey:@"udid"];
    [newDic setObject:self.owner_id forKey:@"owner_id"];
    [newDic setObject:self.type forKey:@"type"];
    [newDic setObject:self.device_token forKey:@"device_token"];
    [newDic setObject:self.created forKey:@"created"];
    [newDic setObject:self.modified forKey:@"modified"];
    [newDic setObject:self.available forKey:@"available"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.udid = [argDataDic objectForKey:@"udid"];
    self.owner_id = [argDataDic objectForKey:@"owner_id"];
    self.type = [argDataDic objectForKey:@"type"];
    self.device_token = [argDataDic objectForKey:@"device_token"];
    self.created = [argDataDic objectForKey:@"created"];
    self.modified = [argDataDic objectForKey:@"modified"];
    self.available = [argDataDic objectForKey:@"available"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    udid_replaced = NO;
    owner_id_replaced = NO;
    type_replaced = NO;
    device_token_replaced = NO;
    created_replaced = NO;
    modified_replaced = NO;
    available_replaced = NO;

    replaced = NO;
    return;
}

@end
