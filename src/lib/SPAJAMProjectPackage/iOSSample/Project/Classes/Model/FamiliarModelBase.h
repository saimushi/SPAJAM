//
//  FamiliarModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface FamiliarModelBase : ProjectModelBase
{
    NSString *name;
    NSString *info;
    NSString *god_id;
    NSString *god_bconudid;
    NSString *image;
    NSString *familiar_count;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *god_id;
@property (strong, nonatomic) NSString *god_bconudid;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *familiar_count;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;


@end
