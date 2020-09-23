//
//  IAPHelper.m
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-18.
//  Copyright (c) 2015 Rohan Dhir. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface IAPHelper () <SKProductsRequestDelegate>
@end

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

#define kRemoveAdsProductIdentifier @"removeAds"

@implementation IAPHelper {

    SKProductsRequest * _productsRequest;

    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Checks for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
        skProduct.productIdentifier,
        skProduct.localizedTitle,
        skProduct.price.floatValue);
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        if ([skProduct.productIdentifier isEqualToString:kRemoveAdsProductIdentifier]) {
            _priceFormatted4 = [_priceFormatter stringFromNumber:skProduct.price];
            [[Menu sharedInstance] receiveID:skProduct.productIdentifier assignPrice:_priceFormatted4];
        }
    }
    
    _completionHandler(YES, skProducts);
    //_completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    //_completionHandler = nil;
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(NSString *)productID {
    
    NSLog(@"Buying %@...", productID);
    
    SKMutablePayment *payment = [[SKMutablePayment alloc] init];
    payment.productIdentifier = productID;

    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    [[Menu sharedInstance] unlockPurchase:productIdentifier];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
@end
