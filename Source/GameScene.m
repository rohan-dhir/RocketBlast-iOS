//
//  GameScene.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-16.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "GameScene.h"
#import "HUD.h"

@implementation GameScene

{
    double Movement, stretchFactor, _speed, baseSpeed, superSonic, movementFactor;
    CGFloat firstObstaclePosition;
    CGFloat distanceBetweenObstacles;
    BOOL gameStarted, resetTimer, canAddPoint, checkpointSpawned, skimmed, gamePaused, gameEnded, collisionEnabled, collided, gameOver;
    NSMutableArray *_obstacles;
    NSTimer *addPoint, *speedingUp;
}

#pragma mark - Initialization

- (void)didLoadFromCCB

{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        isUsingiPad = TRUE;
    } else {
        isUsingiPad = FALSE;
    }

    if (![GameData sharedGameData].adsRemoved) {
        if ([GameData sharedGameData].gameOvers >= 6) {
            [[Advertisements sharedBanners] requestInterstitial];
        }
    }

    baseSpeed = 400.f;
    Movement = 250.f;
    checkPointValue = 10;
    firstObstaclePosition = 220.f;
    distanceBetweenObstacles = 920.f;
    scorer = 0;

    extraLives = 1;
    lives.string = [NSString stringWithFormat:@"Lives: %d", extraLives];
    collisionEnabled = FALSE;
    collided = FALSE;
    gameOver = FALSE;

    timeInterval.visible = FALSE;
    HUDnode.visible = FALSE;
    [GameData sharedGameData].newHighScore = FALSE;
    gameStarted = FALSE;
    canAddPoint = TRUE;
    resetTimer = FALSE;
    gamePaused = FALSE;
    gameEnded = FALSE;
    checkpointSpawned = FALSE;
    _obstacles = [NSMutableArray array];

    rocket.physicsBody.sensor = FALSE;
    rocket.zOrder = DrawingOrderRocket;
    progress.zOrder = DrawingOrderProgress;
    progressBar.zOrder = DrawingOrderProgressBar;
    speedBar.zOrder = DrawingOrderProgressBar;
    speedBarProgress.zOrder = DrawingOrderProgress;
    startSymbol.zOrder = DrawingOrderProgress;
    flag.zOrder = DrawingOrderProgress;
    speed.zOrder = DrawingOrderLabel;
    score.zOrder = DrawingOrderLabel;
    turtle.zOrder = DrawingOrderProgressBar;
    rabbit.zOrder = DrawingOrderProgress;
    lives.zOrder = DrawingOrderLabel;
    topBar.zOrder = DrawingOrderBar;
    bottomBar.zOrder = DrawingOrderBar;
    _pauseMenu.zOrder = DrawingOrderPause;
    _continue.zOrder = DrawingOrderPauseMenuButtons;
    _quit.zOrder = DrawingOrderPauseMenuButtons;
    _physicsNode.collisionDelegate = self;
    rocket.physicsBody.sensor = FALSE;
    rocket.physicsBody.collisionType = @"rocket";

    if (![GameData sharedGameData].isNotFirstLaunch) {
        [GameData sharedGameData].isNotFirstLaunch = TRUE;
        _pause.visible = FALSE;
        NSTimer *tutorial, *phoneRemoval;
        tutorial = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(endTutorial) userInfo:nil repeats:NO];
        phoneRemoval = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(removePhoneRender) userInfo:nil repeats:NO];
    } else {
        [_tutorial removeFromParent];
        if (isUsingiPad) {
            [self spawnGoaliPad];
            [self spawnNewObstacleiPad];
        } else {
        [self spawnGoal];
        [self spawnNewObstacle];
        }
    }

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)removePhoneRender

{
    [phoneRender removeFromParent];
}

- (void)endTutorial

{
    [_tutorial removeFromParent];
    [[GameData sharedGameData] save];
    firstObstaclePosition = rocket.position.x + 10.f;
    if (isUsingiPad) {
        [self spawnGoaliPad];
        [self spawnNewObstacleiPad];
    } else {
        [self spawnGoal];
        [self spawnNewObstacle];
    }
    _pause.visible = TRUE;
}

- (id)init
{
    if (self = [super init])
    {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderObstacle,
    DrawingOrderRocket,
    DrawingOrderBar,
    DrawingOrderProgressBar,
    DrawingOrderProgress,
    DrawingOrderLabel,
    DrawingOrderPause,
    DrawingOrderPauseMenuButtons
};

- (void)onEnter

{
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
    [_motionManager startGyroUpdates];
}

+ (instancetype)sharedGameScene {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    });

    return sharedInstance;
}

static GameScene *sharedHelper = nil;
+ (GameScene *)sharedScene

{
    if (!sharedHelper) {
        sharedHelper = [[GameScene alloc] init];
    }

    return sharedHelper;
}

- (void)spawnNewObstacle

{
    if (scorer < checkPointValue || checkpointSpawned) {

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

    if (scorer >= checkPointValue && !checkpointSpawned)
    {
        [self spawnCheckpoint];
        checkpointSpawned = TRUE;
    }

}

- (void)spawnGoal

{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;

    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }

    CCNode *obstacle = [CCBReader load:@"Goal"];
    obstacle.zOrder = DrawingOrderObstacle;

    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];

}

- (void)spawnNewObstacleiPad

{
    if (scorer < checkPointValue || checkpointSpawned) {

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

    if (scorer >= checkPointValue && !checkpointSpawned)
    {
        [self spawnCheckpointiPad];
        checkpointSpawned = TRUE;
    }

}

- (void)spawnGoaliPad

{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;

    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }

    CCNode *obstacle = [CCBReader load:@"Goal-iPad"];
    obstacle.zOrder = DrawingOrderObstacle;

    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];

}

- (void)spawnCheckpoint

{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;

    checkpointSpawned = TRUE;

    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }

    CCNode *obstacle = [CCBReader load:@"CheckPoint"];
    obstacle.zOrder = DrawingOrderObstacle;

    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];

}

- (void)spawnCheckpointiPad

{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;

    checkpointSpawned = TRUE;

    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }

    CCNode *obstacle = [CCBReader load:@"CheckPoint-iPad"];
    obstacle.zOrder = DrawingOrderObstacle;

    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];

}

- (void)pause

{
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }

    _pauseMenu = [CCBReader load:@"Pause"];
    if (isUsingiPad) {
        _pauseMenu.position = ccp(96.0, 121.0);
    } else {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (screenSize.width > 480.0f) {
        _pauseMenu.position = ccp(124.0, 89.0);
        } else {
            _pauseMenu.position = ccp(80.0, 89.0);
        }
    }
    [self addChild:_pauseMenu];
    _continue.visible = TRUE;
    _quit.visible = TRUE;
    _pause.visible = FALSE;
    rocket.visible = FALSE;
    [self pauseTimer:self.endGame pauseTimer2:self.changeInterval];
    [[CCDirector sharedDirector] pause];
    CCLOG(@"Paused");

}

- (void)resume

{
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }

    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
    gamePaused = FALSE;
    [self resumeTimer:self.endGame resumeTimer2:self.changeInterval];
    _pause.visible = TRUE;
    _continue.visible = FALSE;
    _quit.visible = FALSE;
    rocket.visible = TRUE;
    [self removeChild:_pauseMenu];
}

- (void)quit

{
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];

    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];

    _pause.visible = FALSE;
    _continue.visible = FALSE;
    _quit.visible = FALSE;

    [self.changeInterval invalidate];
    self.changeInterval = nil;
    [self.endGame invalidate];
    self.endGame = nil;
    [speedingUp invalidate];
    speedingUp = nil;

    CCScene* mainScene = [CCBReader loadAsScene:@"MainScene"];
    CCTransition *moveUp = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionUp duration:0.4f];
    [[CCDirector sharedDirector] replaceScene: mainScene withTransition:moveUp];

}

- (void)pauseTimer:(NSTimer *)timer1 pauseTimer2:(NSTimer *)timer2

{
    //timer 1
    self.endGamePause = [NSDate dateWithTimeIntervalSinceNow:0];
    self.previousEndGameStart = [timer1 fireDate];
    [timer1 setFireDate:[NSDate distantFuture]];

    //timer 2
    self.changeIntervalPause = [NSDate dateWithTimeIntervalSinceNow:0];
    self.previousChangeIntervalStart = [timer2 fireDate];
    [timer2 setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer:(NSTimer *)timer1 resumeTimer2:(NSTimer *)timer2

{
    //timer 1
    float pauseTime = -1*[self.endGamePause timeIntervalSinceNow];
    [timer1 setFireDate:[self.previousEndGameStart initWithTimeInterval:pauseTime sinceDate:self.previousEndGameStart]];

    //timer 2
    float pauseTime2 = -1*[self.changeIntervalPause timeIntervalSinceNow];
    [timer2 setFireDate:[self.previousChangeIntervalStart initWithTimeInterval:pauseTime2 sinceDate:self.previousChangeIntervalStart]];
}

- (void)update:(CCTime)delta

{
    //Handles accelerometer updates
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMGyroData *gyroData = _motionManager.gyroData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CMRotationRate gyro = gyroData.rotationRate;

    CGFloat newYPosition = rocket.position.y - gyro.y * Movement * delta;
    newYPosition = clampf(newYPosition, 40, 280);
    rocket.position = CGPointMake(rocket.position.x, newYPosition);
    effectNode.position = CGPointMake(effectNode.position.x, newYPosition);

    CGFloat newXPosition = speedFlow.position.x - acceleration.y * 1500.f * delta;
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    speedFlow.position = CGPointMake(newXPosition, speedFlow.position.y);
    speedBarProgress.scaleX = newXPosition/(self.contentSize.width);
    _speed = newXPosition + baseSpeed;
    [GameData sharedGameData].flameScale = newXPosition/(self.contentSize.width);

    CGFloat newRocketPosition = rocket.position.x + acceleration.y * 290.f * delta;
    newRocketPosition = clampf(newRocketPosition, referenceNode2.position.x, referenceNode.position.x);
    rocket.position = CGPointMake(newRocketPosition, rocket.position.y);
    effectNode.position = CGPointMake(newRocketPosition, effectNode.position.y);

    //Moves rocket against physics node
    rocket.position = ccp(rocket.position.x + delta * _speed, rocket.position.y);
    effectNode.position = ccp(effectNode.position.x + delta * _speed, effectNode.position.y);
    referenceNode.position = ccp(referenceNode.position.x + delta * _speed, referenceNode.position.y);
    referenceNode2.position = ccp(referenceNode2.position.x + delta * _speed, referenceNode2.position.y);
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
        if (isUsingiPad) {
            [self spawnNewObstacleiPad];
        } else {
            [self spawnNewObstacle];
        }
    }

    if (_speed < 1225.04) {
        speed.string = [NSString stringWithFormat:@"%.0f km/h", _speed];
    } else if (_speed > 1225.04) {
        if (_speed > 1285.24) {
            _speed = 1285.24;
        }
        superSonic = _speed/1225.04;
        speed.string = [NSString stringWithFormat:@"MACH: %.2f", superSonic];
    }

}
#pragma mark - Collisions

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket goalpost:(CCNode *)goalpost {

    if (!gameStarted) {
        timeInterval.visible = TRUE;
        HUDnode.visible = TRUE;
        gameStarted = TRUE;
        timerInterval = checkPointValue + 10;
        timeInterval.string = [NSString stringWithFormat:@"%d", timerInterval];
        [GameData sharedGameData].interval = timerInterval;
        self.endGame = [NSTimer scheduledTimerWithTimeInterval:timerInterval + 0.5 target:self selector:@selector(gameOver) userInfo:nil repeats:NO];
        self.changeInterval = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
        [HUDnode removeChild:timer];
        timer = [CCBReader load:@"HUD"];
        [HUDnode addChild:timer];

        stretchFactor = (scorer/(checkPointValue + 1.0));
        progress.scaleX = stretchFactor;

        goalpost.physicsBody.sensor = TRUE;
    }
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket checkpointPost:(CCNode *)checkpointPost {
    if (!resetTimer) {
        resetTimer = TRUE;
        scorer = 0;
        if (![GameData sharedGameData].soundOff) {

            [[OALSimpleAudio sharedInstance] playEffect:@"CheckPoint.mp3"];
        }

        if (checkPointValue < 100) {
            checkPointValue += 5;
        }

        if (self.timerSoundEffect != nil) {
            [self.timerSoundEffect stop];
            self.timerSoundEffect = nil;
        }

        checkpointPost.physicsBody.sensor = TRUE;
        checkpointPost.visible = FALSE;
        checkpointSpawned = FALSE;
        [self.endGame invalidate];
        self.endGame = nil;
        [self.changeInterval invalidate];
        self.changeInterval = nil;
        stretchFactor = (scorer/(checkPointValue + 1.0));
        progress.scaleX = stretchFactor;
        extraLives += 1;
        lives.string = [NSString stringWithFormat:@"Lives: %d", extraLives];

        if (extraLives >= 1) {
            collisionEnabled = FALSE;
        }

        if (baseSpeed < 840.0) {
            if (referenceNode.position.x > referenceNode2.position.x) {
                referenceNode.position = ccp(referenceNode.position.x - 1.f, referenceNode.position.y);
            }
        }

        speedingUp = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(increaseSpeed) userInfo:nil repeats:NO];
    }
    return TRUE;
}


- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket point:(CCNode *)point
{
    if (canAddPoint) {
        canAddPoint = FALSE;
        point.physicsBody.sensor = TRUE;
        [point removeFromParent];
        goal++;
        scorer++;
        stretchFactor = (scorer/(checkPointValue + 1.0));
        progress.scaleX = stretchFactor;
        score.string = [NSString stringWithFormat:@"%d", goal];
        addPoint = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(pointAdder) userInfo:nil repeats:NO];

    }
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket grind1:(CCNode *)grind1

{
    if (!skimmed) {
        skimmed = TRUE;
        grind1.physicsBody.sensor = TRUE;

        CCNode *sparks = [CCBReader load:@"Sparks"];
        [grind1 addChild:sparks];
        if (![GameData sharedGameData].soundOff) {

            [[OALSimpleAudio sharedInstance] playEffect:@"Grind.mp3"];
        }

    }

    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket grind2:(CCNode *)grind2

{
    if (!skimmed) {
        skimmed = TRUE;
        grind2.physicsBody.sensor = TRUE;
        CCNode *sparks = [CCBReader load:@"Sparks"];
        [grind2 addChild:sparks];

        if (![GameData sharedGameData].soundOff) {

            [[OALSimpleAudio sharedInstance] playEffect:@"Grind.mp3"];
        }
    }

    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket grind3:(CCNode *)grind3

{
    if (!skimmed) {
        skimmed = TRUE;
        grind3.physicsBody.sensor = TRUE;
        CCNode *sparks = [CCBReader load:@"Sparks"];
        [grind3 addChild:sparks];

        if (![GameData sharedGameData].soundOff) {

            [[OALSimpleAudio sharedInstance] playEffect:@"Grind.mp3"];
        }
    }

    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair rocket:(CCSprite *)rocket obstaclehit:(CCNode *)obstaclehit

{
    if (!collisionEnabled && !collided) {
        collided = TRUE;
        [self checkLives];

        if (![GameData sharedGameData].soundOff) {

            [[OALSimpleAudio sharedInstance] playEffect:@"Respawn.mp3"];
        }
    }

    if (!gameEnded && collisionEnabled) {
        gameEnded = TRUE;
        CCLOG (@"hit");
        [self gameOver];
    }

    return TRUE;
}

#pragma mark - Collision Handler Methods

- (void)pointAdder

{
    canAddPoint = TRUE;
    skimmed = FALSE;
}

- (void)changeTime

{
    timerInterval -= 1;
    timeInterval.string = [NSString stringWithFormat:@"%d", timerInterval];

    if (![GameData sharedGameData].soundOff) {
        if (timerInterval == 5) {
            self.timerSoundEffect = [[OALSimpleAudio sharedInstance] playEffect:@"Timer.mp3"];
        }

        if (timerInterval == 0) {
            [self.timerSoundEffect stop];
            self.timerSoundEffect = nil;
        }
    }

}

- (void)increaseSpeed

{
    if (baseSpeed < 840.0) {
        if (baseSpeed < 740.0) {
            baseSpeed += 110;
            distanceBetweenObstacles += 70;
        } else {
            baseSpeed += 100;
            distanceBetweenObstacles += 50;
        }
        referenceNode2.position = ccp(referenceNode2.position.x - 1.f, referenceNode2.position.y);
        if (referenceNode.position.x > referenceNode2.position.x) {
            referenceNode.position = ccp(referenceNode.position.x - 1.f, referenceNode.position.y);
        }
    }
    [self.endGame invalidate];
    self.endGame = nil;

    resetTimer = FALSE;
    if (checkPointValue < 84) {
        timerInterval = checkPointValue + 10;
    } else {
        timerInterval = 105;
    }
    timeInterval.string = [NSString stringWithFormat:@"%d", timerInterval];

    self.endGame = [NSTimer scheduledTimerWithTimeInterval:timerInterval + 0.5 target:self selector:@selector(gameOver) userInfo:nil repeats:NO];
    self.changeInterval = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
    [GameData sharedGameData].interval = timerInterval;
    [HUDnode removeChild:timer];
    timer = [CCBReader load:@"HUD"];
    [HUDnode addChild:timer];

}

- (void)checkLives

{
    if (extraLives > 0) {
        extraLives -= 1;
        lives.string = [NSString stringWithFormat:@"Lives: %d", extraLives];
        rocket.visible = FALSE;
        rocket.physicsBody.sensor = TRUE;
        CCNode *popEffect = [CCBReader load:@"Pop"];
        [effectNode addChild:popEffect];

        NSTimer *resetObject;
        resetObject = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(resetRocket) userInfo:nil repeats:NO];
    }
}

- (void)resetRocket

{
    rocket.visible = TRUE;
    rocket.opacity -= 0.5;
    [effectNode removeAllChildren];

    NSTimer *completeReset;
    completeReset = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(resetComplete) userInfo:nil repeats:NO];
}

- (void)resetComplete

{
    rocket.opacity += 0.5;
    rocket.physicsBody.sensor = FALSE;
    collided = FALSE;
    if (extraLives == 0) {
        collisionEnabled = TRUE;
    }

}

-(void)appWillResignActive:(NSNotification*)note
{
    if (!gamePaused) {
        gamePaused = TRUE;
        [self pause];
    }
}

-(void)appWillBecomeActive:(NSNotification*)note
{
    [self resume];
    gamePaused = TRUE;
    if (gamePaused) {
        [self pause];
    }
}

-(void)appWillTerminate:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

#pragma mark - End-Game Methods

-(void)gameOver

{
    if (!gameOver) {
        gameOver = TRUE;
        rocket.visible = NO;
        rocket.physicsBody = nil;
        CCNode *popEffect = [CCBReader load:@"Pop"];
        [effectNode addChild:popEffect];
        timeInterval.string = [NSString stringWithFormat:@"%d", timerInterval];
        [self.changeInterval invalidate];
        self.changeInterval = nil;
        [speedingUp invalidate];
        speedingUp = nil;
        [self.endGame invalidate];
        self.endGame = nil;

        if (![GameData sharedGameData].soundOff) {

            [[OALSimpleAudio sharedInstance] playEffect:@"Explosion.mp3"];
        }

        if (self.timerSoundEffect != nil) {
            [self.timerSoundEffect stop];
            self.timerSoundEffect = nil;
        }
        if (goal > [GameData sharedGameData].highScore) {
            [GameData sharedGameData].highScore = goal;
            [GameData sharedGameData].newHighScore = TRUE;
            [[GameData sharedGameData] reportScore];
        }
        [GameData sharedGameData].gameOvers += 1;
        [GameData sharedGameData].score = goal;
        [[GameData sharedGameData] save];

        NSTimer *endSession;
        endSession = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(endGameScene) userInfo:nil repeats:NO];
    }
}

- (void)endGameScene

{
    [self.endGame invalidate];
    self.endGame = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    CCScene* gameOverTransition = [CCBReader loadAsScene:@"GameOver"];
    CCTransition *moveUp = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionUp duration:0.4f];
    [[CCDirector sharedDirector] replaceScene: gameOverTransition withTransition:moveUp];
}

- (void)onExit

{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
    [_obstacles removeAllObjects];
}

@end
