//
//  MainController.h
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>
#import <AFNetworking/AFNetworking.h>
#import "AppManager.h"

#import "KBPebbleMessageQueue.h"
#import "StepInfo.h"
#import "GeoMath.h"
#import "GoogleAPI.h"
#import "NavigationStatusEnum.h"
#import "CLLocation+measuring.h"

@interface MainController : UIViewController<PBPebbleCentralDelegate,CLLocationManagerDelegate>{
    KBPebbleMessageQueue *_messageQueue;
    CLLocationManager *_locationManager;
    NSArray *_steps;
    StepInfo *_didNotificationForStep;
    BOOL _isNavigating;
    NSInteger _currentStepDegree;
}
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)startTouchUp:(id)sender;

@end
