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
        UIImageView *familiaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 47, 47)];
        [familiaImageView hnk_setImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@/image/familiar%@.jpg", PROTOCOL, DOMAIN_NAME, URL_BASE, argFamiliarModel.ID]] placeholderImage:nil success:^(UIImage *image) {
            //
            NSLog(@"succ");
            familiaImageView.image = image;
        } failure:^(NSError *error) {
            //
            NSLog(@"err");
        }];
        [self addSubview:familiaImageView];

        // レコード名
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 240, 24)];
        nameLabel.text = [NSString stringWithFormat:@"%@・ファミリア", argFamiliarModel.name];
        nameLabel.textColor = RGBA(230, 197, 107, 1);
        nameLabel.font = [UIFont boldSystemFontOfSize:15];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];

        // 件数
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 20, 240, 33)];
        dateLabel.text = [NSString stringWithFormat:@"%@人",argFamiliarModel.familiar_count];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont boldSystemFontOfSize:13];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:dateLabel];

        // >
        /*
        UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(271, 11, 10, 13)];
        nextLabel.text = @">";
        nextLabel.textColor = [UIColor grayColor];
        nextLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
        nextLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nextLabel];
         */
        
        // セパレータ
        UIImage *separatorImage = [UIImage imageNamed:@"devider.png"];
        UIImageView *separator = [[UIImageView alloc] initWithImage:separatorImage];
        separator.x = (self.frame.size.width - separator.frame.size.width) / 2;
        separator.y = self.frame.size.height - separator.frame.size.height;
        [self addSubview:separator];
    }
    return self;
}

@end
