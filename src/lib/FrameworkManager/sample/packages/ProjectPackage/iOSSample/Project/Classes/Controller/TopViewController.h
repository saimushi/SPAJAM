//
//  TopViewController.h
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import "EGORefreshTableHeaderView.h"

@interface TopViewController : UIViewControllerBase <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    // Protected
}

// Public
@property (weak, nonatomic) IBOutlet UITableView *dataListView;


@end
