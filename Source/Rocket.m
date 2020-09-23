//
//  Rocket.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-16.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "Rocket.h"

@implementation Rocket

- (void)didLoadFromCCB

{
    _rocket.physicsBody.collisionType = @"rocket";
    _rocket.physicsBody.sensor = FALSE;
}

- (void)update:(CCTime)delta

{
    flame.scaleY = [GameData sharedGameData].flameScale + 1.2;
}
@end
