//
//  DeviceModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface DeviceModelBase : ProjectModelBase
{
    NSString *udid;
    NSString *owner_id;
    NSString *type;
    NSString *version_name;
    NSString *version_code;
    NSString *device_token;
    NSString *sandbox_enabled;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *udid;
@property (strong, nonatomic) NSString *owner_id;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *version_name;
@property (strong, nonatomic) NSString *version_code;
@property (strong, nonatomic) NSString *device_token;
@property (strong, nonatomic) NSString *sandbox_enabled;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;


@end
