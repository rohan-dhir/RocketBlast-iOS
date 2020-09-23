//
//  Menu.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-17.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "CCNode.h"
#import "GameData.h"
#import "Advertisements.h"

@interface Menu : CCNode

{
    CCButton *_back, *_gameCentre, *_removeAds, *_restore, *soundToggle;
    CCLabelTTF *_price;
    CCNode *checkMark;
}

+(Menu *)sharedInstance;

- (void)receiveID:(NSString *)productIdentifier assignPrice:(NSString *)productPrice;

- (void)unlockPurchase:(NSString*)purchase;

@end
