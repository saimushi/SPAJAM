//
//  AppDelegate.h
//
//  Created by saimushi on 2014/09/19.
//  Copyright (c) 2014年 saimushi. All rights reserved.
//

#import "common.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, ModelDelegate,CLLocationManagerDelegate>
{
    UIViewControllerBase *topViewController;
    NSString *ownerID;
    NSString *familiarID;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewControllerBase *topViewController;
@property (strong, nonatomic) NSString *ownerID;
@property (strong, nonatomic) NSString *familiarID;
@property (strong, nonatomic) NSUUID *proximityUUID;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeacon *nearestBeacon;

- (void)registerDeviceToken;
- (void)initializeGoogleAnalytics;
- (BOOL)isSimulator;
- (void)showLoading:(NSString *)argLoadingMessage;
- (void)showLoading;
- (void)hideLoading;
@end
