//
//  ViewController.m
//  pebble-navigation
//
//  Created by Mark G on 8/3/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Set UUID of watchapp

    NSUUID *myAppUUID =
    [[NSUUID alloc] initWithUUIDString:@"1ca78ef8-2b15-4a38-9e42-2ec611cb21a2"];
    [PBPebbleCentral defaultCentral].appUUID = myAppUUID;
    [PBPebbleCentral defaultCentral].delegate = self;
    
    [[PBPebbleCentral defaultCentral] run];
    
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
 
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10;
    
    NSString *url = @"https://goo.gl/maps/CjrSFKSmP4E2";
    self.urlTextField.text = url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pebble delegate
- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSString *status = [NSString stringWithFormat:@"Pebble connected: %@", [watch name]];
    [self log:status];
    self.statusLabel.text = status;
    
    // Keep a reference to this watch
    _messageQueue = [[KBPebbleMessageQueue alloc] init];
    _messageQueue.watch = watch;
    _connectedWatch = watch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);
    
    // If this was the recently connected watch, forget it
    if ([watch isEqual:_connectedWatch]) {
        _connectedWatch = nil;
    }
}

#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    StepInfo *stepInfo = [self getStepInfoForLocation:location];
    if (stepInfo) {
        NSInteger index = [_steps indexOfObject:stepInfo];
        if (index + 1 < _steps.count) {
            StepInfo *nextStepInfo = [_steps objectAtIndex:index+1];
            NSInteger distance = [nextStepInfo.startLocation distanceFromLocation:location];
            
            BOOL shouldVirbrate = NO;
            if (_didVirbrateForStep != nextStepInfo){
                
            }
            [self log:[NSString stringWithFormat:@"intr:%@", nextStepInfo.instructions]];
            
            [_messageQueue enqueue:@{
                                     @(0) : @(nextStepInfo.maneuver),
                                     @(1) : @(distance).stringValue,
                                     @(2) : @"m"
//                                     @(3) : @()
                                     }];
            
        } else {
            
            NSInteger distance = [stepInfo.endLocation distanceFromLocation:location];
            [self log:[NSString stringWithFormat:@"intr:%@", stepInfo.instructions]];
            
            [_messageQueue enqueue:@{
                                     @(0) : @(ManeuverStraight),
                                     @(1) : @(distance).stringValue,
                                     @(2) : @"m"
                                     }];

        }
    }
     else NSLog(@"FAILED!!!");
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
}
-(StepInfo *) getStepInfoForLocation:(CLLocation *)location{
    for (StepInfo *stepInfoInLoop in _steps) {
        
        NSArray *points = [GeoMath intersectionLineSegmentWithCircle:stepInfoInLoop.startLocation.coordinate
                                                               lineB:stepInfoInLoop.endLocation.coordinate
                                                   circleCenterPoint:location.coordinate circleRadius:MAN_RADIUS];
        
        if (points.count > 0) {
            for (CLLocation *point in points) {
                if ([GeoMath geoPointInRangeLineSegment:stepInfoInLoop.startLocation.coordinate
                                                      B:stepInfoInLoop.endLocation.coordinate
                                                  point:point.coordinate]) {
                    return stepInfoInLoop;
                }
            }
        }
    }
    
    return nil;
}
- (IBAction)startTouchUp:(id)sender {
    [self log:@"getting direction"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSString *sharedUrl = [self getRedirectUrlOfUrl:self.urlTextField.text];
        sharedUrl = [sharedUrl stringByReplacingOccurrencesOfString:@"https://www.google.com/maps/dir/" withString:@""];
        NSArray *temp = [sharedUrl componentsSeparatedByString:@"/"];
        
        NSString *gUrl = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=AIzaSyAIdVw3LiK6odOvxD5CbmnMtF5lyj-Nz4c", temp[0], temp[1]];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:gUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id response) {
            NSArray *steps = response[@"routes"][0][@"legs"][0][@"steps"];
            
            NSMutableArray *stepInfos = [[NSMutableArray alloc] init];
            for (NSDictionary *step in steps) {
                StepInfo *stepInfo = [[StepInfo alloc] initWithData:step];
                [stepInfos addObject:stepInfo];
            }
            
            _steps = stepInfos;
            [_locationManager startUpdatingLocation];
            self.statusLabel.text = @"ready to navigation";
            [self log:@"ready to navigation"];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    });
    
}

- (IBAction)testTouchUp:(id)sender {
    NSString *text = self.locationTextField.text;
    NSArray *parts = [text componentsSeparatedByString:@","];
    double lat = [parts[0] doubleValue];
    double lng = [parts[1] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    [self locationManager:_locationManager didUpdateLocations:@[location]];
}

-(NSString*) getRedirectUrlOfUrl:(NSString *)url{
//        NSURL *orinigalURL = [NSURL URLWithString:url];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:orinigalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
//        [request setHTTPMethod:@"HEAD"];
//        NSURLResponse *response = nil;
//        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//        NSURL *finalURL = response.URL;
//    
//    return finalURL.absoluteString;
    NSURL *originalUrl=[NSURL URLWithString:url];
    NSData *data=nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSURL *LastURL=[response URL];
    
    return LastURL.absoluteString;
}
-(void) log:(NSString *) message{
    self.logTextView.text = [self.logTextView.text stringByAppendingString:@"\n"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:message];
//    self.logTextView.contentOffset = CGPointMake(0, self.logTextView.contentSize.height);

}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}
@end
