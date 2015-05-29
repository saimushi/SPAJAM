//
//  SessionModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface SessionModelBase : ProjectModelBase
{
    NSString *token;
    NSString *created;

}

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *created;


@end
