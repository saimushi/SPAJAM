@interface NSString (textsize)
- (CGRect)textFrameWithFont:(UIFont *)font label:(UILabel *)label padding:(CGFloat)padding;
- (CGSize)textFrameWithFont:(UIFont *)font viewWidth:(CGFloat)viewWidth padding:(CGFloat)padding;
@end
