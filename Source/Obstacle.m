//
//  Obstacle.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-16.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle

- (void)didLoadFromCCB

{
    int RandomObstacle = arc4random()%2;
    if (RandomObstacle == 0) {
        //plays default animation
    }

    if (RandomObstacle == 1) {
        CCAnimationManager* animationManager = self.userObject;
        [animationManager runAnimationsForSequenceNamed:@"Animation2"];
    }

    obstacle.physicsBody.collisionType = @"obstaclehit";
    obstacle.physicsBody.sensor = TRUE;
    point.physicsBody.collisionType = @"point";
    point.physicsBody.sensor = FALSE;
    grind1.physicsBody.collisionType = @"grind1";
    grind1.physicsBody.sensor = FALSE;
    grind2.physicsBody.collisionType = @"grind2";
    grind2.physicsBody.sensor = FALSE;
    grind3.physicsBody.collisionType = @"grind3";
    grind3.physicsBody.sensor = FALSE;
}

@end
