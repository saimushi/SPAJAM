//
//  MMessages.m
//
//  Created by saimushi on 2014/11/18.
//  Copyright (c) 2014年 cybird. All rights reserved.
//

#import "MMessages.h"


@interface MMessagelUILabel : UILabel
{
    NSString *messageID;
}
@property (strong, nonatomic) NSString *messageID;
@end

@implementation MMessagelUILabel
@synthesize messageID;
- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {10.0, 10.0, 0.0, 10.0};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end


@implementation MMessages
{
    BOOL showed;
    NSString *messageID;
    MMessagelUILabel *messageLabelView;
    UIButton *alphaBtn;
}

static MMessages *sharedInstance = nil;

@synthesize completionBlock;;
@synthesize messages;


+ (id)sharedInstance;
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance = [[self alloc] initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].delegate.window.frame.size.width, 64)];
        }
    }
    return sharedInstance;
}

+ (id)sharedInstance:(NSString *)argMessageID :(NSString *)argMessage :(MMessageType)argMessageType :(NSString *)argScheme :(MMessagesCompletionBlock)argCompletion;
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance = [[self alloc] initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].delegate.window.frame.size.width, 64)];
        }
        NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
        [messageDic setObject:argMessage forKey:@"message"];
        [messageDic setObject:[NSNumber numberWithInt:argMessageType] forKey:@"messageType"];
        if (nil == argScheme) {
            argScheme = @"";
        }
        [messageDic setObject:argScheme forKey:@"messageScheme"];
        [sharedInstance.messages setObject:messageDic forKey:argMessageID];
        sharedInstance.completionBlock = argCompletion;
    }
    return sharedInstance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil != self) {
        self.backgroundColor = [UIColor clearColor];
        messages = [[NSMutableDictionary alloc] init];
        showed = NO;
        messageID = nil;
        // ナビゲーションバー風の高さの見た目のUIViewを配置
        UIView *messageBGView = [[UIView alloc] init];
        messageBGView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].delegate.window.frame.size.width, 64);
        messageBGView.backgroundColor = [UIColor clearColor];
        messageBGView.clipsToBounds = YES;
        // メッセージ表示ラベルView
        messageLabelView = [[MMessagelUILabel alloc] initWithFrame:CGRectMake(0, -64, messageBGView.frame.size.width, messageBGView.frame.size.height)];
        messageLabelView.backgroundColor = [UIColor clearColor];
        messageLabelView.textColor = [UIColor whiteColor];
        messageLabelView.font = [UIFont boldSystemFontOfSize:12.0f];
        messageLabelView.numberOfLines = 3;
        [messageBGView addSubview:messageLabelView];
        [self addSubview:messageBGView];

        // 閉じるボタン(透明ボタン)
        alphaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        alphaBtn.frame = self.frame;
        alphaBtn.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
        alphaBtn.enabled = NO;
        [alphaBtn addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:alphaBtn];
    }
    return self;
}

/* 表示処理 */
- (void)show;
{
    if (NO == showed) {
        // 表示の準備
        alphaBtn.enabled = NO;
        showed = YES;
        messageLabelView.frame = CGRectMake(messageLabelView.frame.origin.x, -64, messageLabelView.frame.size.width, messageLabelView.frame.size.height);
        messageID = [[self.messages allKeys] objectAtIndex:0];
        messageLabelView.messageID = messageID;
        id message = [self.messages objectForKey:messageLabelView.messageID];
        messageLabelView.text = @"";
        if([message isKindOfClass:NSClassFromString(@"NSString")]){
            messageLabelView.text = [NSString stringWithFormat:@"%@", (NSString *)message];
            messageLabelView.backgroundColor = MMESSAGE_NOTIFY_BACKGROUND_COLOR;
        }
        else if([message isKindOfClass:NSClassFromString(@"NSMutableDictionary")]){
            messageLabelView.text = [NSString stringWithFormat:@"%@", [message objectForKey:@"message"]];
            messageLabelView.backgroundColor = MMESSAGE_NOTIFY_BACKGROUND_COLOR;
            messageLabelView.backgroundColor = MMESSAGE_NOTIFY_BACKGROUND_COLOR;
            if ([[message objectForKey:@"messageType"] intValue] == MMessageWarrning) {
                // 警告表示
                messageLabelView.textColor = MMESSAGE_WARRNING_FONT_COLOR;
                messageLabelView.backgroundColor = MMESSAGE_WARNING_BACKGROUND_COLOR;
            }
            else if ([[message objectForKey:@"messageType"] intValue] == MMessageError) {
                // エラー表示
                messageLabelView.textColor = MMESSAGE_ERROR_FONT_COLOR;
                messageLabelView.backgroundColor = MMESSAGE_ERROR_BACKGROUND_COLOR;
            }
        }
        if (nil != messageLabelView.text && ![messageLabelView.text isEqualToString:@""]){
            // Windowに通知を表示
            [[UIApplication sharedApplication].delegate.window addSubview:self];
            // 表示
            [UIView animateWithDuration:0.5f animations:^{
                messageLabelView.frame = CGRectMake(messageLabelView.frame.origin.x, 0, messageLabelView.frame.size.width, messageLabelView.frame.size.height);
            } completion:^(BOOL finished) {
                // 表示されたら閉じるボタンを有効に
                alphaBtn.enabled = YES;
                // 5秒滞在し、5秒後に閉じるを呼ぶ
                [self performSelector:@selector(hideAuto:) withObject:messageLabelView.messageID afterDelay:DISPLAY_TIME];
            }];
        }
        else {
            // 表示せずにfinalize
            [self.messages removeObjectForKey:messageLabelView.messageID];
            messageID = nil;
        }
    }
}

/* 5秒後に閉じる専用メソッド */
- (void)hideAuto:(NSString *)argMessageID;
{
    if(YES == showed && [messageID isEqualToString:argMessageID]){
        // 途中で閉じるが押されているかも知れないので、該当のメッセージインデックスのshowの時だけ自動で閉じる
        [self hide:nil];
    }
}

/* 非表示処理 */
- (void)hide:(id)sender;
{
    // 先ずはとにかくボタン無効化
    alphaBtn.enabled = NO;
    if (YES == showed) {
        showed = NO;
        NSString *scheme = [[self.messages objectForKey:messageLabelView.messageID] objectForKey:@"messageScheme"];
        if (nil != sender && nil != scheme && [scheme isKindOfClass:NSClassFromString(@"NSString")] && 0 < scheme.length) {
            // openURLを呼んであげる
            [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] handleOpenURL:[NSURL URLWithString:[scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
        // 非表示
        [UIView animateWithDuration:0.5f animations:^{
            messageLabelView.frame = CGRectMake(messageLabelView.frame.origin.x, 64, messageLabelView.frame.size.width, messageLabelView.frame.size.height);
        } completion:^(BOOL finished) {
            // 元の位置に戻す
            messageLabelView.frame = CGRectMake(messageLabelView.frame.origin.x, -64, messageLabelView.frame.size.width, messageLabelView.frame.size.height);
            // メッセージを表示した事を通知
            if (nil != self.completionBlock) {
                self.completionBlock(messageLabelView.messageID);
            }
            // いつまでもでてしまうので、配列から捨てる
            [self.messages removeObjectForKey:messageLabelView.messageID];
            messageID = nil;
            // 通知Viewを消して終了
            [self removeFromSuperview];
            // メッセージがまだあれば、次のメッセージを表示
            if (0 < self.messages.count){
                [self show];
            }
        }];
    }
}

+ (void)showMessage:(NSString *)argMessageID :(NSString *)argMessage :(MMessageType)argMessageType :(NSString *)argScheme completion:(MMessagesCompletionBlock)argCompletion;
{
    [[MMessages sharedInstance:argMessageID :argMessage :argMessageType :argScheme :argCompletion] show];
}

@end
