//
//  ViewController.h
//  pebble-navigation
//
//  Created by Mark G on 8/3/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>
#import <AFNetworking/AFNetworking.h>
#import "KBPebbleMessageQueue.h"
#import "StepInfo.h"
#import "GeoMath.h"
#import "AppManager.h"

@import GoogleMaps;

#define API_KEY @"AIzaSyAIdVw3LiK6odOvxD5CbmnMtF5lyj-Nz4c"

#define DISTANCE_TO_VIRBRATE 100
@interface ViewController : UIViewController<PBPebbleCentralDelegate,CLLocationManagerDelegate>{
    KBPebbleMessageQueue *_messageQueue;
    PBWatch *_connectedWatch;
    CLLocationManager *_locationManager;
    CLLocation *_startLocation;
    NSArray *_steps;
    StepInfo *_didVirbrateForStep;
}
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
- (IBAction)startTouchUp:(id)sender;
- (IBAction)testTouchUp:(id)sender;


@end

