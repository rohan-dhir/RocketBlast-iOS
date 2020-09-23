//
//  GameCentre.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-17.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "GameData.h"
#import "GameScene.h"

@implementation GameData

@synthesize gameCentreAvailable;

static NSString* const SSGameDataHighScoreKey = @"highScore";

static NSString* const SSGameDataGameOversKey = @"gameOvers";

static NSString* const SSGameDataRemoveAdsKey = @"removeAds";
static NSString* const SSGameDataSoundToggleKey = @"soundToggle";
static NSString* const SSGameDataNotFirstLaunchKey = @"notFirstLaunch";

#pragma mark - Scoring, Loading & Saving Data

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.gameOvers forKey:SSGameDataGameOversKey];
    [encoder encodeInt:self.highScore forKey:SSGameDataHighScoreKey];
    [encoder encodeBool:self.adsRemoved forKey:SSGameDataRemoveAdsKey];
    [encoder encodeBool:self.isNotFirstLaunch forKey:SSGameDataNotFirstLaunchKey];
    [encoder encodeBool:self.soundOff forKey:SSGameDataSoundToggleKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _highScore = [decoder decodeIntForKey: SSGameDataHighScoreKey];

        _gameOvers = [decoder decodeIntForKey:SSGameDataGameOversKey];

        _adsRemoved = [decoder decodeBoolForKey:SSGameDataRemoveAdsKey];
        _soundOff = [decoder decodeBoolForKey:SSGameDataSoundToggleKey];
        _isNotFirstLaunch = [decoder decodeBoolForKey:SSGameDataNotFirstLaunchKey];
    }
    return self;
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }

    return [[GameData alloc] init];
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];

}

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });

    return sharedInstance;
}

- (void)reset

{
    self.highScore = 0;
    [self resetAchievements];
    self.gameOvers = 0;
    CCLOG(@"Stats reset");
}

-(void)resetAchievements{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)reportScore{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"HiScore"];
    score.value = self.highScore;

    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

#pragma mark - Initialization

static GameData *sharedHelper = nil;
+ (GameData *)sharedInstance

{
    if (!sharedHelper) {
        sharedHelper = [[GameData alloc] init];
    }

    return sharedHelper;
}

- (BOOL) isGameCentreAvailable

{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);

    return (gcClass && osVersionSupported);
}

//Sign User into Game Center
- (id)init

{
    if (self = [super init])
    {
        gameCentreAvailable = [self isGameCentreAvailable];
        if (gameCentreAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}


- (void)authenticationChanged {

    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        [self loadAchievements];
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }

}

- (void)authenticateLocalUser

{
    if (!gameCentreAvailable) return;

    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated");
    }

}

- (void) loadAchievements
{
    self.achievementsDictionary = [[NSMutableDictionary alloc] init];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {

    if (error != nil)
    {
        NSLog(@"Error in loading achievements: %@", error);
    }
    if (achievements != nil)
    {
        // Process the array of achievements.
        for (GKAchievement* achievement in achievements)
            [self.achievementsDictionary setObject: achievement forKey: achievement.identifier];

    }
}];
}

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{
    GKAchievement *achievement = [self.achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [self.achievementsDictionary setObject:achievement forKey:achievement.identifier];

    }
    return achievement;
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {

        if(error) NSLog(@"error reporting ach");

        for (GKAchievement *achievement in achievements) {
            if([achievement.identifier isEqualToString:identifier]) { //already submitted
                return ;
            }
        }

        GKAchievement *achievementToSend = [[GKAchievement alloc] initWithIdentifier:identifier];
        achievementToSend.percentComplete = percent;
        achievementToSend.showsCompletionBanner = YES;
        [achievementToSend reportAchievementWithCompletionHandler:NULL];

    }];
}

#pragma mark - User Functions

- (void) showGameCentre: (NSString*) leaderBoardID
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.leaderboardIdentifier = leaderBoardID;
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        [[CCDirector sharedDirector] presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)showAchievements
{
    GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController != nil)
    {
        achievementController.gameCenterDelegate = self;
        [[CCDirector sharedDirector] presentViewController: achievementController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
}

@end
