//
//  MStatusbarProgress.m
//
//  Created by saimushi on 2015/01/14.
//  Version:1.0

#import "MStatusbarProgress.h"

@implementation MStatusbarProgress
{
    BOOL showed;
    UIView *progressBarView;
    double totalBytesSent;
    double totalBytes;
}

static MStatusbarProgress *sharedInstance = nil;

+ (void)show:(double)argTotalBytesSent :(double)argTotalBytes;
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        // メインスレッドで実行
        [[self sharedInstance:argTotalBytesSent :argTotalBytes] animation];
    });
}

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

+ (id)sharedInstance:(double)argTotalBytesSent :(double)argTotalBytes
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance = [self sharedInstance];
        }
        [sharedInstance initialize:argTotalBytesSent :argTotalBytes];
    }
    return sharedInstance;
}

- (void)initialize:(double)argTotalBytesSent :(double)argTotalBytes
{
    totalBytesSent = argTotalBytesSent;
    totalBytes = argTotalBytes;
    if (YES != showed) {
        self.frame = CGRectMake(0, 0, 0, MSTATUSBAR_PROGRESS_HEIGHT);
        self.backgroundColor = MSTATUSBAR_PROGRESS_COLOR;
        // Windowの一番上に貼り付ける
        [[UIApplication sharedApplication].delegate.window addSubview:self];
        showed = YES;
    }
}

- (void)animation
{
    [UIView animateWithDuration:0.2f animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [UIApplication sharedApplication].delegate.window.frame.size.width * (totalBytesSent / totalBytes), self.frame.size.height);
    } completion:^(BOOL finished) {
        [self finalize];
    }];
}

- (void)finalize;
{
    if (totalBytesSent >= totalBytes){
        // 転送量が総量に到達した
        [UIView animateWithDuration:1.0f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            // 初期化
            [self removeFromSuperview];
            sharedInstance = nil;
        }];
    }
}

@end
