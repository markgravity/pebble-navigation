//
//  GeoMath.h
//  pebble-navigation
//
//  Created by Mark G on 8/21/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface GeoMath : NSObject

+(NSArray *) intersectionLineSegmentWithCircle:(CLLocationCoordinate2D )A
                                         lineB:(CLLocationCoordinate2D )B
                             circleCenterPoint:(CLLocationCoordinate2D )C
                                  circleRadius:(double) R;
+(BOOL) geoPointInRangeLineSegment:(CLLocationCoordinate2D)A
                                 B:(CLLocationCoordinate2D)B
                             point:(CLLocationCoordinate2D)P;
@end
