//
//  Advertisements.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-19.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "Advertisements.h"

@import GoogleMobileAds;

@implementation Advertisements

#define kAdMobIdentifier @"XXXX-AD-IDENTIFER-XXXX"
#define kAdMobBannerIdentifier @"XXXX-AD-IDENTIFER-XXXX"

//Shared Class

+(instancetype)loadInstance
{
    return [[Advertisements alloc] init];
}

+ (instancetype)sharedBanners {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });

    return sharedInstance;
}

static Advertisements *sharedHelper = nil;
+ (Advertisements *)sharedInstance

{
    if (!sharedHelper) {
        sharedHelper = [[Advertisements alloc] init];
    }

    return sharedHelper;
}

//iAd Methods
-(id)initAdBanner
{
    if ((self = [super init])) {

        if (![GameData sharedGameData].adsRemoved) {


            if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
                self.iAdBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
                self.iAdBannerView.delegate = self;

            } else {
                self.iAdBannerView = [[ADBannerView alloc] init];
            }

            [[[CCDirector sharedDirector]view]addSubview:self.iAdBannerView];
            [self.iAdBannerView setBackgroundColor:[UIColor clearColor]];
            [[[CCDirector sharedDirector]view]addSubview:self.iAdBannerView];

        [self layoutAnimated:NO];

    }
    }
    return self;

}

- (void)requestInterstitial

{
    self.interstitial = [self createAndLoadInterstitial];

}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:kAdMobIdentifier];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}


- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {

    [self showBanner:self.iAdBannerView];
    [self showBanner:self.gAdBannerView];

}

- (void)layoutAnimated:(BOOL)animated
{

    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
    CGRect bannerFrame = self.iAdBannerView.frame;

    if (self.iAdBannerView.bannerLoaded) {
        contentFrame.size.height -= bannerFrame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
        bannerFrame.origin.x = 0;

    } else {
        bannerFrame.origin.y = contentFrame.size.height;
        bannerFrame.origin.x = 0;
    }

    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.iAdBannerView.frame = bannerFrame;
    }];

    if (self.iAdBannerView.hidden) {
        [self hideBanner:self.iAdBannerView];
    }

}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"iAd loaded");
   if (adLoaded) {
        [self.gAdBannerView removeFromSuperview];
        adLoaded = NO;
    }

    [self layoutAnimated:YES];
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error

{
    NSLog(@"iAd Error: %@", error);

    [self layoutAnimated:YES];
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:kGADSimulatorID, nil];
    [self.gAdBannerView loadRequest:request];
    [self initAdmobBanner];

    [self.gAdBannerView loadRequest:request];
    [self initAdmobBanner];


    if (!adLoaded) {
        [self showBanner:self.gAdBannerView];
    }

}

//Admob Methods

- (void)initAdmobBanner

{
    if (![GameData sharedGameData].adsRemoved) {
        if (!adLoaded) {

            if (!self.gAdBannerView) {

                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

                    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
                    CGRect rect = CGRectMake(contentFrame.size.width/3, (contentFrame.size.height - GAD_SIZE_320x50.height) + GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
                    self.gAdBannerView = [[GADBannerView alloc] initWithFrame:rect];
                    self.gAdBannerView.adUnitID = kAdMobBannerIdentifier;
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    self.gAdBannerView.rootViewController = rootViewController;
                    self.gAdBannerView.delegate = self;
                    self.gAdBannerView.hidden = TRUE;
                    [[[CCDirector sharedDirector] view] addSubview:self.gAdBannerView];
                    if (self.adNotDisplayed) {
                        [self hideBanner:self.gAdBannerView];
                    } else {
                        [self showBanner:self.gAdBannerView];
                    }
                    adLoaded = YES;

                } else {
                    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
                    CGRect rect = CGRectMake(contentFrame.size.width/4, (contentFrame.size.height - GAD_SIZE_320x50.height) + GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
                    self.gAdBannerView = [[GADBannerView alloc] initWithFrame:rect];
                    self.gAdBannerView.adUnitID = kAdMobBannerIdentifier;
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    self.gAdBannerView.rootViewController = rootViewController;
                    self.gAdBannerView.delegate = self;
                    self.gAdBannerView.hidden = TRUE;
                    [[[CCDirector sharedDirector] view] addSubview:self.gAdBannerView];
                    if (self.adNotDisplayed) {
                        [self hideBanner:self.gAdBannerView];
                    } else {
                        [self showBanner:self.gAdBannerView];
                    }
                    adLoaded = YES;
                }
            }
        }
    }
}

-(void)hideBanner:(UIView*)banner
{
    if (banner && ![banner isHidden])
    {
        [UIView beginAnimations:@"hideBanner" context:nil];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        banner.hidden = TRUE;
        [UIView commitAnimations];
        //plays animation if banner loads after being hidden
    } else {
        [UIView beginAnimations:@"hideBanner" context:nil];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        banner.hidden = TRUE;
        [UIView commitAnimations];
    }
}

-(void)showBanner:(UIView*)banner
{
    if (banner && [banner isHidden])
    {
        [UIView beginAnimations:@"showBanner" context:nil];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        banner.hidden = FALSE;
    }
}


@end
