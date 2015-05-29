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
    BOOL version_name_replaced;
    BOOL version_code_replaced;
    BOOL device_token_replaced;
    BOOL sandbox_enabled_replaced;
    BOOL created_replaced;
    BOOL modified_replaced;
    BOOL available_replaced;

}

@synthesize udid;
@synthesize owner_id;
@synthesize type;
@synthesize version_name;
@synthesize version_code;
@synthesize device_token;
@synthesize sandbox_enabled;
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

-(void)setVersion_name:(NSString *)argVersion_name
{
    version_name = argVersion_name;
    version_name_replaced = YES;
    replaced = YES;
}

-(void)setVersion_code:(NSString *)argVersion_code
{
    version_code = argVersion_code;
    version_code_replaced = YES;
    replaced = YES;
}

-(void)setDevice_token:(NSString *)argDevice_token
{
    device_token = argDevice_token;
    device_token_replaced = YES;
    replaced = YES;
}

-(void)setSandbox_enabled:(NSString *)argSandbox_enabled
{
    sandbox_enabled = argSandbox_enabled;
    sandbox_enabled_replaced = YES;
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
        version_name_replaced = NO;
        version_code_replaced = NO;
        device_token_replaced = NO;
        sandbox_enabled_replaced = NO;
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
        if(YES == version_name_replaced){
            [saveParams setValue:self.version_name forKey:@"version_name"];
        }
        if(YES == version_code_replaced){
            [saveParams setValue:self.version_code forKey:@"version_code"];
        }
        if(YES == device_token_replaced){
            [saveParams setValue:self.device_token forKey:@"device_token"];
        }
        if(YES == sandbox_enabled_replaced){
            [saveParams setValue:self.sandbox_enabled forKey:@"sandbox_enabled"];
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
    [newDic setObject:self.version_name forKey:@"version_name"];
    [newDic setObject:self.version_code forKey:@"version_code"];
    [newDic setObject:self.device_token forKey:@"device_token"];
    [newDic setObject:self.sandbox_enabled forKey:@"sandbox_enabled"];
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
    self.version_name = [argDataDic objectForKey:@"version_name"];
    self.version_code = [argDataDic objectForKey:@"version_code"];
    self.device_token = [argDataDic objectForKey:@"device_token"];
    self.sandbox_enabled = [argDataDic objectForKey:@"sandbox_enabled"];
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
    version_name_replaced = NO;
    version_code_replaced = NO;
    device_token_replaced = NO;
    sandbox_enabled_replaced = NO;
    created_replaced = NO;
    modified_replaced = NO;
    available_replaced = NO;

    replaced = NO;
    return;
}

@end
