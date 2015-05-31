//
//  ActivityModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface ActivityModelBase : ProjectModelBase
{
    NSString *log;
    NSString *user_id;
    NSString *familiar_id;
    NSString *time;
    NSString *good;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *log;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *familiar_id;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *good;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;


@end
