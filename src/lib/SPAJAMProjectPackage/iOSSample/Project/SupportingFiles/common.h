//
//  common.h
//
//  Created by saimushi on 2014/06/03.
//  Copyright (c) 2014年 shuhei_ohono. All rights reserved.
//

#ifndef Sample_common_h
#define Sample_common_h

#import <UIKit/UIKit.h>

// 定数定義読み込み
#import "define.h"

// UNICORN標準のカテゴリの読み込み
#import "UIImage+custom.h"
#import "UIDevice+platformName.h"
#import "UIScreen+property.h"
#import "NSData+Base64.h"
#import "NSData+Crypto.h"
#import "NSData+hex2bin.h"
#import "NSString+bin2hex.h"
#import "NSString+Crypto.h"
#import "NSString+UTF8URLEncoding.h"
#import "NSString+textsize.h"
#import "NSString+numberFormat.h"
#import "UIBarButtonItem+initwithimage.h"
#import "UIView+property.h"
#import "UIView+position.h"

// UNICORN付属のライブラリの読み込み
#import "Haneke.h"
#import "MProgress.h"
#import "MMessages.h"
#import "MStatusbarProgress.h"
#import "MProductAgent.h"
#import "MPurchaseAgent.h"
//#import "TrackingManager.h"

// UNICORNライブラリの読み込み
#import "AES.h"
#import "Request.h"
#import "SBJsonAgent.h"
#import "CustomAlert.h"
#import "ModelBase.h"
#import "ProjectModelBase.h"
#import "PurchaseModelBase.h"

// UNICORNカスタムUIパーツの読み込み
#import "UIViewControllerBase.h"
//#import "CustomWebView.h"

/* 全ての機能から突如呼ばれる可能性のあるViewControllerは、commonでimportしておく */
#import "TopViewController.h"
#import "SettingViewController.h"

/* 最後にAppDelegate */
#import "AppDelegate.h"

#endif
