//
//  StepInfo.m
//  pebble-navigation
//
//  Created by Mark G on 8/20/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "StepInfo.h"

@implementation StepInfo
-(instancetype) initWithData:(NSDictionary *) data{
    self = [super init];
    self.startLocation = [[CLLocation alloc] initWithLatitude:[data[@"start_location"][@"lat"] doubleValue] longitude:[data[@"start_location"][@"lng"] doubleValue]];
    self.endLocation = [[CLLocation alloc] initWithLatitude:[data[@"end_location"][@"lat"] doubleValue] longitude:[data[@"end_location"][@"lng"] doubleValue]];
    self.instructions = data[@"html_instructions"];
    
    NSString *maneuver = [data objectForKey:@"maneuver"];
    self.maneuver = ManeuverStraight;
    self.maneuverText = maneuver;
    if ([maneuver isEqualToString:@"turn-sharp-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"uturn-right"]){
        self.maneuver = ManeuverTurnRight;
    } else if ([maneuver isEqualToString:@"merge"]){
        self.maneuver = ManeuverStraight;
    } else if ([maneuver isEqualToString:@"roundabout-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"roundabout-right"]){
        self.maneuver = ManeuverTurnRight;
    } else if ([maneuver isEqualToString:@"uturn-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"turn-slight-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"turn-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"ramp-right"]){
        self.maneuver = ManeuverTurnRight;
    } else if ([maneuver isEqualToString:@"turn-right"]){
        self.maneuver = ManeuverTurnRight;
    } else if ([maneuver isEqualToString:@"fork-right"]){
        self.maneuver = ManeuverTurnRight;
    } else if ([maneuver isEqualToString:@"straight"]){
        self.maneuver = ManeuverStraight;
    } else if ([maneuver isEqualToString:@"fork-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"ferry-train"]){
        self.maneuver = ManeuverStraight;
    } else if ([maneuver isEqualToString:@"ramp-left"]){
        self.maneuver = ManeuverTurnLeft;
    } else if ([maneuver isEqualToString:@"ferry"]){
        self.maneuver = ManeuverStraight;
    }
    
    
    return self;

}

-(CGFloat) distanceFromLocation:(CLLocation *) location{
    double a = location.coordinate.latitude - self.startLocation.coordinate.latitude;
    double b = location.coordinate.longitude - self.startLocation.coordinate.longitude;
    double numberator = fabs(a*location.coordinate.longitude + b*location.coordinate.latitude);
    double denominator = sqrt(a*a + b*b);
    
    return numberator / denominator;
}
@end
