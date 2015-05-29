//
//  OperatorModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface OperatorModelBase : ProjectModelBase
{
    NSString *name;
    NSString *mail;
    NSString *pass;
    NSString *permission;

}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *mail;
@property (strong, nonatomic) NSString *pass;
@property (strong, nonatomic) NSString *permission;


@end
