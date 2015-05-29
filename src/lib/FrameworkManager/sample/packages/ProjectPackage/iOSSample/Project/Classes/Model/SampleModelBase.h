//
//  SampleModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface SampleModelBase : ProjectModelBase
{
    NSString *name;
    NSString *owner_id;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *owner_id;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;


@end
