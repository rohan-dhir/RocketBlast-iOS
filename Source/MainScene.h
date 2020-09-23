//
//  MainScene.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-16.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "GameData.h"
#import "Advertisements.h"

@interface MainScene : CCNode

{
    CCLabelTTF *hiScore;
    CCNode *title, *topBar, *bottomBar;
    CCButton *_play, *_menu;
    CCPhysicsNode *_physicsNode;
}

@end
