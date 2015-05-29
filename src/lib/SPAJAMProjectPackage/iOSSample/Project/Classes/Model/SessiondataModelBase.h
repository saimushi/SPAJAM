//
//  SessiondataModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface SessiondataModelBase : ProjectModelBase
{
    NSString *identifier;
    NSString *data;
    NSString *modified;

}

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *data;
@property (strong, nonatomic) NSString *modified;


@end
