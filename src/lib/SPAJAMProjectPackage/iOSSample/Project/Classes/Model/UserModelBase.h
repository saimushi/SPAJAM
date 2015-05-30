//
//  UserModelBase.h
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ProjectModelBase.h"

@interface UserModelBase : ProjectModelBase
{
<<<<<<< HEAD
    NSString *name;
    NSString *uniq_name;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uniq_name;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;
=======
    NSString *name;
    NSString *uniq_name;
    NSString *familiar_count;
    NSString *created;
    NSString *modified;
    NSString *available;

}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uniq_name;
@property (strong, nonatomic) NSString *familiar_count;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *available;
>>>>>>> 5d839c7a7ef15b55f4901772ee2dbd3179436d87


@end
