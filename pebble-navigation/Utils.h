//
//  Utils.h
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+(void) getRedirectUrlOfUrl:(NSString *)url
                  completed:(void(^)(NSString *redirectURL)) completed;
+(BOOL) isURL:(NSString *) unknownString;
@end
