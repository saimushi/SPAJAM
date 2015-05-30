//
//  SampleCellView.m
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ActivityCellView.h"

@interface ActivityCellView()
{
    // Private
}
@end

@implementation ActivityCellView

- (id)initWithFrame:(CGRect)argFrame WithSampleModel:(ActivityModel *)argActivityModel;
{
    self = [super initWithFrame:argFrame];
    if (self) {
        
//        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_button"]];
//        bgImageView.x = 0;
//        bgImageView.y = 0;
//        [self addSubview:bgImageView];
        
        // セパレータ用画像
        UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"devider"]];
        separatorImageView.x = 0;
        separatorImageView.y = 0;
        [self addSubview:separatorImageView];
        
        // 階段マーク
        UIImageView *kaidanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_kaidan"]];
        kaidanImageView.x = 30;
        kaidanImageView.y = 25;
        [self addSubview:kaidanImageView];
        
        // Activity
        UILabel *logLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 175, 15)];
        logLabel.text = argActivityModel.log;
        logLabel.textColor =  RGBA(230, 197, 107, 1);
        logLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
        logLabel.backgroundColor = [UIColor clearColor];
        //logLabel.backgroundColor = [UIColor redColor];
        logLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:logLabel];
        
        // 作業時間
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(logLabel.x+logLabel.width+5, 25, 25, 15)];
        timeLabel.text = [NSString stringWithFormat:@"%@h",argActivityModel.time];
        timeLabel.textColor =  RGBA(230, 197, 107, 1);
        timeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
        timeLabel.backgroundColor = [UIColor clearColor];
        //timeLabel.backgroundColor = [UIColor blueColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:timeLabel];

        // 星
        NSString *starFileName;
        if([@"0" isEqual:argActivityModel.good]){
            starFileName = @"icon_star_gray";
        }else{
            starFileName = @"icon_star";
        }
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:starFileName]];
        starImageView.x = timeLabel.x+timeLabel.width+7;
        starImageView.y = timeLabel.y;
        [self addSubview:starImageView];
        
        // 作成日時
        UILabel *createLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width*0.5-7, logLabel.y+logLabel.height+2, self.width*0.5, 15)];
        createLabel.text = argActivityModel.created;
        createLabel.textColor =  RGBA(230, 197, 107, 1);
        createLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:10];
        createLabel.backgroundColor = [UIColor clearColor];
        createLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:createLabel];
        
    }
    return self;
}

@end
