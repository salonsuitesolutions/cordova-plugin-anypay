//
//  ANPEndpoint.h
//  AnyPay
//
//  Created by Ankit Gupta on 15/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANPTerminal.h"
#import "ANPMeaningfulError.h"
#import "ANPGatewayResponse.h"
#import "ANPTransaction.h"

@protocol ANPEndpoint <NSObject>

@property (nonatomic, copy) NSString * _Nullable gatewayUrl;

- (void)submitTransaction:(ANPTransaction *_Nullable)transaction resultHandler:(void (^ _Nullable)(ANPGatewayResponse * _Nullable response, ANPMeaningfulError * _Nullable))resultHandler;

@optional
- (void)authenticateTerminal:(void (^_Nonnull)(BOOL authenticated, ANPMeaningfulError *_Nullable))completionHandler;

@end
