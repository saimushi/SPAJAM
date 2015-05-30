//
//  GodMyPageViewController.m
//  Project
//
//  Created by inukai1 on 2015/05/30.
//  Copyright (c) 2015年 shuhei_ohono. All rights reserved.
//

#import "GodMyPageViewController.h"
#import "GodMyPageView.h"

@interface GodMyPageViewController ()
@property (nonatomic) CBPeripheralManager* peripheralManager;
@end


@implementation GodMyPageViewController

- (id)init
{
    self = [super init];
    if(self != nil){
        // デフォルトのスクリーン名をセット
        screenName = @"神さまマイページ";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:dispatch_get_main_queue()];
    
    [self beaconing];

    GodMyPageView *view = [[GodMyPageView alloc] initWithFrame:CGRectMake(0, 30, self.view.width, self.view.height - self.navigationController.navigationBar.frame.size.height - 64 - 5) WithDelegate:self];
    [self.view addSubview:view];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.peripheralManager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

- (void)beaconing
{
    NSLog(@"start becoing");
    //ビーコン情報を設定
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion* region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                     major:1
                                                                     minor:1
                                                                identifier:[uuid UUIDString]];
    
    NSDictionary* peripheralData = [region peripheralDataWithMeasuredPower:nil];//Default
    
    [self.peripheralManager startAdvertising:peripheralData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onButtonTap:(id)sender{
    NSLog(@"onButtonTap");
    [self beaconing];
}

@end
