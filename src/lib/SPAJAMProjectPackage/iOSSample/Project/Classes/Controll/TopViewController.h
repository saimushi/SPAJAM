//
//  TopViewController.h
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import "EGORefreshTableHeaderView.h"
@import CoreBluetooth;
@import CoreLocation;

@interface TopViewController : UIViewControllerBase <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, UIScrollViewDelegate,CBPeripheralManagerDelegate>
{
    // Protected
}

// Public
-(void)reloadFamiliarData;
-(void)setUserModel:(id)argUserModel;


@end
