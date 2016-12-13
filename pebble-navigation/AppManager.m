//
//  AppManager.m
//  pebble-navigation
//
//  Created by Mark G on 8/23/16.
//  Copyright © 2016 Mark G. All rights reserved.
//

#import "AppManager.h"
static AppManager *_defaultManager;
@implementation AppManager
+(instancetype) defaultManager{
    if (!_defaultManager) {
        _defaultManager = [[AppManager alloc] init];
    }
    
    return _defaultManager;
}


-(void) registerDefaultSettings{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              SETTING_DISTANCE_TO_NOTIFY : @"100"
                                                              }];
}

@end
