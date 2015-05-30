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
    NSString *good;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *log;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *good;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;


@end
