//
//  FamiliarModel.m
//  自由に拡張可能です
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import "FamiliarModel.h"

@implementation FamiliarModel

/* オーバーライド */
- (id)init;
{
    self = [super init:PROTOCOL :DOMAIN_NAME :URL_BASE :COOKIE_TOKEN_NAME :SESSION_CRYPT_KEY :SESSION_CRYPT_IV :DEVICE_TOKEN_KEY_NAME :TIMEOUT];
    myResourcePrefix = @"";
    return self;
}

- (BOOL)list:(RequestCompletionHandler)argCompletionHandler;
{
    completionHandler = argCompletionHandler;
    return [self _load:listedResource :nil];
}

- (BOOL)list;
{
    return [self _load:listedResource :nil];
}

- (BOOL)load:(RequestCompletionHandler)argCompletionHandler widthId:(NSString*)_id;
{
    myResourcePrefix = @"";
    completionHandler = argCompletionHandler;
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setValue:_id forKey:@"id"];
    return [self _load:listedResource :query];
}

- (BOOL)saveImage:(UIImage *)argImage :(RequestCompletionHandler)argCompletionHandler;
{
    if(nil != argImage){
        NSMutableDictionary *saveParams = [[NSMutableDictionary alloc] init];
        [saveParams setValue:self.ID forKey:@"familiar_id"];
        completionHandler = argCompletionHandler;
        return [super _save:saveParams :[[NSData alloc] initWithData:UIImageJPEGRepresentation(argImage, 0.5)] :@"main.jpg" :@"image/jpeg" :@"main_image"];
    }
    // 何もしないで終了
    return YES;
}

@end
