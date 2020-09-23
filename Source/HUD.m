//
//  HUD.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-19.
//
//

#import "HUD.h"
#import "GameScene.h"
#import "CCAnimationManager.h"

@implementation HUD

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    });
    
    return sharedInstance;
}

static HUD *sharedHelper = nil;
+ (HUD *)sharedInstance

{
    if (!sharedHelper) {
        sharedHelper = [[HUD alloc] init];
    }
    
    return sharedHelper;
}

- (void)didLoadFromCCB

{
    if ([GameData sharedGameData].interval > 0) {
        [self runAnimation:[GameData sharedGameData].interval];
    }
}

- (void)runAnimation:(int)duration

{
    CCAnimationManager* animationManager = self.userObject;
    [animationManager setPlaybackSpeed:1.0/duration];
    [animationManager runAnimationsForSequenceNamed:@"Progress"];
}

@end
