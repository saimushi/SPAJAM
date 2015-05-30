//
//  FamiliarModel.h
//  自由に拡張可能です
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "FamiliarModelBase.h"

@interface FamiliarModel : FamiliarModelBase

- (BOOL)load:(RequestCompletionHandler)argCompletionHandler widthId:(NSString*)_id;

@end
