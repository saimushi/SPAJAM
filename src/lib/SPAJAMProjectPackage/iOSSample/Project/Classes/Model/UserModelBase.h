//
//  UserModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface UserModelBase : ProjectModelBase
{
    NSString *name;
    NSString *uniq_name;
    NSString *familiar_id;
    NSString *familiar_count;
    NSString *exp;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uniq_name;
@property (strong, nonatomic) NSString *familiar_id;
@property (strong, nonatomic) NSString *familiar_count;
@property (strong, nonatomic) NSString *exp;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;


@end
