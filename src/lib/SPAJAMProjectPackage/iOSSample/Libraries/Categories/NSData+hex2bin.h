//
//  Created by 八幡 洋一 on 10/12/02.
#import <Foundation/Foundation.h>

@interface NSData (HexStringConvert)
+(NSData*) dataWithHexString:(NSString*)string;
-(id) initWithHexString:(NSString*)string;
@end
