//
//  SBJsonAgent.h
//
//  Created by saimushi on 2015/05/25.
//  Copyright (c) 2015年 saimushi. All rights reserved.
//

#import "SBJson.h"

@interface SBJsonAgent : NSObject

// Jsonをパースする
+ (NSMutableDictionary *)parse:(NSString *)json;
+ (NSMutableArray *)parseArr:(NSString *)json;

@end
