//
//  UIViewControllerBase.h
//
//  Created by saimushi on 2012/10/30.
//  Copyright (c) 2012年 saimushi. All rights reserved.
//

#import "common.h"

@interface UIViewControllerBase()
{
    // Private
}
@end

@implementation UIViewControllerBase

@synthesize viewStayStartTime;
@synthesize viewStayEndTime;
@synthesize screenName;

- (id)init
{
    self = [super init];
    if(self != nil){
        screenName = @"UIViewControllerBase";
        isNavigateion = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [TrackingManager sendScreenTracking:screenName];
    viewStayStartTime = [NSDate date];
    if (isNavigateion){
        self.navigationItem.title = screenName;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // View滞在時間を計測
    viewStayEndTime = [NSDate date];
    // Google Analytics
//    [TrackingManager sendEventTracking:@"StayViewTime" action:screenName label:@"ViewStayTime" value:[[NSNumber alloc]initWithInt:(int)[viewStayEndTime timeIntervalSinceDate:viewStayStartTime]] screen:screenName];
    [super viewDidDisappear:animated];
}

- (void)dataLoad
{
    
}

@end
