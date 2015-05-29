//
//  MEditImageView.h
//
//  Created by takanori.morita on 2012/11/27.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// 塗りつぶし背景色
#define EDITED_IMAGE_BACKGROUND_FILL_COLOR 0.94f,0.95f,0.93f,1.0f

@protocol MEditImageViewDelegate;

@interface MEditImageView : UIView <UIGestureRecognizerDelegate>
{
    id<MEditImageViewDelegate> delegate;
    
    // イメージ
    UIImage *image;
    
    // イメージビュー
    UIImageView *imageView;
    
    // 編集ラストのimage
    UIImage *lastEdittingImage;

    // イメージサイズ
    CGSize imageSize;
    CGSize editImageSize;
    
    // 切り取りイメージのサイズ
    CGFloat rectangleTrimWidth;
    CGFloat rectangleTrimHeight;
    
    // 切り取りイメージの表示上のサイズ
    CGFloat rectangleFittingWidth;
    CGFloat rectangleFittingHeight;
    
    // 編集パラメタ
    CGFloat imageTurn;
    CGFloat imageMoveX;
    CGFloat imageMoveY;
    CGFloat imageScale;
    
    // 編集カレントパラメタ
    CGFloat imageTurnOffset;
    CGFloat imageMoveOffsetX;
    CGFloat imageMoveOffsetY;
    CGFloat imageScaleOffset;
    
    // 編集アフィン変換用変数
    CGAffineTransform rotate;
    CGAffineTransform scale;
    CGAffineTransform translate;
    CGAffineTransform concat;
    
    // 編集中フラグ
    BOOL moveFlg;
    
    // ジェスチャー中フラグ
    BOOL pinchFlg;
    BOOL rotateFlg;
    BOOL panFlg;
    
    // 編集可能フラグ
    BOOL editable;

    BOOL selfclose;
    void (^completionBlock)(MEditImageView *editedImageView);

    // デフォルト画像設定フラグ
    BOOL defaultImage;
    
    // 拡大最大値
    CGFloat scaleMax;
    
    // 回転フィッティングレンジ
    CGFloat turnFitRange;
    
    // 切り取りイメージのサイズと切り取りイメージの表示上のサイズの倍率
    CGFloat rectangleTrimAndFittingScale;
}

@property (nonatomic, retain) UIImageView *imageView;
@property CGAffineTransform rotate, scale, translate, concat;
@property CGFloat imageTurn, imageMoveX, imageMoveY, imageScale;
@property (nonatomic, strong) id<MEditImageViewDelegate> delegate;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *lastEdittingImage;
@property (nonatomic) CGSize editImageSize;
@property (nonatomic) BOOL editable;
@property (nonatomic) BOOL selfclose;
@property (strong, nonatomic) void (^completionBlock)(MEditImageView *editedImageView);
@property (nonatomic) BOOL defaultImage;
@property (nonatomic) CGFloat scaleMax;
@property (nonatomic) CGFloat turnFitRange;
@property (nonatomic) CGFloat rectangleTrimAndFittingScale;

// Methods
// Setter Methods
- (void)setImage:(UIImage *)_image;
- (void)setImage:(UIImage *)_image :(BOOL)atFit;
- (void)setEditable:(BOOL)_editting;
- (void)setDefaultImage:(BOOL)_defaultImage;
- (void)setTurnFitRange:(CGFloat)_turnFitRange;
- (void)setScaleMax:(CGFloat)_scaleMax;
- (void)setRectangleTrimAndFittingScale:(CGFloat)_rectangleTrimAndFittingScale;

// Other Methods
- (void)fitImage;
- (UIImage*)getEditedImage;

// Gestures
- (void)handleTapGesture:(UITapGestureRecognizer *)sender;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)sender;
- (void)handlePanGesture:(UIPanGestureRecognizer *)sender;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
- (void)pinchEnd;
- (void)panEnd;
- (void)rotateEnd;
- (void)turnFitting;
- (void)endTurnFittAnimation;
- (void)rectFitting;

@end

//delegate実装
@protocol MEditImageViewDelegate <NSObject>
@optional
- (void)editImageViewShowCamera:(MEditImageView *)editImageView;
- (void)editImageViewGestureBegan;
- (void)editImageViewGestureEnded;
@end
