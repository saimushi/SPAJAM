//
//  UserModel.h
//  自由に拡張可能です
//
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "UserModelBase.h"

@interface UserModel : UserModelBase

- (BOOL)load:(RequestCompletionHandler)argCompletionHandler;

@end
