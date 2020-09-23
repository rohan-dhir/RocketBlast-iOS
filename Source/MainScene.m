//
//  MainScene.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-16.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

{
    NSMutableArray *_obstacles;
    BOOL isUsingiPad;
}

static const CGFloat firstObstaclePosition = 220.f;
static const CGFloat distanceBetweenObstacles = 700.f;
static const CGFloat _speed = 250.f;

- (void)didLoadFromCCB

{
  _obstacles = [NSMutableArray array];

  topBar.zOrder = DrawingOrderAbove;
  bottomBar.zOrder = DrawingOrderAbove;
  title.zOrder = DrawingOrderAbove;
  hiScore.zOrder = DrawingOrderAbove;
  _play.zOrder = DrawingOrderAbove;
  _menu.zOrder = DrawingOrderAbove;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        isUsingiPad = TRUE;
    } else {
        isUsingiPad = FALSE;
    }

    int highScore = [GameData sharedGameData].highScore;
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:highScore]];

    hiScore.string = [NSString stringWithFormat:@"High Score: %@", formatted];

    [[GameData sharedInstance] authenticateLocalUser];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    if (![GameData sharedGameData].adsRemoved) {
        [Advertisements sharedBanners].adNotDisplayed = FALSE;
        [[Advertisements sharedBanners] showBanner:[Advertisements sharedBanners].iAdBannerView];
        [[Advertisements sharedBanners] showBanner:[Advertisements sharedBanners].gAdBannerView];

        if (![Advertisements sharedBanners].adRequested) {
            [[Advertisements sharedBanners] initAdBanner];
            [Advertisements sharedBanners].adRequested = TRUE;
        }
       /*

        [[Advertisements sharedBanners] requestInterstitial];

        if ([[Advertisements sharedBanners].interstitial isReady]) {
            [[Advertisements sharedBanners].interstitial presentFromRootViewController:];
        }

        */
    }

//spawns background scene
    if (isUsingiPad)
    {
        [self spawnNewObstacleiPad];
        [self spawnNewObstacleiPad];
    } else {
        [self spawnNewObstacle];
        [self spawnNewObstacle];
    }
}

- (void)play

{
    if (![GameData sharedGameData].adsRemoved) {
        [Advertisements sharedBanners].adNotDisplayed = TRUE;
        [[Advertisements sharedBanners] hideBanner:[Advertisements sharedBanners].iAdBannerView];
        [[Advertisements sharedBanners] hideBanner:[Advertisements sharedBanners].gAdBannerView];
    }

    if (isUsingiPad)
    {
        CCScene* gameSceneiPad = [CCBReader loadAsScene:@"GameScene-iPad"];
        [[CCDirector sharedDirector] replaceScene:gameSceneiPad];

    } else {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (screenSize.width > 480.0f) {
            CCScene* gameScene = [CCBReader loadAsScene:@"GameScene"];
            [[CCDirector sharedDirector] replaceScene:gameScene];
        } else {
            CCScene* gameSceneSmall = [CCBReader loadAsScene:@"GameScene-smalliPhone"];
            [[CCDirector sharedDirector] replaceScene:gameSceneSmall];
        }
    }
}

- (void)menu

{
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }

    CCScene* menu = [CCBReader loadAsScene:@"Menu"];
    [[CCDirector sharedDirector] replaceScene:menu];
}

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderAbove,
    DrawingOrderObstacle
};

//generates background obstacles
- (void)spawnNewObstacle

{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;

    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }

    CCNode *obstacle = [CCBReader load:@"Obstacle"];
    obstacle.zOrder = DrawingOrderObstacle;

    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

- (void)spawnNewObstacleiPad

{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;

    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }

    CCNode *obstacle = [CCBReader load:@"Obstacle-iPad"];
    obstacle.zOrder = DrawingOrderObstacle;

    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}


- (void)update:(CCTime)delta

{
    _physicsNode.position = ccp(_physicsNode.position.x - (_speed  * delta), _physicsNode.position.y);

    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width)  {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [_physicsNode removeChild:obstacleToRemove];
        [_obstacles removeObject:obstacleToRemove];
        if (isUsingiPad)
        {
            [self spawnNewObstacleiPad];
        } else {
            [self spawnNewObstacle];
        }
    }
}

@end
