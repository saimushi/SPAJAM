
#import "NSString+textsize.h"

@implementation NSString (textsize)

- (CGRect)textFrameWithFont:(UIFont *)font label:(UILabel *)label padding:(CGFloat)padding;
{
    CGSize size;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        //OS7
        NSDictionary *attributeDic = @{NSFontAttributeName:font};
        size = [self boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                               attributes:attributeDic
                                  context:nil].size;
    }
    CGRect frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, size.height + padding);
    return frame;
}

- (CGSize)textFrameWithFont:(UIFont *)font viewWidth:(CGFloat)viewWidth padding:(CGFloat)padding;
{
    CGSize size;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        //OS7
        NSDictionary *attributeDic = @{NSFontAttributeName:font};
        size = [self boundingRectWithSize:CGSizeMake(viewWidth, CGFLOAT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                               attributes:attributeDic
                                  context:nil].size;
    }
    size.height += padding;
    return size;
}
@end
