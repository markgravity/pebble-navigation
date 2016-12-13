//
//  GoogleAPI.m
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "GoogleAPI.h"

@implementation GoogleAPI
+(void) directionForOrigin:(NSString *) origin
                      dest:(NSString *) dest
                 completed:(void(^)(NSDictionary *reponse, NSError *error)) completed{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSString *url = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@", origin, dest, GOOGLE_MAP_API_KEY];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:url
          parameters:nil
            progress:nil
             success:^(NSURLSessionTask *task, id response) {
                 completed(response, nil);
                 
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            // TODO: show alert when get direction failed
            completed(nil, error);
        }];
    });
}

+(NSDictionary *) googleMapDirectionURLParser:(NSString *)url{
    if ([url containsString:@"https://www.google.com/maps/dir/"]){
        url = [url stringByReplacingOccurrencesOfString:@"https://www.google.com/maps/dir/" withString:@""];
        NSArray *temp = [url componentsSeparatedByString:@"/"];
        
        return @{
                 @"origin" : temp[0],
                 @"destination" : temp[1]
                 };
    }
    return nil;
}

+(void) directionWithShortUrl:(NSString *)url
                                                completed:(void(^)(NSDictionary *response, NSError *error)) completed{
    [Utils getRedirectUrlOfUrl:url completed:^(NSString *redirectUrl){
        NSDictionary *info = [GoogleAPI googleMapDirectionURLParser:redirectUrl];
        if (info)
            [GoogleAPI directionForOrigin:info[@"origin"] dest:info[@"destination"] completed:completed];
        else {
            NSError *error = [NSError errorWithDomain:ERROR_DOMAIN code:0 userInfo:nil];
            completed(nil, error);
        }
    }];
}
@end
