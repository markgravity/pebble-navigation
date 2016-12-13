//
//  GoogleAPI.h
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "AppManager.h"

@interface GoogleAPI : NSObject
+(void) directionForOrigin:(NSString *) origin
                      dest:(NSString *) dest
                 completed:(void(^)(NSDictionary *reponse, NSError *error)) completed;
+(void) directionWithShortUrl:(NSString *)url
                                      completed:(void(^)(NSDictionary *response, NSError *error)) completed;
@end
