//
//  MEditImageView.m
//
//  Created by takanori.morita on 2012/11/27.
//

#import "MEditImageView.h"

@implementation MEditImageView

@synthesize delegate;
@synthesize image;
@synthesize lastEdittingImage;
@synthesize editImageSize;
@synthesize imageView;
@synthesize rotate;
@synthesize scale;
@synthesize translate;
@synthesize concat;
@synthesize editable;
@synthesize imageTurn;
@synthesize imageMoveX;
@synthesize imageMoveY;
@synthesize imageScale;
@synthesize defaultImage;
@synthesize selfclose;
@synthesize completionBlock;
@synthesize scaleMax;
@synthesize turnFitRange;
@synthesize rectangleTrimAndFittingScale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        completionBlock = nil;
        lastEdittingImage = nil;
        self.editImageSize = CGSizeZero;
        // イメージ
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectZero;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = NO;
        imageView.transform = CGAffineTransformIdentity;
        [self addSubview:imageView];
        
        // マルチタッチイベント
        [self setMultipleTouchEnabled:YES];
        
        // タップ登録
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];

        // ロングプレス登録
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPressGesture.delegate = self;
        longPressGesture.allowableMovement = 5;
        longPressGesture.minimumPressDuration = 0.15;
        [self addGestureRecognizer:longPressGesture];

        // パン登録
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        
        // ピンチ登録
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        pinchGesture.delegate = self;
        [self addGestureRecognizer:pinchGesture];
        
        // ローテーション登録
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
    }
    return self;
}

#pragma mark - Setter Methods

- (void)setImage:(UIImage *)_image :(BOOL)atFit
{
    image = _image;
    imageView.image = image;
    if(self.editImageSize.height == 0 && self.editImageSize.width == 0){
        self.editImageSize = self.frame.size;
    }
    if (atFit) {
        // セットされたイメージに合わせて調整する
        [self fitImage];
    }
    lastEdittingImage = [self getEditedImage];
}

- (void)setImage:(UIImage *)_image
{
    if(self.editImageSize.height == 0 && self.editImageSize.width == 0){
        self.editImageSize = self.frame.size;
    }
    [self setImage:_image :TRUE];
}

- (void)setRectangleTrimAndFittingScale:(CGFloat)_rectangleTrimAndFittingScale
{
    rectangleTrimAndFittingScale = _rectangleTrimAndFittingScale;
    rectangleTrimWidth = self.editImageSize.width * rectangleTrimAndFittingScale;
    rectangleTrimHeight = self.editImageSize.height * rectangleTrimAndFittingScale;
}

#pragma mark - Fit Image

- (void)fitImage
{
    if (YES == defaultImage) {
        // ImageViewのフレームサイズ
        imageView.frame = CGRectMake(0, 0, self.editImageSize.width, self.editImageSize.height);
        // imageViewを画面のセンターに設定
        imageView.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    } else {
        // 各種編集情報クリアー
        imageMoveX = 0.0f;
        imageMoveY = 0.0f;
        
        imageMoveOffsetX = 0.0f;
        imageMoveOffsetY = 0.0f;
        
        imageTurn = 0.0f;
        imageTurnOffset = 0.0f;
        
        imageScale = 1.0f;
        imageScaleOffset = 1.0f;
        
        scale = CGAffineTransformMakeScale(imageScale * imageScaleOffset, imageScale * imageScaleOffset);
        translate = CGAffineTransformMakeTranslation(imageMoveX + imageMoveOffsetX, imageMoveY + imageMoveOffsetY);
        rotate = CGAffineTransformMakeRotation(imageTurn + imageTurnOffset);
        
        // 合算トランスフォーム
        [imageView setTransform:CGAffineTransformConcat(scale, CGAffineTransformConcat(rotate, translate))];
        
        rectangleFittingWidth = self.editImageSize.width;
        rectangleFittingHeight = self.editImageSize.height;
        
        rectangleTrimWidth = self.editImageSize.width * rectangleTrimAndFittingScale;
        rectangleTrimHeight = self.editImageSize.height * rectangleTrimAndFittingScale;
        
        // アスペクト固定のまま画面に余白が入らないようにサイズ調整
        if(self.image.size.width/self.image.size.height > rectangleFittingWidth / rectangleFittingHeight) {
            // 横長だったので縦をあわせ込む
            imageSize = CGSizeMake((int)self.image.size.width * rectangleFittingHeight / self.image.size.height, rectangleFittingHeight);
            
        } else if(self.image.size.width / self.image.size.height < rectangleFittingWidth / rectangleFittingHeight) {
            // 縦長だったので横をあわせ込む
            imageSize = CGSizeMake(rectangleFittingWidth, (int)self.image.size.height * rectangleFittingWidth / self.image.size.width);
            
        } else {
            // 縦横比同じ
            imageSize = CGSizeMake(rectangleFittingWidth, rectangleFittingHeight);
        }
        
        // ImageViewのフレームサイズ
        imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        //imageViewを画面のセンターに設定
        imageView.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    }
    
    [self setNeedsDisplay];
}


#pragma mark - Get EditedImage

- (UIImage*)getEditedImage
{
    rectangleTrimWidth = self.editImageSize.width * rectangleTrimAndFittingScale;
    rectangleTrimHeight = self.editImageSize.height * rectangleTrimAndFittingScale;
    
    CGFloat cw = rectangleTrimWidth;
    CGFloat ch = rectangleTrimHeight;
    
    CGColorSpaceRef genericColorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = NULL;
    
    contextRef = CGBitmapContextCreate(NULL,
                                       floor(cw),
                                       ch,
                                       8,
                                       floor(cw)*4,
                                       genericColorSpaceRef,
                                       (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    // GCへの描画処理開始
    CGColorSpaceRelease(genericColorSpaceRef);
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    
    // 塗りつぶし
    CGContextSetRGBFillColor(contextRef, EDITED_IMAGE_BACKGROUND_FILL_COLOR);
    CGContextFillRect(contextRef, CGRectMake(0,0,cw,ch));
    
    CGContextTranslateCTM(contextRef, cw/2.0f,ch/2.0f);
    CGContextTranslateCTM(contextRef,
                          (imageMoveX + imageMoveOffsetX) * cw / rectangleFittingWidth,
                          -(imageMoveY + imageMoveOffsetY) * ch / rectangleFittingHeight);
    
    // 写真の向きに応じて適切に回転
    if(self.image.imageOrientation == 0){
        CGContextRotateCTM(contextRef, -(imageTurn + imageTurnOffset));
        CGContextScaleCTM(contextRef,
                          imageScale * imageScaleOffset * imageSize.width / rectangleFittingWidth,
                          imageScale * imageScaleOffset * imageSize.height / rectangleFittingHeight);
        
    }else if(self.image.imageOrientation == 1){
        CGContextRotateCTM(contextRef, -(imageTurn + imageTurnOffset) + M_PI);
        CGContextScaleCTM(contextRef,
                          imageScale * imageScaleOffset * imageSize.width / rectangleFittingWidth,
                          imageScale * imageScaleOffset * imageSize.height / rectangleFittingHeight);
        
    }else if(self.image.imageOrientation == 2){
        CGContextRotateCTM(contextRef, -(imageTurn + imageTurnOffset) + M_PI / 2.0f);
        CGContextScaleCTM(contextRef,
                          imageScale * imageScaleOffset * imageSize.height / rectangleFittingWidth,
                          imageScale * imageScaleOffset * imageSize.width / rectangleFittingHeight);
        
    }else{
        CGContextRotateCTM(contextRef, -(imageTurn + imageTurnOffset) + M_PI + M_PI / 2.0f);
        CGContextScaleCTM(contextRef,
                          imageScale * imageScaleOffset * imageSize.height / rectangleFittingWidth,
                          imageScale * imageScaleOffset * imageSize.width / rectangleFittingHeight);
    }
    
    CGContextTranslateCTM(contextRef, -cw / 2.0f, -ch / 2.0f);
    
    CGContextDrawImage(contextRef, CGRectMake(0,0, cw ,ch), self.image.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    
    UIImage *editedImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CFRelease(contextRef);
    
    return (editedImage);
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    imageMoveX += imageMoveOffsetX;
    imageMoveY += imageMoveOffsetY;
    
    imageMoveOffsetX = 0.0f;
    imageMoveOffsetY = 0.0f;
    
    imageTurn += imageTurnOffset;
    imageTurnOffset = 0.0f;
    
    if(M_PI*2.0f<=imageTurn){
        imageTurn -= M_PI*2.0f;
    }
    if(imageTurn < 0.0f){
        imageTurn += M_PI*2.0f;
    }
    
    imageScale *= imageScaleOffset;
    imageScaleOffset = 1.0f;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Gestures

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (YES == defaultImage) {
        [delegate editImageViewShowCamera:self];
    }
    else if (YES == selfclose) {
        if (nil != self.completionBlock) {
            self.completionBlock(self);
        }
        [self removeFromSuperview];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (UIGestureRecognizerStateBegan == sender.state) {
        //長押ししてもカメラ起動しない処理
        //        [delegate editImageViewShowCamera:self];
    }
}

- (void)handleRotationGesture:(UIRotationGestureRecognizer *)sender
{
    if (NO == editable) {
        return;
    }
    
    rotateFlg = YES;
    
    if (moveFlg == YES) {
        return;
    }
    moveFlg = YES;
    
    UIRotationGestureRecognizer *rotation = (UIRotationGestureRecognizer *)sender;
    
    // 回転処理
    imageTurnOffset = rotation.rotation;
    
    // 回転トランスフォーム
    rotate = CGAffineTransformMakeRotation(imageTurn + imageTurnOffset);
    
    // 合算トランスフォーム
    [imageView setTransform:CGAffineTransformConcat(scale, CGAffineTransformConcat(rotate, translate))];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self rotateEnd];
    }
    
    moveFlg = NO;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    // ジェスチャーが開始されたことを通知
    if([delegate respondsToSelector:@selector(editImageViewGestureBegan)]){
        [delegate editImageViewGestureBegan];
    }
    
    if (NO == editable) {
        // ジェスチャーが終了したことを通知
        if([delegate respondsToSelector:@selector(editImageViewGestureEnded)]){
            [delegate editImageViewGestureEnded];
        }
        
        return;
    }
    
    panFlg = YES;
    
    if (moveFlg == YES) {
        return;
    }
    moveFlg = YES;
    
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    
    CGPoint location = [pan translationInView:self];
    
    // 移動処理
    imageMoveOffsetX = location.x;
    imageMoveOffsetY = location.y;
    
    // 移動トランスフォーム
    translate = CGAffineTransformMakeTranslation(imageMoveX + imageMoveOffsetX, imageMoveY + imageMoveOffsetY);
    
    // 合算トランスフォーム
    [imageView setTransform:CGAffineTransformConcat(scale, CGAffineTransformConcat(rotate, translate))];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self panEnd];
    }
    
    moveFlg = NO;
    
    // ジェスチャーが終了したことを通知
    if([delegate respondsToSelector:@selector(editImageViewGestureEnded)]){
        [delegate editImageViewGestureEnded];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    if (NO == editable) {
        return;
    }
    
    pinchFlg = YES;
    
    if (moveFlg == YES) {
        return;
    }
    moveFlg = YES;
    
    UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)sender;
    
    // 拡大処理
    imageScaleOffset = pinch.scale;
    
    // 拡大縮小トランスフォーム
    scale = CGAffineTransformMakeScale(imageScale * imageScaleOffset, imageScale * imageScaleOffset);
    
    // 合算トランスフォーム
    [imageView setTransform:CGAffineTransformConcat(scale, CGAffineTransformConcat(rotate, translate))];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self pinchEnd];
    }
    moveFlg = NO;
}

- (void)pinchEnd
{
    pinchFlg = NO;
    
    if (panFlg == NO && rotateFlg == NO) {
        [self turnFitting];
    }
    return;
}

- (void)panEnd
{
    panFlg = NO;
    if (pinchFlg == NO && rotateFlg == NO) {
        [self turnFitting];
    }
    return;
}

- (void)rotateEnd
{
    rotateFlg = NO;
    if (pinchFlg == NO && panFlg == NO) {
        [self turnFitting];
    }
    return;
}

- (void)turnFitting
{
    CGFloat turnTemp = imageTurn + imageTurnOffset;
    
    turnTemp = M_PI * 2.0f <= turnTemp ? turnTemp - M_PI * 2.0f * (int)(turnTemp / (M_PI * 2.0f)):turnTemp;
    turnTemp = turnTemp < 0 ? turnTemp + M_PI * 2.0f *(int)(-turnTemp / (M_PI * 2.0f) + 1.0):turnTemp;
    
    if(turnTemp == 0.0f || turnTemp == M_PI / 2.0f || turnTemp == M_PI || turnTemp == M_PI + M_PI / 2.0f){
        // 合わせ込みなし
        [self rectFitting];
        return;
        
    }else if(turnTemp < M_PI * turnFitRange / 180.0f){
        // 0度にあわせ込み
        turnTemp = -turnTemp;
        
    }else if(M_PI * 2.0f - M_PI * turnFitRange / 180.0f < turnTemp){
        // 0度にあわせ込み
        turnTemp = M_PI * 2.0f - (turnTemp - M_PI * 2.0f);
        
    }else if(M_PI / 2.0f - M_PI * turnFitRange / 180.0f < turnTemp && turnTemp < M_PI / 2.0f + M_PI * turnFitRange / 180.0f){
        // 90度にあわせ込み
        turnTemp = M_PI / 2.0f - (turnTemp - (M_PI / 2.0f));
        
    }else if(M_PI - M_PI * turnFitRange / 180.0f < turnTemp && turnTemp < M_PI + M_PI * turnFitRange / 180.0f){
        // 180度にあわせ込み
        turnTemp = M_PI - (turnTemp - (M_PI)) * 4.0f / 5.0f;
        
    }else if(M_PI + M_PI / 2.0f - M_PI * turnFitRange / 180.0f < turnTemp && turnTemp < M_PI + M_PI / 2.0f + M_PI * turnFitRange / 180.0f){
        // 270度にあわせ込み
        turnTemp = M_PI + M_PI / 2.0f - (turnTemp - (M_PI + M_PI / 2.0f));
        
    }else{
        // 合わせ込みなし
        [self rectFitting];
        return;
    }
    
    // 角度合わせ込みのビヨヨヨンアニメ
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.07f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:3];
    
    [UIView setAnimationDidStopSelector:@selector(endTurnFittAnimation)];
    
    // 回転トランスフォーム
    rotate = CGAffineTransformMakeRotation(turnTemp);
    
    // 合算トランスフォーム
    [imageView setTransform:CGAffineTransformConcat(scale,CGAffineTransformConcat(rotate, translate))];
    
    // アニメーションをコミット
    [UIView commitAnimations];
    
    return;
}

- (void)endTurnFittAnimation
{
    // CGFloat turnFitting = 3.0f;
    CGFloat turnTemp = imageTurn + imageTurnOffset;
    
    turnTemp = M_PI * 2.0f <= turnTemp ? turnTemp - M_PI * 2.0f * (int)(turnTemp / (M_PI * 2.0f)):turnTemp;
    turnTemp = turnTemp < 0 ? turnTemp + M_PI * 2.0f * (int)(-turnTemp / (M_PI * 2.0f) + 1.0):turnTemp;
    
    if(turnTemp < M_PI * turnFitRange / 180.0f){
        // 0度にあわせ込み
        imageTurn = imageTurnOffset = 0.0f;
        
    }else if(M_PI * 2.0f - M_PI * turnFitRange / 180.0f < turnTemp){
        // 0度にあわせ込み
        imageTurn = M_PI * 2.0f;
        imageTurnOffset = 0.0f;
        
    }else if(M_PI / 2.0f - M_PI * turnFitRange / 180.0f < turnTemp && turnTemp < M_PI / 2.0f + M_PI * turnFitRange / 180.0f){
        // 90度にあわせ込み
        imageTurn = M_PI / 2.0f;
        imageTurnOffset = 0.0f;
        
    }else if(M_PI - M_PI * turnFitRange / 180.0f < turnTemp && turnTemp < M_PI + M_PI * turnFitRange / 180.0f){
        // 180度にあわせ込み
        imageTurn = M_PI;
        imageTurnOffset = 0.0f;
        
    }else if(M_PI + M_PI / 2.0f - M_PI * turnFitRange / 180.0f < turnTemp && turnTemp < M_PI + M_PI / 2.0f + M_PI * turnFitRange / 180.0f){
        // 270度にあわせ込み
        imageTurn = M_PI + M_PI / 2.0f;
        imageTurnOffset = 0.0f;
        
    }
    
    [self rectFitting];
    return;
}

- (void)rectFitting
{
    CGFloat cw = rectangleFittingWidth;
    CGFloat ch = rectangleFittingHeight;
    
    CGFloat turnTemp = imageTurn + imageTurnOffset;
    
    turnTemp = M_PI * 2.0f <= turnTemp ? turnTemp - M_PI * 2.0f * (int)(turnTemp / (M_PI * 2.0f)):turnTemp;
    turnTemp = turnTemp < 0 ? turnTemp + M_PI * 2.0f * (int)(-turnTemp / (M_PI * 2.0f) + 1.0):turnTemp;
    
    {
        // 縮小により画面から見切れているか？
        CGFloat gaiRectHen1 = imageSize.width * imageScaleOffset * imageScale;
        CGFloat gaiRectHen2 = imageSize.height * imageScaleOffset * imageScale;
        
        CGFloat naiRectHen1 = ch;
        CGFloat naiRectHen2 = cw;
        
        CGFloat taikakusen = sqrt(naiRectHen1 * naiRectHen1 + naiRectHen2 * naiRectHen2);
        
        CGFloat newRectHen1;
        // CGFloat newRectHen2;
        
        // ９０度毎に処理をチェック
        if(turnTemp <= M_PI/2.0f){
            CGFloat newRectHen1tmp1 = fabs(gaiRectHen1 * naiRectHen1 / taikakusen / sinf(turnTemp + atan2f(naiRectHen2, naiRectHen1)));
            CGFloat newRectHen1tmp2 = fabs(gaiRectHen2 * naiRectHen1 / taikakusen/ cosf(turnTemp - atan2f(naiRectHen2, naiRectHen1)));
            
            newRectHen1 = newRectHen1tmp1 < newRectHen1tmp2 ? newRectHen1tmp1:newRectHen1tmp2;
        }else if(turnTemp <= M_PI){
            CGFloat newRectHen1tmp1 = fabs(gaiRectHen1 * naiRectHen1 / taikakusen / sinf(M_PI - turnTemp + atan2f(naiRectHen2, naiRectHen1)));
            CGFloat newRectHen1tmp2 = fabs(gaiRectHen2 * naiRectHen1 / taikakusen / cosf(M_PI - turnTemp - atan2f(naiRectHen2, naiRectHen1)));
            
            newRectHen1 = newRectHen1tmp1 < newRectHen1tmp2 ? newRectHen1tmp1:newRectHen1tmp2;
        }else if(turnTemp <= M_PI + M_PI / 2.0f){
            CGFloat newRectHen1tmp1 = fabs(gaiRectHen1 * naiRectHen1 / taikakusen / sinf(turnTemp - M_PI + atan2f(naiRectHen2, naiRectHen1)));
            CGFloat newRectHen1tmp2 = fabs(gaiRectHen2 * naiRectHen1 / taikakusen / cosf(turnTemp - M_PI - atan2f(naiRectHen2, naiRectHen1)));
            
            newRectHen1 = newRectHen1tmp1 < newRectHen1tmp2 ? newRectHen1tmp1:newRectHen1tmp2;
        }else{
            CGFloat newRectHen1tmp1 = fabs(gaiRectHen1 * naiRectHen1 / taikakusen / sinf(M_PI * 2.0f - turnTemp + atan2f(naiRectHen2, naiRectHen1)));
            CGFloat newRectHen1tmp2 = fabs(gaiRectHen2 * naiRectHen1 / taikakusen / cosf(M_PI * 2.0f - turnTemp - atan2f(naiRectHen2, naiRectHen1)));
            
            newRectHen1 = newRectHen1tmp1 < newRectHen1tmp2 ? newRectHen1tmp1:newRectHen1tmp2;
        }
        
        // newRectHen2 = newRectHen1*naiRectHen2/naiRectHen1;
        
        // 画面いっぱいに収まるように画像を拡大する
        if(newRectHen1 / ch < 1.0f){
            //画面から見切れる部分があるので拡大処理
            imageScaleOffset = ch / (newRectHen1 / (imageScaleOffset * imageScale));
            imageScale = 1.0f;
        }
    }
    
    if(scaleMax < imageScaleOffset * imageScale){
        imageScale = scaleMax;
        imageScaleOffset = 1.0f;
    }
    
    // 縮小、移動により画面から見切れているか？
    {
        // 画像の４点の座標を算出
        CGPoint gaiRectPoint[] = {
            CGPointMake(
                        (-imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp)
                        - (-imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp) + imageMoveX + imageMoveOffsetX
                        ,
                        (-imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp)
                        + (-imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp) + imageMoveY + imageMoveOffsetY
                        )
            ,
            CGPointMake(
                        (+imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp)
                        - (-imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp) + imageMoveX + imageMoveOffsetX
                        ,
                        (+imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp)
                        + (-imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp) + imageMoveY + imageMoveOffsetY
                        )
            ,
            CGPointMake(
                        (+imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp)
                        - (+imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp) + imageMoveX + imageMoveOffsetX
                        ,
                        (+imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp)
                        + (+imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp) + imageMoveY + imageMoveOffsetY
                        )
            ,
            CGPointMake(
                        (-imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp)
                        - (+imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp) + imageMoveX + imageMoveOffsetX
                        ,
                        (-imageSize.width) / 2.0f * (imageScaleOffset * imageScale) * sinf(turnTemp)
                        + (+imageSize.height) / 2.0f * (imageScaleOffset * imageScale) * cosf(turnTemp) + imageMoveY + imageMoveOffsetY
                        )
        };
        
        // フレームの４点の座標を算出
        CGPoint naiRectPoint[] = {
            CGPointMake(-cw / 2.0f, -ch / 2.0f),
            CGPointMake(+cw / 2.0f, -ch / 2.0f),
            CGPointMake(+cw / 2.0f, +ch / 2.0f),
            CGPointMake(-cw / 2.0f, +ch / 2.0f)
        };
        
        // 下辺と各ポイントのはみ出しチェック
        if((gaiRectPoint[0].x-gaiRectPoint[3].x) * (naiRectPoint[0].x-gaiRectPoint[3].x)
           +(gaiRectPoint[0].y-gaiRectPoint[3].y) * (naiRectPoint[0].y-gaiRectPoint[3].y) < 0 && M_PI / 2.0f <= turnTemp && turnTemp <= M_PI){
            
            CGFloat a = gaiRectPoint[3].y - gaiRectPoint[2].y;
            CGFloat b = gaiRectPoint[2].x - gaiRectPoint[3].x;
            CGFloat c =  (gaiRectPoint[2].y - gaiRectPoint[3].y) * gaiRectPoint[2].x
            + (gaiRectPoint[3].x - gaiRectPoint[2].x) * gaiRectPoint[2].y;
            CGFloat l = fabs(a * naiRectPoint[0].x + b * naiRectPoint[0].y + c) / sqrtf(a * a + b * b);
            
            imageMoveOffsetX -= l * sinf(turnTemp);
            imageMoveOffsetY += l * cosf(turnTemp);
            
        }else
            if((gaiRectPoint[0].x-gaiRectPoint[3].x) * (naiRectPoint[1].x-gaiRectPoint[3].x)
               + (gaiRectPoint[0].y-gaiRectPoint[3].y) * (naiRectPoint[1].y-gaiRectPoint[3].y) < 0 && M_PI <= turnTemp && turnTemp < M_PI + M_PI / 2.0f){
                
                CGFloat a = gaiRectPoint[3].y - gaiRectPoint[2].y;
                CGFloat b = gaiRectPoint[2].x - gaiRectPoint[3].x;
                CGFloat c =  (gaiRectPoint[2].y - gaiRectPoint[3].y) * gaiRectPoint[2].x
                + (gaiRectPoint[3].x - gaiRectPoint[2].x) * gaiRectPoint[2].y;
                CGFloat l = fabs(a * naiRectPoint[1].x + b * naiRectPoint[1].y + c)/sqrtf(a * a + b * b);
                
                imageMoveOffsetX -= l * sinf(turnTemp);
                imageMoveOffsetY += l * cosf(turnTemp);
                
            }else
                if((gaiRectPoint[0].x-gaiRectPoint[3].x) * (naiRectPoint[2].x-gaiRectPoint[3].x)
                   + (gaiRectPoint[0].y-gaiRectPoint[3].y) * (naiRectPoint[2].y-gaiRectPoint[3].y) < 0 && M_PI + M_PI / 2.0f <= turnTemp){
                    
                    CGFloat a = gaiRectPoint[3].y - gaiRectPoint[2].y;
                    CGFloat b = gaiRectPoint[2].x - gaiRectPoint[3].x;
                    CGFloat c =  (gaiRectPoint[2].y - gaiRectPoint[3].y) * gaiRectPoint[2].x
                    + (gaiRectPoint[3].x - gaiRectPoint[2].x) * gaiRectPoint[2].y;
                    CGFloat l = fabs(a * naiRectPoint[2].x + b * naiRectPoint[2].y + c) / sqrtf(a * a + b * b);
                    
                    imageMoveOffsetX -= l * sinf(turnTemp);
                    imageMoveOffsetY += l * cosf(turnTemp);
                    
                }else
                    if( (gaiRectPoint[0].x-gaiRectPoint[3].x) * (naiRectPoint[3].x-gaiRectPoint[3].x)
                       + (gaiRectPoint[0].y-gaiRectPoint[3].y) * (naiRectPoint[3].y-gaiRectPoint[3].y) < 0 && turnTemp <= M_PI / 2.0f){
                        
                        CGFloat a = gaiRectPoint[3].y - gaiRectPoint[2].y;
                        CGFloat b = gaiRectPoint[2].x - gaiRectPoint[3].x;
                        CGFloat c =  (gaiRectPoint[2].y - gaiRectPoint[3].y) * gaiRectPoint[2].x
                        +(gaiRectPoint[3].x - gaiRectPoint[2].x) * gaiRectPoint[2].y;
                        CGFloat l = fabs(a * naiRectPoint[3].x + b * naiRectPoint[3].y + c) / sqrtf(a * a + b * b);
                        
                        imageMoveOffsetX -= l * sinf(turnTemp);
                        imageMoveOffsetY += l * cosf(turnTemp);
                        
                    }
        
        // 左辺と各ポイントのはみ出しチェック
        if((gaiRectPoint[1].x - gaiRectPoint[0].x) * (naiRectPoint[0].x - gaiRectPoint[0].x)
           + (gaiRectPoint[1].y - gaiRectPoint[0].y) * (naiRectPoint[0].y - gaiRectPoint[0].y) < 0 && turnTemp <= M_PI / 2.0f){
            
            CGFloat a = gaiRectPoint[0].y - gaiRectPoint[3].y;
            CGFloat b = gaiRectPoint[3].x - gaiRectPoint[0].x;
            CGFloat c =  (gaiRectPoint[3].y - gaiRectPoint[0].y) * gaiRectPoint[3].x
            + (gaiRectPoint[0].x - gaiRectPoint[3].x) * gaiRectPoint[3].y;
            CGFloat l = fabs(a * naiRectPoint[0].x + b * naiRectPoint[0].y + c)/sqrtf(a * a + b * b);
            
            imageMoveOffsetX -= l * cosf(turnTemp);
            imageMoveOffsetY -= l * sinf(turnTemp);
            
        }else
            if((gaiRectPoint[1].x - gaiRectPoint[0].x) * (naiRectPoint[1].x - gaiRectPoint[0].x)
               + (gaiRectPoint[1].y - gaiRectPoint[0].y) * (naiRectPoint[1].y - gaiRectPoint[0].y) < 0 && M_PI / 2.0f <= turnTemp && turnTemp <= M_PI){
                
                CGFloat a = gaiRectPoint[0].y - gaiRectPoint[3].y;
                CGFloat b = gaiRectPoint[3].x - gaiRectPoint[0].x;
                CGFloat c =  (gaiRectPoint[3].y - gaiRectPoint[0].y)*gaiRectPoint[3].x
                +(gaiRectPoint[0].x - gaiRectPoint[3].x) * gaiRectPoint[3].y;
                CGFloat l = fabs(a * naiRectPoint[1].x + b * naiRectPoint[1].y + c) / sqrtf(a * a + b * b);
                
                imageMoveOffsetX -= l * cosf(turnTemp);
                imageMoveOffsetY -= l * sinf(turnTemp);
            }else
                if((gaiRectPoint[1].x - gaiRectPoint[0].x) * (naiRectPoint[2].x - gaiRectPoint[0].x)
                   + (gaiRectPoint[1].y - gaiRectPoint[0].y) * (naiRectPoint[2].y - gaiRectPoint[0].y) < 0 && M_PI <= turnTemp && turnTemp < M_PI+M_PI / 2.0f){
                    
                    CGFloat a = gaiRectPoint[0].y - gaiRectPoint[3].y;
                    CGFloat b = gaiRectPoint[3].x - gaiRectPoint[0].x;
                    CGFloat c =  (gaiRectPoint[3].y - gaiRectPoint[0].y) * gaiRectPoint[3].x
                    + (gaiRectPoint[0].x - gaiRectPoint[3].x) * gaiRectPoint[3].y;
                    CGFloat l = fabs(a * naiRectPoint[2].x + b * naiRectPoint[2].y + c)/sqrtf(a * a + b * b);
                    
                    imageMoveOffsetX -= l * cosf(turnTemp);
                    imageMoveOffsetY -= l * sinf(turnTemp);
                }else
                    if((gaiRectPoint[1].x - gaiRectPoint[0].x) * (naiRectPoint[3].x - gaiRectPoint[0].x)
                       + (gaiRectPoint[1].y - gaiRectPoint[0].y) * (naiRectPoint[3].y - gaiRectPoint[0].y) < 0 && M_PI + M_PI / 2.0f <= turnTemp){
                        
                        CGFloat a = gaiRectPoint[0].y - gaiRectPoint[3].y;
                        CGFloat b = gaiRectPoint[3].x - gaiRectPoint[0].x;
                        CGFloat c =  (gaiRectPoint[3].y - gaiRectPoint[0].y)*gaiRectPoint[3].x
                        + (gaiRectPoint[0].x - gaiRectPoint[3].x) * gaiRectPoint[3].y;
                        CGFloat l = fabs(a * naiRectPoint[3].x + b * naiRectPoint[3].y + c) / sqrtf(a * a + b * b);
                        
                        imageMoveOffsetX -= l * cosf(turnTemp);
                        imageMoveOffsetY -= l * sinf(turnTemp);
                    }
        
        // 上辺と各ポイントのはみ出しチェック
        if((gaiRectPoint[2].x - gaiRectPoint[1].x) * (naiRectPoint[0].x - gaiRectPoint[1].x)
           + (gaiRectPoint[2].y - gaiRectPoint[1].y) * (naiRectPoint[0].y - gaiRectPoint[1].y) < 0 && M_PI + M_PI / 2.0f <= turnTemp){
            
            CGFloat a = gaiRectPoint[1].y - gaiRectPoint[0].y;
            CGFloat b = gaiRectPoint[0].x - gaiRectPoint[1].x;
            CGFloat c =  (gaiRectPoint[0].y - gaiRectPoint[1].y)*gaiRectPoint[0].x
            + (gaiRectPoint[1].x - gaiRectPoint[0].x) * gaiRectPoint[0].y;
            CGFloat l = fabs(a * naiRectPoint[0].x + b * naiRectPoint[0].y + c)/sqrtf(a * a + b * b);
            
            imageMoveOffsetX += l * sinf(turnTemp);
            imageMoveOffsetY -= l * cosf(turnTemp);
            
        }else
            if((gaiRectPoint[2].x - gaiRectPoint[1].x) * (naiRectPoint[1].x - gaiRectPoint[1].x)
               + (gaiRectPoint[2].y - gaiRectPoint[1].y) * (naiRectPoint[1].y - gaiRectPoint[1].y) < 0 && turnTemp <= M_PI / 2.0f){
                
                CGFloat a = gaiRectPoint[1].y - gaiRectPoint[0].y;
                CGFloat b = gaiRectPoint[0].x - gaiRectPoint[1].x;
                CGFloat c =  (gaiRectPoint[0].y - gaiRectPoint[1].y) * gaiRectPoint[0].x
                + (gaiRectPoint[1].x - gaiRectPoint[0].x) * gaiRectPoint[0].y;
                CGFloat l = fabs(a * naiRectPoint[1].x + b * naiRectPoint[1].y + c)/sqrtf(a * a + b * b);
                
                imageMoveOffsetX += l * sinf(turnTemp);
                imageMoveOffsetY -= l * cosf(turnTemp);
                
            }else
                if((gaiRectPoint[2].x-gaiRectPoint[1].x) * (naiRectPoint[2].x - gaiRectPoint[1].x)
                   + (gaiRectPoint[2].y - gaiRectPoint[1].y) * (naiRectPoint[2].y - gaiRectPoint[1].y) < 0 && M_PI / 2.0f <= turnTemp && turnTemp <= M_PI){
                    
                    CGFloat a = gaiRectPoint[1].y - gaiRectPoint[0].y;
                    CGFloat b = gaiRectPoint[0].x - gaiRectPoint[1].x;
                    CGFloat c =  (gaiRectPoint[0].y - gaiRectPoint[1].y) * gaiRectPoint[0].x
                    + (gaiRectPoint[1].x - gaiRectPoint[0].x) * gaiRectPoint[0].y;
                    CGFloat l = fabs(a * naiRectPoint[2].x + b * naiRectPoint[2].y + c) / sqrtf(a * a + b * b);
                    
                    imageMoveOffsetX += l * sinf(turnTemp);
                    imageMoveOffsetY -= l * cosf(turnTemp);
                    
                }else
                    if((gaiRectPoint[2].x - gaiRectPoint[1].x) * (naiRectPoint[3].x - gaiRectPoint[1].x)
                       + (gaiRectPoint[2].y - gaiRectPoint[1].y) * (naiRectPoint[3].y - gaiRectPoint[1].y) < 0 && M_PI <= turnTemp && turnTemp < M_PI + M_PI / 2.0f){
                        
                        CGFloat a = gaiRectPoint[1].y - gaiRectPoint[0].y;
                        CGFloat b = gaiRectPoint[0].x - gaiRectPoint[1].x;
                        CGFloat c =  (gaiRectPoint[0].y - gaiRectPoint[1].y)*gaiRectPoint[0].x
                        + (gaiRectPoint[1].x - gaiRectPoint[0].x) * gaiRectPoint[0].y;
                        CGFloat l = fabs(a * naiRectPoint[3].x + b * naiRectPoint[3].y + c) / sqrtf(a * a + b * b);
                        
                        imageMoveOffsetX += l * sinf(turnTemp);
                        imageMoveOffsetY -= l * cosf(turnTemp);
                        
                    }
        
        // 右辺と各ポイントのはみ出しチェック
        if((gaiRectPoint[3].x - gaiRectPoint[2].x) * (naiRectPoint[0].x - gaiRectPoint[2].x)
           + (gaiRectPoint[3].y - gaiRectPoint[2].y) * (naiRectPoint[0].y - gaiRectPoint[2].y) < 0 && M_PI <= turnTemp && turnTemp < M_PI + M_PI / 2.0f){
            
            CGFloat a = gaiRectPoint[2].y - gaiRectPoint[1].y;
            CGFloat b = gaiRectPoint[1].x - gaiRectPoint[2].x;
            CGFloat c =  (gaiRectPoint[1].y - gaiRectPoint[2].y) * gaiRectPoint[1].x
            + (gaiRectPoint[2].x - gaiRectPoint[1].x) * gaiRectPoint[1].y;
            CGFloat l = fabs(a * naiRectPoint[0].x + b * naiRectPoint[0].y + c) / sqrtf(a * a + b * b);
            
            imageMoveOffsetX += l * cosf(turnTemp);
            imageMoveOffsetY += l * sinf(turnTemp);
            
        }else
            if((gaiRectPoint[3].x - gaiRectPoint[2].x) * (naiRectPoint[1].x - gaiRectPoint[2].x)
               + (gaiRectPoint[3].y - gaiRectPoint[2].y) * (naiRectPoint[1].y - gaiRectPoint[2].y) < 0 && M_PI + M_PI / 2.0f <= turnTemp){
                
                CGFloat a = gaiRectPoint[2].y - gaiRectPoint[1].y;
                CGFloat b = gaiRectPoint[1].x - gaiRectPoint[2].x;
                CGFloat c =  (gaiRectPoint[1].y - gaiRectPoint[2].y) * gaiRectPoint[1].x
                + (gaiRectPoint[2].x - gaiRectPoint[1].x) * gaiRectPoint[1].y;
                CGFloat l = fabs(a * naiRectPoint[1].x + b * naiRectPoint[1].y + c) / sqrtf(a * a + b * b);
                
                imageMoveOffsetX += l * cosf(turnTemp);
                imageMoveOffsetY += l * sinf(turnTemp);
                
            }else
                if((gaiRectPoint[3].x - gaiRectPoint[2].x) * (naiRectPoint[2].x - gaiRectPoint[2].x)
                   + (gaiRectPoint[3].y - gaiRectPoint[2].y) * (naiRectPoint[2].y - gaiRectPoint[2].y) < 0 && turnTemp <= M_PI / 2.0f){
                    
                    CGFloat a = gaiRectPoint[2].y - gaiRectPoint[1].y;
                    CGFloat b = gaiRectPoint[1].x - gaiRectPoint[2].x;
                    CGFloat c =  (gaiRectPoint[1].y - gaiRectPoint[2].y) * gaiRectPoint[1].x
                    + (gaiRectPoint[2].x - gaiRectPoint[1].x) * gaiRectPoint[1].y;
                    CGFloat l = fabs(a * naiRectPoint[2].x + b * naiRectPoint[2].y + c) / sqrtf(a * a + b * b);
                    
                    imageMoveOffsetX += l * cosf(turnTemp);
                    imageMoveOffsetY += l * sinf(turnTemp);
                    
                }else
                    if((gaiRectPoint[3].x - gaiRectPoint[2].x) * (naiRectPoint[3].x - gaiRectPoint[2].x)
                       + (gaiRectPoint[3].y - gaiRectPoint[2].y) * (naiRectPoint[3].y - gaiRectPoint[2].y) < 0 && M_PI / 2.0f <= turnTemp && turnTemp <= M_PI){
                        
                        CGFloat a = gaiRectPoint[2].y - gaiRectPoint[1].y;
                        CGFloat b = gaiRectPoint[1].x - gaiRectPoint[2].x;
                        CGFloat c =  (gaiRectPoint[1].y - gaiRectPoint[2].y) * gaiRectPoint[1].x
                        + (gaiRectPoint[2].x - gaiRectPoint[1].x) * gaiRectPoint[1].y;
                        CGFloat l = fabs(a * naiRectPoint[3].x + b * naiRectPoint[3].y + c) / sqrtf(a * a + b * b);
                        
                        imageMoveOffsetX += l * cosf(turnTemp);
                        imageMoveOffsetY += l * sinf(turnTemp);
                    }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd)];
    
    //拡大縮小トランスフォーム
    scale = CGAffineTransformMakeScale(imageScale * imageScaleOffset, imageScale * imageScaleOffset);
    
    //移動トランスフォーム
    translate = CGAffineTransformMakeTranslation(imageMoveX + imageMoveOffsetX,
                                                 imageMoveY + imageMoveOffsetY);
    
    //回転トランスフォーム
    rotate = CGAffineTransformMakeRotation(turnTemp);
    
    //合算トランスフォーム
    [imageView setTransform:CGAffineTransformConcat(scale, CGAffineTransformConcat(rotate, translate))];
    
    // アニメーションをコミット
    [UIView commitAnimations];
}

- (void)animationEnd
{
    if (imageView.image) {
        lastEdittingImage = [self getEditedImage];
    }
}

@end
