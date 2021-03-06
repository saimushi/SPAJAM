//
//  AppDelegate.h
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import <CoreLocation/CoreLocation.h>

@class UserModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, ModelDelegate, CLLocationManagerDelegate>
{
    UIViewControllerBase *topViewController;
    UserModel *userModel;
    NSString *ownerID;
    NSString *familiarID;
    NSString *beconUDID;
    BOOL isLVUPOK;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewControllerBase *topViewController;
@property (strong, nonatomic) UserModel *userModel;
@property (strong, nonatomic) NSString *ownerID;
@property (strong, nonatomic) NSString *familiarID;
@property (strong, nonatomic) NSString *beconUDID;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeacon *nearestBeacon;

- (void)registerDeviceToken;
- (void)initializeGoogleAnalytics;
- (BOOL)isSimulator;
- (void)showLoading:(NSString *)argLoadingMessage;
- (void)showLoading;
- (void)hideLoading;
- (void)resignBecon;
@end
