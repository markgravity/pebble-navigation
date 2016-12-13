//
//  Utils.m
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(void) getRedirectUrlOfUrl:(NSString *)url
                       completed:(void(^)(NSString *redirectURL)) completed{
    NSURL *originalUrl=[NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    [[urlSession dataTaskWithRequest:request completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error){
        completed(response.URL.absoluteString);
    }] resume];
    
}
+(BOOL) isURL:(NSString *) unknownString{
    NSURL *candidateURL = [NSURL URLWithString:unknownString];
    // WARNING > "test" is an URL according to RFCs, being just a path
    // so you still should check scheme and all other NSURL attributes you need
    if (candidateURL && candidateURL.scheme && candidateURL.host) {
        // candidate is a well-formed url with:
        //  - a scheme (like http://)
        //  - a host (like stackoverflow.com)
        return YES;
    }
    
    return NO;
}
@end
