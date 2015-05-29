//
//  define.h
//
//  Created by saimushi on 2014/06/03.
//  Copyright (c) 2014年 shuhei_ohono. All rights reserved.
//

#ifndef Project_define_h
#define Project_define_h


/*** ビルド環境定義 ココから ***/

// Debug Runマクロ
#ifdef DEBUG


// Local-Development
# ifdef LOCAL
#  if TARGET_IPHONE_SIMULATOR
#   define TEST @"1"
#   define DEPROY_SETTING @"Local-Development Debug Run"
#   define PROTOCOL @"http"
#   define DOMAIN_NAME @"localhost"
#   define URL_BASE @"/workspace/UNICORN-project/lib/FrameworkManager/template/managedocs/api/"
#  endif
// XXX シミュレータ以外はエラー！

// Development
# elif defined DEV
#  define TEST @"1"
#  define DEPROY_SETTING @"Development Debug Run"
#  define PROTOCOL @"https"
#  define DOMAIN_NAME @"apitest.unicorn-project.com"
#  define URL_BASE @"/"

// Staging
# elif defined STAGING
#  define DEPROY_SETTING @"Staging Debug Run"
#  define PROTOCOL @"https"
#  define DOMAIN_NAME @"apistaging.unicorn-project.com"
#  define URL_BASE @"/"

// Distribution(フラグ無)
# else
#  define DEPROY_SETTING @"Distribution Debug Run"
#  define PROTOCOL @"https"
#  define DOMAIN_NAME @"api.unicorn-project.com"
#  define URL_BASE @"/"

# endif


// Adhoc Archive(配布ビルド)マクロ
#elif defined ADHOC


// Development
# elif defined DEV
#  define TEST @"1"
#  define DEPROY_SETTING @"Development Adhoc Run"
#  define PROTOCOL @"https"
#  define DOMAIN_NAME @"apitest.unicorn-project.com"
#  define URL_BASE @"/"

// Staging
# if defined STAGING
#  define DEPROY_SETTING @"Staging Adhoc Run"
#  define PROTOCOL @"https"
#  define DOMAIN_NAME @"apistaging.unicorn-project.com"
#  define URL_BASE @"/"

// Distribution(フラグ無)
# else
#  define DEPROY_SETTING @"Distribution Adhoc Run"
#  define PROTOCOL @"https"
#  define DOMAIN_NAME @"api.unicorn-project.com"
#  define URL_BASE @"/"

# endif


// Release Archive(Releaseビルド)マクロ
#else


// Distribution Archive(Releaseビルド)
# define DEPROY_SETTING @"Distribution Archive Run"
# define PROTOCOL @"https"
# define DOMAIN_NAME @"api.unicorn-project.com"
# define URL_BASE @"/"


#endif

/*** ビルド環境定義 ココまで ***/


// 各種マクロ
#define APPDELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


// デフォルトタイムアウトは短めの20秒に設定しています。
#define TIMEOUT 20
#define COOKIE_TOKEN_NAME @"token"
#define SESSION_CRYPT_KEY @"bdcc54fba7d9856c"
#define SESSION_CRYPT_IV @"ccfd172a95aqqd9a"

// In-App Purchase用の定義
#define SHARED_SECRET @"769bca60ace44eedaa8f2a3d5e02006d"
#define COOKIE_TOKEN_NAME @"token"
#define SESSION_CRYPT_KEY @"bdcc54fba7d9856c"
#define SESSION_CRYPT_IV @"ccfd172a95aqqd9a"
#define DEVICE_TOKEN_KEY_NAME @"device_token"

// サイズ定義
#define navibar_title_size 20

// 強制アップデート時にAppStoreに遷移する為のリダイレクトURL
#define FORCE_APP_UPDATE_REDIRECT @"RedirectAppStore"

#endif
