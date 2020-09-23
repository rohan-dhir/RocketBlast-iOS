//
//  HUD.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-19.
//
//

#import "CCNode.h"
#import "GameScene.h"
#import "GameData.h"

@interface HUD : CCNode

+ (HUD *)sharedInstance;
+ (instancetype)sharedGameData;

- (void)runAnimation:(int) duration;


@end
