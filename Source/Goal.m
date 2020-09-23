//
//  Goal.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-17.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "Goal.h"

@implementation Goal

- (void)didLoadFromCCB

{
    goalPost.physicsBody.collisionType = @"goalpost";
    goalPost.physicsBody.sensor = FALSE;
}

@end
