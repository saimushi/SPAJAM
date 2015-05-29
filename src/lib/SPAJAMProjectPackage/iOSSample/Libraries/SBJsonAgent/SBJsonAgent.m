//
//  SBJsonAgent.h
//
//  Created by saimushi on 2015/05/25.
//  Copyright (c) 2015年 saimushi. All rights reserved.
//

#import "SBJsonAgent.h"

@implementation SBJsonAgent

#pragma mark - Parse Json

+ (NSMutableDictionary *)parse:(NSString *)json
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDic = [parser objectWithString:json];
    return jsonDic;
}

+ (NSMutableArray *)parseArr:(NSString *)json
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableArray *jsonDic = [parser objectWithString:json];
    return jsonDic;
}

@end
