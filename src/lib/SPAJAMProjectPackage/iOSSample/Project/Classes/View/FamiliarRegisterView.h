//
//  GodMyPageView.h
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "common.h"

@interface FamiliarRegisterView : UIView
{
    // Protected
    UILabel *familiarNameInputLabel;
    UILabel *familiarInfoInputLabel;
}

@property (strong, nonatomic) UILabel *familiarNameInputLabel;
@property (strong, nonatomic) UILabel *familiarInfoInputLabel;

- (id)initWithFrame:(CGRect)argFrame WithDelegate:(id)delegate;


@end
