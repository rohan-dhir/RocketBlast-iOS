//
//  Advertisements.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-19.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "CCNode.h"
#import "GameData.h"
#import <iAd/iAd.h>

@import GoogleMobileAds;

@interface Advertisements : CCNode <ADBannerViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate>

{
    BOOL adLoaded;
}

@property (strong, nonatomic) ADBannerView *iAdBannerView;
@property (strong, nonatomic) GADBannerView *gAdBannerView;
@property (strong, nonatomic) GADInterstitial *interstitial;
@property BOOL adRequested;
@property (assign, nonatomic) BOOL adNotDisplayed;

+ (Advertisements *)sharedInstance;
+ (instancetype)sharedBanners;

-(void)hideBanner:(UIView*)banner;
-(void)showBanner:(UIView*)banner;
-(id) initAdBanner;
-(void)requestInterstitial;

@end
