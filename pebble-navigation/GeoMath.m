//
//  GeoMath.m
//  pebble-navigation
//
//  Created by Mark G on 8/21/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "GeoMath.h"

@implementation GeoMath
+(NSArray *) intersectionLineSegmentWithCircle:(CLLocationCoordinate2D )A lineB:(CLLocationCoordinate2D )B circleCenterPoint:(CLLocationCoordinate2D )C circleRadius:(double) R{
    R = R/111000;
    
    double Ax = A.longitude;
    double Ay = A.latitude;
    double Bx = B.longitude;
    double By = B.latitude;
    double Cx = C.longitude;
    double Cy = C.latitude;
    // compute the euclidean distance between A and B
    
    double LAB = sqrt( (Bx -Ax)*(Bx -Ax)+(By-Ay)*(By-Ay) );
    
    // compute the direction vector D from A to B
    double Dx = (Bx-Ax)/LAB;
    double Dy = (By-Ay)/LAB;
    
    // Now the line equation is x = Dx*t + Ax, y = Dy*t + Ay with 0 <= t <= 1.
    
    // compute the value t of the closest point to the circle center (Cx, Cy)
    double t = Dx*(Cx-Ax) + Dy*(Cy-Ay);
    
    // This is the projection of C on the line from A to B.
    
    // compute the coordinates of the point E on line and closest to C
    double Ex = t*Dx+Ax;
    double Ey = t*Dy+Ay;
    
    // compute the euclidean distance from E to C
    double LEC = sqrt( (Ex-Cx)*(Ex-Cx)+(Ey-Cy)*(Ey-Cy) );
    
    // test if the line intersects the circle
    if( LEC < R )
    {
        // compute distance from t to circle intersection point
        double dt = sqrt( R*R - LEC*LEC);
        
        // compute first intersection point
        double Fx = (t-dt)*Dx + Ax;
        double Fy = (t-dt)*Dy + Ay;
        
        // compute second intersection point
        double Gx = (t+dt)*Dx + Ax;
        double Gy = (t+dt)*Dy + Ay;
        
        return @[[[CLLocation alloc] initWithLatitude:Fy longitude:Fx],
                 [[CLLocation alloc] initWithLatitude:Gy longitude:Gx]];
    }
    
    // else test if the line is tangent to circle
    else if( LEC == R )
        // tangent point to circle is E
        return @[[[CLLocation alloc] initWithLatitude:Ey longitude:Ex]];
        else
            return @[];
    
}

+(BOOL) geoPointInRangeLineSegment:(CLLocationCoordinate2D)A B:(CLLocationCoordinate2D)B point:(CLLocationCoordinate2D)P{
    BOOL passLng = (A.longitude <= B.longitude
                    &&  P.longitude >= A.longitude
                    && P.longitude <= B.longitude)
                    ||
                    (B.longitude < A.longitude
                     &&  P.longitude >= B.longitude
                     && P.longitude <= A.longitude);
    
    BOOL passLat = (A.latitude <= B.latitude
                    &&  P.latitude >= A.latitude
                    && P.latitude <= B.latitude)
                    ||
                    (B.latitude < A.latitude
                     &&  P.latitude >= B.latitude
                     && P.latitude <= A.latitude);
    
    return passLat && passLng;
}
@end
