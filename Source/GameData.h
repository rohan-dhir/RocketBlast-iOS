//
//  GameCentre.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-17.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameData : NSObject<GKGameCenterControllerDelegate, NSCoding>

{
    BOOL gameCentreAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCentreAvailable;
@property(assign, atomic) int sensitivityValues;
@property(assign, atomic) BOOL adsRemoved;
@property (assign, atomic) BOOL soundOff, success;
@property (assign, nonatomic) NSString *removeAdsPrice;
@property (assign, nonatomic) int interval;
@property (assign, nonatomic) double flameScale;
@property (assign, nonatomic) BOOL shouldShowSpark;
@property (assign, nonatomic) double positionOfSparkX;
@property (assign, nonatomic) double positionOfSparkY;
@property (assign, nonatomic) BOOL isNotFirstLaunch;

#pragma mark - Scoring Properties

@property(nonatomic, assign) int score;
@property(nonatomic, assign) int highScore;
@property(nonatomic, assign) BOOL newHighScore;

#pragma mark - Achievement Properties

@property (nonatomic, assign) int gameOvers;
@property(assign, atomic) BOOL showsCompletionBanner;
@property(nonatomic, retain) NSMutableDictionary *achievementsDictionary;

+ (GameData *)sharedInstance;
+ (instancetype)sharedGameData;

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier;

- (void)authenticateLocalUser;
- (void)showGameCentre: (NSString *) leaderBoardID;
- (void)showAchievements;
- (void)updateAchievements;
- (void)loadAchievements;
- (void)reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
- (void)reportScore;

- (void)save;
- (void)reset;

@end
