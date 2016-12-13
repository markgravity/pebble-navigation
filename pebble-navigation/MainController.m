//
//  MainController.m
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "MainController.h"

@interface MainController ()

@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initPebbleCentral];
    [self initGPSManager];
    [self fillURLTextfieldFromPasteboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - GPS Stuffs
-(void) initGPSManager{
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10;
    _locationManager.headingFilter = 1;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse){
        //TODO: show alert for failed grant permisson
    }
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* location = [locations lastObject];
    
    StepInfo *stepInfo = [self stepInfoInLocation:location radius:MAN_RADIUS];
    if (stepInfo){
        NSInteger distance = 0;
        NSInteger indexOfStep = [_steps indexOfObject:stepInfo];
        NSString *unitText = @"m";
        Maneuver maneuver;
        
        if (indexOfStep+1 < _steps.count){
            StepInfo *nextStepInfo = [_steps objectAtIndex:indexOfStep+1];
            maneuver = nextStepInfo.maneuver;
            distance = [nextStepInfo.startLocation distanceFromLocation:location];
        } else {
            // TODO: last step screen
            maneuver = ManeuverStraight;
            distance = [stepInfo.endLocation distanceFromLocation:location];
        }
        
        [_messageQueue enqueue:@{
                                 @(MESSAGE_KEY_DIRECTION_TYPE) : @(maneuver),
                                 @(MESSAGE_KEY_DISTANCE_TO_NEXT_TURN): @(distance).stringValue,
                                 @(MESSAGE_KEY_DISTANCE_UNIT_TEXT) : unitText,
                                 @(MESSAGE_KEY_NAVIGATION_STATUS) : @(NavigationStatusInRoute),
                                 }];
    } else {
        // TODO: out of range status
        StepInfo *lastStep = _steps.lastObject;
        NSInteger distance = [lastStep.endLocation distanceFromLocation:location];
        Maneuver maneuver = ManeuverStraight;
        NSString *unitText = @"m";
        _currentStepDegree = [location directionToLocation:lastStep.endLocation];
        [_messageQueue enqueue:@{
                                 @(MESSAGE_KEY_DIRECTION_TYPE) : @(maneuver),
                                 @(MESSAGE_KEY_DISTANCE_TO_NEXT_TURN): @(distance).stringValue,
                                 @(MESSAGE_KEY_DISTANCE_UNIT_TEXT) : unitText,
                                 @(MESSAGE_KEY_NAVIGATION_STATUS) : @(NavigationStatusWrongWay),
                                 }];
        
    }
    
}
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading{
    NSInteger manDegree = newHeading.trueHeading;
    NSInteger dDegree = _currentStepDegree - manDegree;
    if (dDegree < 0) {
        dDegree = 360 + dDegree;
    }
    
    [_messageQueue enqueue:@{
                             @(MESSAGE_KEY_DIRECTION_DEGREE) : @(dDegree)
                             }];
}
#pragma mark - Pebble Stuffs
-(void) initPebbleCentral{
    NSUUID *uuid =
    [[NSUUID alloc] initWithUUIDString:PEBBLE_APP_UUID];
    [PBPebbleCentral defaultCentral].appUUID = uuid;
    [PBPebbleCentral defaultCentral].delegate = self;
    
    [[PBPebbleCentral defaultCentral] run];
    self.startButton.enabled = NO;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    // Keep a reference to this watch
    _messageQueue = [[KBPebbleMessageQueue alloc] init];
    _messageQueue.watch = watch;
    self.startButton.enabled = YES;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    // If this was the recently connected watch, forget it
    if ([watch isEqual:_messageQueue.watch]) {
        _messageQueue = nil;
        self.startButton.enabled = NO;
    }
}

#pragma mark - Step Stuffs
-(StepInfo *) stepInfoInLocation:(CLLocation *) location radius:(NSInteger) radius{
    // TODO: should improve
    
    for (StepInfo *stepInfo in _steps) {
        NSArray *intersectionPoints = [GeoMath intersectionLineSegmentWithCircle:stepInfo.startLocation.coordinate
                                                               lineB:stepInfo.endLocation.coordinate
                                                   circleCenterPoint:location.coordinate circleRadius:radius];
        
        if (intersectionPoints.count > 0) {
            for (CLLocation *point in intersectionPoints) {
                if ([GeoMath geoPointInRangeLineSegment:stepInfo.startLocation.coordinate
                                                      B:stepInfo.endLocation.coordinate
                                                  point:point.coordinate]) {
                    return stepInfo;
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - Others
-(void) fillURLTextfieldFromPasteboard{
    NSString *unknowString  = [UIPasteboard generalPasteboard].string;
    if ([Utils isURL:unknowString])
        self.urlTextField.text = unknowString;
}
#pragma mark- OUTLET
- (IBAction)startTouchUp:(id)sender {
    if (_isNavigating) {
        [self.startButton setTitle:@"START" forState:UIControlStateNormal];
        
        [_locationManager stopUpdatingLocation];
        [_locationManager stopUpdatingHeading];
        
        _isNavigating = NO;
    } else{
        _steps = [[NSArray alloc] init];
        _didNotificationForStep = nil;
        _currentStepDegree = 0;
        
        self.startButton.enabled = NO;
        
        NSString *url = self.urlTextField.text;
        
        if (![url isEqualToString: @""]){
            [GoogleAPI directionWithShortUrl:url completed:^(NSDictionary *response, NSError *error){
                if (!error && [response[@"status"] isEqualToString:@"OK"]){
                    NSArray *steps = response[@"routes"][0][@"legs"][0][@"steps"];
                    
                    NSMutableArray *stepInfos = [[NSMutableArray alloc] init];
                    for (NSDictionary *step in steps) {
                        StepInfo *stepInfo = [[StepInfo alloc] initWithData:step];
                        [stepInfos addObject:stepInfo];
                    }
                    
                    _steps = stepInfos;
                    [_locationManager startUpdatingLocation];
                    [_locationManager startUpdatingHeading];
                    
                    // set config for navigating
                    _isNavigating = YES;
                    [self.startButton setTitle:@"STOP" forState:UIControlStateNormal];
                    self.startButton.enabled = YES;
                } else {
                    // TODO: show alert for failed get direction
                    self.startButton.enabled = YES;
                }
            }];
        } else {
            // TODO: show alert for empty url
        }
        
    }
}
@end
