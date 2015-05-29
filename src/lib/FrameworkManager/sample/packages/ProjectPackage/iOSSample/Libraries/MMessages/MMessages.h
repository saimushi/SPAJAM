//
//  MMessages.m
//
//  Created by saimushi on 2014/11/18.
//  Version:1.0
//

#import <UIKit/UIKit.h>

//#define MMESSAGE_NOTIFY_BACKGROUND_COLOR [UIColor colorWithRed:0.60 green:1.00 blue:0.60 alpha:0.9f]
//#define MMESSAGE_WARNING_BACKGROUND_COLOR [UIColor colorWithRed:1.00 green:0.84 blue:0.00 alpha:0.9f]
//#define MMESSAGE_ERROR_BACKGROUND_COLOR [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:0.9f]
//#define MMESSAGE_NOTIFY_FONT_COLOR [UIColor whiteColor]
//#define MMESSAGE_WARRNING_FONT_COLOR [UIColor grayColor]
//#define MMESSAGE_ERROR_FONT_COLOR [UIColor whiteColor]
#define MMESSAGE_NOTIFY_BACKGROUND_COLOR [UIColor colorWithRed:0.67 green:0.84 blue:0.20 alpha:0.9f]
#define MMESSAGE_WARNING_BACKGROUND_COLOR [UIColor colorWithRed:1.00 green:0.56 blue:0.35 alpha:0.9f]
#define MMESSAGE_ERROR_BACKGROUND_COLOR [UIColor colorWithRed:0.97 green:0.39 blue:0.10 alpha:0.9f]
#define MMESSAGE_NOTIFY_FONT_COLOR [UIColor whiteColor]
#define MMESSAGE_WARRNING_FONT_COLOR [UIColor whiteColor]
#define MMESSAGE_ERROR_FONT_COLOR [UIColor whiteColor]

#define DISPLAY_TIME 10.0f

typedef void (^MMessagesCompletionBlock)(NSString *messageIdentifier);
typedef enum{
    MMessageNotify,// 通常通知
    MMessageWarrning,// 警告
    MMessageError,// 異常
} MMessageType;

@interface MMessages : UIView
{
    MMessagesCompletionBlock completionBlock;
    NSMutableDictionary *messages;
}

@property (strong, nonatomic) MMessagesCompletionBlock completionBlock;
@property (strong, nonatomic) NSMutableDictionary *messages;

+ (void)showMessage:(NSString *)argMessageID :(NSString *)argMessage :(MMessageType)argMessageType :(NSString *)argScheme completion:(MMessagesCompletionBlock)argCompletion;

@end
