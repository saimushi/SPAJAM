//
//  MCropImageView.h
//
//  Created by saimushi on 2014/10/08.
//

#import "MEditImageView.h"

@class MCropImageView;

typedef void(^MCropCompletionHandler)(MCropImageView *mcropImageView, BOOL finished, UIImage *image);

@interface MCropImageView : UIView <MEditImageViewDelegate>

- (id)initWithFrame:(CGRect)frame :(UIImage *)argImage :(int)argCropWith :(int)argCropHeight :(BOOL)argUseFrame :(MCropCompletionHandler)argCompletionHandler;
- (id)initWithFrame:(CGRect)frame :(UIImage *)argImage :(int)argCropWith :(int)argCropHeight :(BOOL)argUseFrame :(UIView*)argOverlayView :(MCropCompletionHandler)argCompletionHandler;

- (void)show:(BOOL)animated;
- (void)dissmiss:(BOOL)animated;
- (void)onPushCancelButton:(id)sender;
- (void)onPushOkButton:(id)sender;

@end
