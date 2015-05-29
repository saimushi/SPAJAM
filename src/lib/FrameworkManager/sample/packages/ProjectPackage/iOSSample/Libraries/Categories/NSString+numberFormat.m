
#import "NSString+numberFormat.h"

@implementation NSString (numberFormat)
- (NSString *)getMoneyFormatString;
{
    NSNumber *priceNumber = [[NSNumber alloc] initWithInteger:[self intValue]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
    return [formatter stringFromNumber:priceNumber];
}
@end
