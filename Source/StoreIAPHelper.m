//
//  StoreIAPHelper.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-18.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "StoreIAPHelper.h"

@implementation StoreIAPHelper

+ (StoreIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static StoreIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"removeAds",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
