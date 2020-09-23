//
//  Menu.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-17.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "Menu.h"
#import "StoreIAPHelper.h"

@implementation Menu

{
    NSArray *_products;
}

#define kRemoveAdsProductIdentifier @"removeAds"

- (void)didLoadFromCCB

{
    _removeAds.enabled = FALSE;
    _restore.enabled = FALSE;
    [self reload];

    if ([GameData sharedGameData].adsRemoved) {
        checkMark.visible = TRUE;
    }

    if ([GameData sharedGameData].soundOff) {
        soundToggle.selected = TRUE;
    } else {
        soundToggle.selected = FALSE;
    }
}

static Menu *sharedHelper = nil;
+ (Menu *)sharedInstance

{
    if (!sharedHelper) {
        sharedHelper = [[Menu alloc] init];
    }

    return sharedHelper;
}
- (void)receiveID:(NSString *)productIdentifier assignPrice:(NSString *)productPrice

{
    if ([productIdentifier isEqualToString:kRemoveAdsProductIdentifier]) {
        [GameData sharedGameData].removeAdsPrice = productPrice;
    }
}

- (void)reload

{
    _products = nil;

    [[StoreIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
     {
         if (success) {
             CCLOG(@"Success");
             [GameData sharedGameData].success = YES;
             _products = products;

             if (![GameData sharedGameData].adsRemoved) {
                 _removeAds.enabled = TRUE;
                 _price.visible = TRUE;
                 _price.string = [NSString stringWithFormat:@"%@", [GameData sharedGameData].removeAdsPrice];
             } else {
                 _removeAds.enabled = FALSE;
                 _price.visible = FALSE;
                 checkMark.visible = TRUE;
             }
             _restore.enabled = TRUE;


         } else {
             CCLOG(@"Failed");
             [GameData sharedGameData].success = NO;
         }
     }];
}


- (void)back

{
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }

    CCScene* menu = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:menu];
    [[GameData sharedGameData] save];
}

- (void)toggleSound

{
    if ([GameData sharedGameData].soundOff) {
        [GameData sharedGameData].soundOff = FALSE;
        soundToggle.selected = NO;
        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    } else {
        [GameData sharedGameData].soundOff = TRUE;
        soundToggle.selected = YES;
    }
}

- (void)gameCentre

{
    [[GameData sharedGameData] showGameCentre:@"HiScore"];
}

- (void)removeAds

{
    [[StoreIAPHelper sharedInstance] buyProduct:kRemoveAdsProductIdentifier];
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }
}

- (void)restore

{
     [[StoreIAPHelper sharedInstance] restoreCompletedTransactions];
    if (![GameData sharedGameData].soundOff) {

        [[OALSimpleAudio sharedInstance] playEffect:@"Tap.mp3"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {

    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            *stop = YES;
        }
    }];

}
- (void)unlockPurchase:(NSString *)purchase

{
    if ([purchase isEqualToString: kRemoveAdsProductIdentifier]) {
        if (![GameData sharedGameData].adsRemoved) {
            [self doRemoveAds];
        }
    }
}

- (void)doRemoveAds

{
    [GameData sharedGameData].adsRemoved = TRUE;
    [[Advertisements sharedBanners].iAdBannerView removeFromSuperview];
    [[Advertisements sharedBanners].gAdBannerView removeFromSuperview];
    [Advertisements sharedBanners].adNotDisplayed = TRUE;
    _removeAds.enabled = FALSE;
    _price.visible = FALSE;
    checkMark.visible = TRUE;
    [[GameData sharedGameData] save];
}

- (void)update:(CCTime)delta

{
    if ([GameData sharedGameData].adsRemoved) {
        _removeAds.enabled = FALSE;
        _price.visible = FALSE;
        checkMark.visible = TRUE;
    }
}

@end
