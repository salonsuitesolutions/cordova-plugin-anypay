//
//  AnyPayTerminal.h
//  AnyPay
//
//  Created by Ankit Gupta on 10/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANPTerminal.h"

@interface AnyPayTerminal : NSObject<ANPTerminal>

- (nonnull instancetype)initWithEndpoint:(nonnull id <ANPEndpoint>)endpoint NS_DESIGNATED_INITIALIZER;
- (void)assignTerminalID:(nonnull NSString *)terminalID terminalKey:(nonnull NSString *)terminalKey gatewayURL:(nullable NSString *)gatewayURL;

@end
