//
//  SampleCellView.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "SampleCellView.h"

@interface SampleCellView()
{
    // Private
}
@end

@implementation SampleCellView

- (id)initWithFrame:(CGRect)argFrame WithSampleModel:(SampleModel *)argSampleModel;
{
    self = [super initWithFrame:argFrame];
    if (self) {
        // レコード名
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, 15)];
        nameLabel.text = argSampleModel.name;
        nameLabel.textColor = [UIColor grayColor];
        nameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];

        // 日時
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 110, nameLabel.y + nameLabel.height + 5, 100, 10)];
        dateLabel.text = argSampleModel.modified;
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:9];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:dateLabel];
        
        // セパレータ
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(5, self.height -5, self.width - 10, 1)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
    return self;
}

@end
