//
//  Checkpoint.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-17.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "Checkpoint.h"

@implementation Checkpoint

-(void)didLoadFromCCB

{
    checkpointPost.physicsBody.collisionType = @"checkpointPost";
    checkpointPost.physicsBody.sensor = FALSE;
}

@end
