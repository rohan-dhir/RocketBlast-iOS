//
//  GameOver.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-19.
//
//

#import "GameOver.h"

@implementation GameOver

{
    CCButton *_play, *_menu;
    CCNode *topBar, *bottomBar;
    BOOL isUsingiPad;
}

- (void)didLoadFromCCB

{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        isUsingiPad = TRUE;
    } else {
        isUsingiPad = FALSE;
    }

    if (![GameData sharedGameData].adsRemoved) {

        if ([GameData sharedGameData].gameOvers >= 7) {
            if ([[Advertisements sharedBanners].interstitial isReady])
            {
                [Advertisements sharedBanners].adNotDisplayed = FALSE;
                [[Advertisements sharedBanners].interstitial presentFromRootViewController:[CCDirector sharedDirector]];
            }
            [GameData sharedGameData].gameOvers = 0;
            [[GameData sharedGameData] save];
        } else {
            [[Advertisements sharedBanners] showBanner:[Advertisements sharedBanners].iAdBannerView];
            [[Advertisements sharedBanners] showBanner:[Advertisements sharedBanners].gAdBannerView];
            [Advertisements sharedBanners].adNotDisplayed = FALSE;
        }
    }

    if ([GameData sharedGameData].newHighScore) {
        hiScore.string = [NSString stringWithFormat:@"NEW HIGH SCORE!"];
    } else {
        int highScore = [GameData sharedGameData].highScore;
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

        NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:highScore]];

        hiScore.string = [NSString stringWithFormat:@"High Score: %@", formatted];
    }

    int _score = [GameData sharedGameData].score;
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:_score]];

    score.string = [NSString stringWithFormat:@"Your Score: %@", formatted];
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

- (void)back

{
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }

    CCScene* mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
