//
//  FamiliarModelBase.m
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "FamiliarModelBase.h"

@implementation FamiliarModelBase
{
    BOOL name_replaced;
    BOOL info_replaced;
    BOOL god_id_replaced;
    BOOL god_bconudid_replaced;
    BOOL image_replaced;
    BOOL familiar_count_replaced;
    BOOL created_replaced;
    BOOL modified_replaced;
    BOOL available_replaced;

}

@synthesize name;
@synthesize info;
@synthesize god_id;
@synthesize god_bconudid;
@synthesize image;
@synthesize familiar_count;
@synthesize created;
@synthesize modified;
@synthesize available;


-(void)setName:(NSString *)argName
{
    name = argName;
    name_replaced = YES;
    replaced = YES;
}

-(void)setInfo:(NSString *)argInfo
{
    info = argInfo;
    info_replaced = YES;
    replaced = YES;
}

-(void)setGod_id:(NSString *)argGod_id
{
    god_id = argGod_id;
    god_id_replaced = YES;
    replaced = YES;
}

-(void)setGod_bconudid:(NSString *)argGod_bconudid
{
    god_bconudid = argGod_bconudid;
    god_bconudid_replaced = YES;
    replaced = YES;
}

-(void)setImage:(NSString *)argImage
{
    image = argImage;
    image_replaced = YES;
    replaced = YES;
}

-(void)setFamiliar_count:(NSString *)argFamiliar_count
{
    familiar_count = argFamiliar_count;
    familiar_count_replaced = YES;
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
        modelName = @"familiar";
        name_replaced = NO;
        info_replaced = NO;
        god_id_replaced = NO;
        god_bconudid_replaced = NO;
        image_replaced = NO;
        familiar_count_replaced = NO;
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
        if(YES == info_replaced){
            [saveParams setValue:self.info forKey:@"info"];
        }
        if(YES == god_id_replaced){
            [saveParams setValue:self.god_id forKey:@"god_id"];
        }
        if(YES == god_bconudid_replaced){
            [saveParams setValue:self.god_bconudid forKey:@"god_bconudid"];
        }
        if(YES == image_replaced){
            [saveParams setValue:self.image forKey:@"image"];
        }
        if(YES == familiar_count_replaced){
            [saveParams setValue:self.familiar_count forKey:@"familiar_count"];
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
    [newDic setObject:self.info forKey:@"info"];
    [newDic setObject:self.god_id forKey:@"god_id"];
    [newDic setObject:self.god_bconudid forKey:@"god_bconudid"];
    [newDic setObject:self.image forKey:@"image"];
    [newDic setObject:self.familiar_count forKey:@"familiar_count"];
    [newDic setObject:self.created forKey:@"created"];
    [newDic setObject:self.modified forKey:@"modified"];
    [newDic setObject:self.available forKey:@"available"];

    return newDic;
}

- (void)_setModelData:(NSMutableDictionary *)argDataDic;
{
    self.ID = [argDataDic objectForKey:@"id"];
    self.name = [argDataDic objectForKey:@"name"];
    self.info = [argDataDic objectForKey:@"info"];
    self.god_id = [argDataDic objectForKey:@"god_id"];
    self.god_bconudid = [argDataDic objectForKey:@"god_bconudid"];
    self.image = [argDataDic objectForKey:@"image"];
    self.familiar_count = [argDataDic objectForKey:@"familiar_count"];
    self.created = [argDataDic objectForKey:@"created"];
    self.modified = [argDataDic objectForKey:@"modified"];
    self.available = [argDataDic objectForKey:@"available"];

    [self resetReplaceFlagment];
}

- (void)resetReplaceFlagment;
{
    name_replaced = NO;
    info_replaced = NO;
    god_id_replaced = NO;
    god_bconudid_replaced = NO;
    image_replaced = NO;
    familiar_count_replaced = NO;
    created_replaced = NO;
    modified_replaced = NO;
    available_replaced = NO;

    replaced = NO;
    return;
}

@end
