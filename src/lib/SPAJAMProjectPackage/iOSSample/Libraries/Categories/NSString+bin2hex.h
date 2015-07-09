//
//  Created by 八幡 洋一 on 10/12/02.
#import <Foundation/Foundation.h>

@interface NSString (HexStringConvert)
+(NSString*) stringHexWithData:(NSData*)data;
-(id) initHexWithData:(NSData*)data;
@end
