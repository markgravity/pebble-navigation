//
//  StepInfo.h
//  pebble-navigation
//
//  Created by Mark G on 8/20/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

typedef enum {
    ManeuverTurnSharpLeft = 0,
    ManeuverUturnRight,
    ManeuverTurnSlightRight,
    ManeuverMerge,
    ManeuverRoundaboutLeft,
    ManeuverRoundaboutRight,
    ManeuverUturnLeft,
    ManeuverTurnSlightLeft,
    ManeuverTurnLeft, // 8
    ManeuverRampRight,
    ManeuverTurnRight, // 10
    ManeuverForkRight,
    ManeuverStraight, // 12
    ManeuverForkLeft,
    ManeuverFerryTrain,
    ManeuverTurnSharpRight,
    ManeuverRampLeft,
    ManeuverFerry
} Maneuver;
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface StepInfo : NSObject
@property (strong, nonatomic) CLLocation *startLocation;
@property (strong, nonatomic) CLLocation *endLocation;
@property (assign, nonatomic) Maneuver maneuver;
@property (strong, nonatomic) NSString *maneuverText;
@property (strong, nonatomic) NSString *instructions;

-(instancetype) initWithData:(NSDictionary *) data;
-(CGFloat) distanceFromLocation:(CLLocation *) location;
@end
