//
//  SampleCellView.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "FamiliarCellView.h"

@interface FamiliarCellView()
{
    // Private
}
@end

@implementation FamiliarCellView

- (id)initWithFrame:(CGRect)argFrame WithSampleModel:(FamiliarModel *)argFamiliarModel;
{
    self = [super initWithFrame:argFrame];
    if (self) {
        
        UIImageView *familiaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 8, 46, 47)];
//        [familiaImageView hnk_setImageFromURL:[NSURL URLWithString:self.argFamiliarModel.main_img_url] placeholderImage:blankImage success:^(UIImage *image) {
//            //
//            NSLog(@"succ");
//            profileImageView.image = image;
//        } failure:^(NSError *error) {
//            //
//            NSLog(@"err");
//        }];

        
        // レコード名
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 5, 187, 24)];
        nameLabel.text = [NSString stringWithFormat:@"%@・ファミリア", argFamiliarModel.name];
        nameLabel.textColor = [UIColor grayColor];
        nameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:17];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];

        // 件数
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 25, 210, 33)];
        dateLabel.text = [NSString stringWithFormat:@"%@人",argFamiliarModel.familiar_count];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:dateLabel];

        // >
        UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(271, 11, 10, 13)];
        nextLabel.text = @">";
        nextLabel.textColor = [UIColor grayColor];
        nextLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
        nextLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nextLabel];
        
        // セパレータ
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(5, self.height -5, self.width - 10, 1)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
    return self;
}

@end
