//
//  AnyPay.h
//  AnyPay
//
//  Created by Ankit Gupta on 10/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for AnyPay.
FOUNDATION_EXPORT double AnyPayVersionNumber;

//! Project version string for AnyPay.
FOUNDATION_EXPORT const unsigned char AnyPayVersionString[];

#import "ANPTerminal.h"
#import "ANPWorldnetTerminal.h"
#import "ANPCardReaderController.h"
#import "ANPWorldnetTransaction.h"
#import "ANPWorldnetReferenceTransaction.h"
#import "ANPDatabase.h"
#import "ANPWorldnetUser.h"
#import "ANPBBPOSOTACredential.h"
#import "ANPEndpoint.h"
#import "AnyPayEndpoint.h"
#import "ANPTerminals.h"
#import "ANPKeyedTransactionWorkflow.h"
#import "ANPWorldnetTerminalSettings.h"
#import "ANPTaxLineItem.h"
#import "ANPTipLineItem.h"
#import "ANPTipAdjustmentLineItem.h"
#import "ANPFeeLineItem.h"
#import "ANPSurchargeLineItem.h"
#import "ANPLineItem.h"
#import "ANPSignature.h"
#import "ANPDrawPath.h"
#import "ANPSignatureView.h"


//--------------------------------------------------------//
                /*  ... AnyPay ... */
//------------------------------------------------------//

@interface AnyPay : NSObject

@property (nonnull, nonatomic, strong) id<ANPTerminal> terminal;

+ (nullable instancetype)initializeWithTerminal:(nullable id<ANPTerminal>) terminal;

+ (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)new NS_UNAVAILABLE;


#pragma mark - Information
+ (nonnull NSString *)currentVersion;

@end
