//
//  IAPHelper.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-18.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "GameData.h"
#import "Menu.h"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

{
    NSNumberFormatter * _priceFormatter;
    NSString *_priceFormatted1, *_priceFormatted2, *_priceFormatted3, *_priceFormatted4;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(NSString *)productID;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
