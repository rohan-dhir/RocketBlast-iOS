//
//  GameScene.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-16.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "CCNode.h"
#import "Rocket.h"
#import "GameData.h"
#import "Advertisements.h"
#import <CoreMotion/CoreMotion.h>

@interface GameScene : CCNode <CCPhysicsCollisionDelegate>

{
    CCPhysicsNode *_physicsNode;
    CCNode *speedFlow, *topBar, *bottomBar, *timer, *HUDnode, *progress, *progressBar, *startSymbol, *flag, *speedBar, *turtle, *rabbit, *speedBarProgress, *referenceNode, *referenceNode2, *effectNode;
    CCSprite *rocket;
    CMMotionManager *_motionManager;
    CCLabelTTF *score, *speed, *lives, *timeInterval;
    CCButton *_pause, *_continue, *_quit;
    CCNode *_pauseMenu, *_tutorial, *phoneRender;

    int goal, scorer, checkPointValue, timerInterval, extraLives;
    BOOL isUsingiPad;
}

+ (GameScene *)sharedScene;
+ (instancetype)sharedGameScene;
- (void)pause;
- (void)resume;
- (void)pauseTimer:(NSTimer *)timer1 pauseTimer2:(NSTimer *)timer2;
- (void)resumeTimer:(NSTimer *)timer1 resumeTimer2:(NSTimer *)timer2;

@property NSTimer *endGame, *changeInterval;
@property NSDate *endGamePause, *previousEndGameStart, *changeIntervalPause, *previousChangeIntervalStart;
@property (nonatomic, strong) id<ALSoundSource> timerSoundEffect;

@end
