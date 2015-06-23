//
//  UIViewControllerBase.h
//
//  Created by saimushi on 2012/10/30.
//  Copyright (c) 2012年 saimushi. All rights reserved.
//

@interface UIViewControllerBase : UIViewController
{
    // Protected
    NSDate *viewStayStartTime;
    NSDate *viewStayEndTime;
    NSString *screenName;
    BOOL isNavigateion;
}

// Public
@property (nonatomic) NSDate *viewStayStartTime;
@property (nonatomic) NSDate *viewStayEndTime;
@property (nonatomic) NSString *screenName;

- (void)dataLoad;

@end
