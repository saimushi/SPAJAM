//
//  NodataCellView.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "NodataCellView.h"

@interface NodataCellView()
{
    // Private
}
@end

@implementation NodataCellView

/* オーバーライド */
- (id)initWithFrame:(CGRect)argFrame
{
    self = [super initWithFrame:argFrame];
    if (self) {
        // レコード名
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ((self.height - 15.0f) / 2.0f) - 50, self.width, 20)];
        label.text = @"No Data";
        label.textColor = [UIColor grayColor];
        label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
    return self;
}

@end
