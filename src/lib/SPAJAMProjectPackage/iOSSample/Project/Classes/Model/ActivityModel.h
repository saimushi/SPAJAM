//
//  ActivityModel.h
//  自由に拡張可能です
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "ActivityModelBase.h"

@interface ActivityModel : ActivityModelBase

- (BOOL)load:(RequestCompletionHandler)argCompletionHandler;

@end
