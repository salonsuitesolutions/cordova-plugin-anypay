/********* AnyPayCordova.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
@import AnyPay;

@interface AnyPayCordova : CDVPlugin {
  // Member variables go here.
}

@property (nonatomic) AnyPay *anyPay;
@property (nonatomic) ANPTransaction *refTransaction;

- (void)authenticateWorldnetTerminal:(CDVInvokedUrlCommand*)command;
- (void)startEMVSale:(CDVInvokedUrlCommand*)command;
- (void)startKeyedSale:(CDVInvokedUrlCommand*)command;
- (void)disconnect:(CDVInvokedUrlCommand*)command;
- (void)subscribeOnCardReaderConnected:(CDVInvokedUrlCommand*)command;
- (void)subscribeOnCardReaderDisconnected:(CDVInvokedUrlCommand*)command;
- (void)subscribeToCardReaderEvent:(CDVInvokedUrlCommand*)command;
- (void)subscribeOnCardReaderConnectFailed:(CDVInvokedUrlCommand*)command;
- (void)subscribeOnCardReaderError:(CDVInvokedUrlCommand*)command;
- (void)connectToBluetoothReader:(CDVInvokedUrlCommand*)command;
- (void)connectAudioReader:(CDVInvokedUrlCommand*)command;

@property (nonatomic) NSString *readerEventcallbackId;
@property (nonatomic) NSString *signatureRequiredCallbackId;

@end

@implementation AnyPayCordova

- (void)initializeSDK:(CDVInvokedUrlCommand*)command {
    //This method call is needed for Android. Simulating for iOS
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE] callbackId:command.callbackId];
}

- (void)authenticateWorldnetTerminal:(CDVInvokedUrlCommand*)command {
    __block CDVPluginResult* pluginResult = nil;
    NSString *terminalId = [command.arguments objectAtIndex:0];
    NSString *terminalKey = [command.arguments objectAtIndex:1];
    NSString *gatewayURL = [command.arguments objectAtIndex:2];

    ANPWorldnetTerminal *terminal = [[ANPWorldnetTerminal alloc] initWithTerminalID:terminalId terminalKey:terminalKey gatewayURL:gatewayURL];
    _anyPay = [AnyPay initializeWithTerminal:terminal];

    [_anyPay.terminal authenticate:^(BOOL authenticated, ANPMeaningfulError * _Nullable error) {
        if (!error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:authenticated];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.detail];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)startEMVSale:(CDVInvokedUrlCommand*)command {
    __block CDVPluginResult* pluginResult = nil;

    ANPWorldnetTransaction *transaction = [[ANPWorldnetTransaction alloc] initWithType:ANPTransactionType_SALE];

    NSDictionary *transactionDict = [command.arguments objectAtIndex:0];
    [transaction setValuesForKeysWithDictionary:transactionDict];

    _refTransaction = transaction;

    @try {
        if ([[transactionDict allKeys] containsObject:@"totalAmount"]) {
            if (transactionDict[@"totalAmount"] != [NSNull null]) {
//                if ([[transactionDict[@"totalAmount"] allKeys] containsObject:@"value"]) {
//                }

                transaction.totalAmount = [ANPAmount amountWithString:[transactionDict[@"totalAmount"] stringValue]];
            }
        }

        if ([[transactionDict allKeys] containsObject:@"subtotal"]) {
            if (transactionDict[@"subtotal"] != [NSNull null]) {
//                if ([[transactionDict[@"subtotal"] allKeys] containsObject:@"value"]) {
//                    transaction.subtotal = [ANPAmount amountWithString:[transactionDict[@"subtotal"][@"value"] stringValue]];
//                }

                transaction.subtotal = [ANPAmount amountWithString:[transactionDict[@"subtotal"] stringValue]];
            }
        }

        if ([[transactionDict allKeys] containsObject:@"tax"]) {
            if (transactionDict[@"tax"] != [NSNull null]) {
//                if ([[transactionDict[@"tax"] allKeys] containsObject:@"value"]) {
//                    transaction.tax = [ANPAmount amountWithString:[transactionDict[@"tax"][@"value"] stringValue]];
//                }

                transaction.tax = [ANPAmount amountWithString:[transactionDict[@"tax"] stringValue]];
            }

        }

        if ([[transactionDict allKeys] containsObject:@"tip"]) {
            if (transactionDict[@"tip"] != [NSNull null]) {
//                if ([[transactionDict[@"tip"] allKeys] containsObject:@"value"]) {
//                    transaction.tip = [ANPAmount amountWithString:[transactionDict[@"tip"][@"value"] stringValue]];
//                }

                transaction.tip = [ANPAmount amountWithString:[transactionDict[@"tip"] stringValue]];

            }

        }

        if ([[transactionDict allKeys] containsObject:@"fee"]) {
            if (transactionDict[@"fee"] != [NSNull null]) {
//                if ([[transactionDict[@"fee"] allKeys] containsObject:@"value"]) {
//                    transaction.fee = [ANPAmount amountWithString:[transactionDict[@"fee"][@"value"] stringValue]];
//                }

                transaction.fee = [ANPAmount amountWithString:[transactionDict[@"fee"] stringValue]];
            }

        }

        if ([[transactionDict allKeys] containsObject:@"externalId"]) {
            if (transactionDict[@"externalId"] != [NSNull null]) {
                transaction.externalID = transactionDict[@"externalId"];
            }
        }

        //Due to issue with corepay currency calculation, AnyPay skips auto-set of currency
        if ([[transactionDict allKeys] containsObject:@"currency"]) {
            if (transactionDict[@"currency"] != [NSNull null]) {
                transaction.currency = transactionDict[@"currency"];
            }
        }

        if ([[transactionDict allKeys] containsObject:@"cardInterfaceModes"]) {
            NSArray *arr = transactionDict[@"cardInterfaceModes"];
            if ([arr containsObject:@"TAP"] && [arr containsObject:@"SWIPE"] && [arr containsObject:@"INSERT"]) {
                [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceSwipeOrInsertOrTap;
            }
            else if ([arr containsObject:@"TAP"] && [arr containsObject:@"SWIPE"] && ![arr containsObject:@"INSERT"]) {
                [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceSwipeOrTap;
            }
            else if (![arr containsObject:@"TAP"] && [arr containsObject:@"SWIPE"] && [arr containsObject:@"INSERT"]) {
                [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceSwipeOrInsert;
            }
            else if (![arr containsObject:@"TAP"] && [arr containsObject:@"SWIPE"] && ![arr containsObject:@"INSERT"]) {
                [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceSwipe;
            }
            else if ([arr containsObject:@"TAP"] && ![arr containsObject:@"SWIPE"] && [arr containsObject:@"INSERT"]) {
                [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceInsertOrTap;
            }
            else {
                [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceSwipeOrInsertOrTap;
            }
        }
        else {
            [ANPCardReaderController sharedController].connectedReader.selectedCardInterface = ANPCardReaderInterfaceSwipeOrInsertOrTap;
        }
    } @catch (NSException *exception) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Transaction JSON sent"] callbackId:command.callbackId];
    } @finally {

    }

    [((ANPWorldnetTransaction *)transaction) setOnSignatureRequired:^{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE];
        result.keepCallback = @0;
        [self.commandDelegate sendPluginResult:result callbackId:_signatureRequiredCallbackId];
    }];

    [transaction execute:^(ANPTransactionStatus status, ANPMeaningfulError * _Nullable error) {
        if (!error) {

            NSMutableDictionary *dict = ((NSDictionary *)[transaction performSelector:@selector(getAsDictionary) withObject:nil]).mutableCopy;

            if ([[dict allKeys] containsObject:@"gatewayResponse"]) {
                NSMutableDictionary *gResponseDict = ((NSDictionary *)dict[@"gatewayResponse"]).mutableCopy;

                if ([[gResponseDict allKeys] containsObject:@"transactionResponse"]) {
                    [gResponseDict removeObjectForKey:@"transactionResponse"];
                }

                if ([[gResponseDict allKeys] containsObject:@"transactionTime"]) {
                    [gResponseDict removeObjectForKey:@"transactionTime"];
                }

                dict[@"gatewayResponse"] = gResponseDict;
            }

            if ([[dict allKeys] containsObject:@"transactionTime"]) {
                [dict removeObjectForKey:@"transactionTime"];
            }

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.detail];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } cardReaderEvent:^(ANPMeaningfulMessage * _Nullable message) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message.message];
        result.keepCallback = @1;
        [self.commandDelegate sendPluginResult:result callbackId:_readerEventcallbackId];
    }];
}

- (void)startKeyedTransaction:(CDVInvokedUrlCommand*)command {
    __block CDVPluginResult* pluginResult = nil;

    NSDictionary *transactionDict = [command.arguments objectAtIndex:0];

    ANPTransaction *transaction = [[ANPWorldnetTransaction alloc] initWithType:[ANPTransactionTypes enumValue:transactionDict[@"type"]]];

    [transaction setValuesForKeysWithDictionary:transactionDict];

    _refTransaction = transaction;

    @try {
//        if ([[transactionDict allKeys] containsObject:@"totalAmount"]) {
//            if (transactionDict[@"totalAmount"] != [NSNull null]) {
//                if ([[transactionDict[@"totalAmount"] allKeys] containsObject:@"value"]) {
//                    transaction.totalAmount = [ANPAmount amountWithString:[transactionDict[@"totalAmount"][@"value"] stringValue]];
//                }
//            }
//        }
//
//        if ([[transactionDict allKeys] containsObject:@"subtotal"]) {
//            if (transactionDict[@"subtotal"] != [NSNull null]) {
//                if ([[transactionDict[@"subtotal"] allKeys] containsObject:@"value"]) {
//                    transaction.subtotal = [ANPAmount amountWithString:[transactionDict[@"subtotal"][@"value"] stringValue]];
//                }
//            }
//
//        }
//
//        if ([[transactionDict allKeys] containsObject:@"tax"]) {
//            if (transactionDict[@"tax"] != [NSNull null]) {
//                if ([[transactionDict[@"tax"] allKeys] containsObject:@"value"]) {
//                    transaction.tax = [ANPAmount amountWithString:[transactionDict[@"tax"][@"value"] stringValue]];
//                }
//            }
//
//        }
//
//        if ([[transactionDict allKeys] containsObject:@"tip"]) {
//            if (transactionDict[@"tip"] != [NSNull null]) {
//                if ([[transactionDict[@"tip"] allKeys] containsObject:@"value"]) {
//                    transaction.tip = [ANPAmount amountWithString:[transactionDict[@"tip"][@"value"] stringValue]];
//                }
//            }
//
//        }
//
//        if ([[transactionDict allKeys] containsObject:@"fee"]) {
//            if (transactionDict[@"fee"] != [NSNull null]) {
//                if ([[transactionDict[@"fee"] allKeys] containsObject:@"value"]) {
//                    transaction.fee = [ANPAmount amountWithString:[transactionDict[@"fee"][@"value"] stringValue]];
//                }
//            }
//
//        }

        if ([[transactionDict allKeys] containsObject:@"totalAmount"]) {
            if (transactionDict[@"totalAmount"] != [NSNull null]) {
                //                if ([[transactionDict[@"totalAmount"] allKeys] containsObject:@"value"]) {
                //                }

                transaction.totalAmount = [ANPAmount amountWithString:[transactionDict[@"totalAmount"] stringValue]];
            }
        }

        if ([[transactionDict allKeys] containsObject:@"subtotal"]) {
            if (transactionDict[@"subtotal"] != [NSNull null]) {
                //                if ([[transactionDict[@"subtotal"] allKeys] containsObject:@"value"]) {
                //                    transaction.subtotal = [ANPAmount amountWithString:[transactionDict[@"subtotal"][@"value"] stringValue]];
                //                }

                transaction.subtotal = [ANPAmount amountWithString:[transactionDict[@"subtotal"] stringValue]];
            }
        }

        if ([[transactionDict allKeys] containsObject:@"tax"]) {
            if (transactionDict[@"tax"] != [NSNull null]) {
                //                if ([[transactionDict[@"tax"] allKeys] containsObject:@"value"]) {
                //                    transaction.tax = [ANPAmount amountWithString:[transactionDict[@"tax"][@"value"] stringValue]];
                //                }

                transaction.tax = [ANPAmount amountWithString:[transactionDict[@"tax"] stringValue]];
            }
        }

        if ([[transactionDict allKeys] containsObject:@"tip"]) {
            if (transactionDict[@"tip"] != [NSNull null]) {
                //                if ([[transactionDict[@"tip"] allKeys] containsObject:@"value"]) {
                //                    transaction.tip = [ANPAmount amountWithString:[transactionDict[@"tip"][@"value"] stringValue]];
                //                }

                transaction.tip = [ANPAmount amountWithString:[transactionDict[@"tip"] stringValue]];

            }
        }

        if ([[transactionDict allKeys] containsObject:@"fee"]) {
            if (transactionDict[@"fee"] != [NSNull null]) {
                //                if ([[transactionDict[@"fee"] allKeys] containsObject:@"value"]) {
                //                    transaction.fee = [ANPAmount amountWithString:[transactionDict[@"fee"][@"value"] stringValue]];
                //                }

                transaction.fee = [ANPAmount amountWithString:[transactionDict[@"fee"] stringValue]];
            }

        }

        if ([[transactionDict allKeys] containsObject:@"externalId"]) {
            if (transactionDict[@"externalId"] != [NSNull null]) {
                transaction.externalID = transactionDict[@"externalId"];
            }
        }

        //Due to issue with corepay currency calculation, AnyPay skips auto-set of currency
        if ([[transactionDict allKeys] containsObject:@"currency"]) {
            if (transactionDict[@"currency"] != [NSNull null]) {
                transaction.currency = transactionDict[@"currency"];
            }
        }
    } @catch (NSException *exception) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Transaction JSON sent"] callbackId:command.callbackId];
    } @finally {

    }

    if (((transaction.transactionType == ANPTransactionType_VOID) || (transaction.transactionType == ANPTransactionType_REFUND) || (transaction.transactionType == ANPTransactionType_REVERSEAUTH))) {

        if (transaction.externalID.length > 0) {
            transaction = [transaction createReversal];
        }
    }

    [transaction execute:^(ANPTransactionStatus status, ANPMeaningfulError * _Nullable error) {
        if (!error) {

            NSMutableDictionary *dict = ((NSDictionary *)[transaction performSelector:@selector(getAsDictionary) withObject:nil]).mutableCopy;

            if ([[dict allKeys] containsObject:@"gatewayResponse"]) {
                NSMutableDictionary *gResponseDict = ((NSDictionary *)dict[@"gatewayResponse"]).mutableCopy;

                if ([[gResponseDict allKeys] containsObject:@"transactionResponse"]) {
                    [gResponseDict removeObjectForKey:@"transactionResponse"];
                }

                if ([[gResponseDict allKeys] containsObject:@"transactionTime"]) {
                    [gResponseDict removeObjectForKey:@"transactionTime"];
                }

                dict[@"gatewayResponse"] = gResponseDict;
            }

            if ([[dict allKeys] containsObject:@"transactionTime"]) {
                [dict removeObjectForKey:@"transactionTime"];
            }

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.detail];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)disconnectReader:(CDVInvokedUrlCommand*)command {
    [[ANPCardReaderController sharedController] disconnectReader];
}

- (void)subscribeOnCardReaderConnected:(CDVInvokedUrlCommand*)command {

    [[ANPCardReaderController sharedController] subscribeOnCardReaderConnected:^(AnyPayCardReader * _Nullable cardReader) {
        NSLog(@"OnCardReaderConnected --> %@", cardReader.productID);

        NSMutableDictionary *dict = [[cardReader valueForKey:@"deviceInfo"] mutableCopy];
        [dict setValue:[cardReader name] forKey:@"name"];

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        result.keepCallback = @1;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)subscribeOnCardReaderDisconnected:(CDVInvokedUrlCommand*)command {
    [[ANPCardReaderController sharedController] subscribeOnCardReaderDisConnected:^{
        NSLog(@"OnCardReaderDisConnected ");

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Card Reader Disconnected"];
        result.keepCallback = @1;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)subscribeToCardReaderEvent:(CDVInvokedUrlCommand*)command {
    _readerEventcallbackId = command.callbackId;
}

- (void)subscribeOnCardReaderConnectFailed:(CDVInvokedUrlCommand*)command {
    [[ANPCardReaderController sharedController] subscribeOnCardReaderConnectionFailed:^(ANPMeaningfulError * _Nullable error) {
        NSLog(@"OnCardReaderConnectionFailed --> %@", error);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:error.detail];
        result.keepCallback = @1;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)subscribeOnCardReaderError:(CDVInvokedUrlCommand*)command {
    [[ANPCardReaderController sharedController] subscribeOnCardReaderError:^(ANPMeaningfulError * _Nullable error) {
        NSLog(@"OnCardReaderError --> %@", error);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:error.detail];
        result.keepCallback = @1;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)connectToBluetoothReader:(CDVInvokedUrlCommand*)command {
    [[ANPCardReaderController sharedController] connectBluetoothReader:^(NSArray<ANPBluetoothDevice *> * _Nullable readers) {
    }];
}

- (void)connectAudioReader:(CDVInvokedUrlCommand*)command {
    [[ANPCardReaderController sharedController] connectAudioReader];
}

- (void)setOnSignatureRequired:(CDVInvokedUrlCommand *)command {
    _signatureRequiredCallbackId = command.callbackId;
}

- (void)proceed:(CDVInvokedUrlCommand *)command {
    NSArray *signaturePoints = [command.arguments objectAtIndex:0];
    ANPSignature *signature = [self pointsToSignatureArray:signaturePoints];

    ((ANPCardTransaction *)_refTransaction).signature = signature;
    [_refTransaction proceed];
}

- (void)updateSignature:(CDVInvokedUrlCommand *)command {
    NSArray *signaturePoints = [command.arguments objectAtIndex:0];
    ANPSignature *signature = [self pointsToSignatureArray:signaturePoints];

    if (_refTransaction && signature) {
        [(ANPWorldnetTransaction *)_refTransaction updateWithSignature:signature resultHandler:^(BOOL sent, ANPMeaningfulError * _Nullable error) {
            CDVPluginResult *result = nil;
            if (sent) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:FALSE];
            }

            result.keepCallback = @0;
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
    else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:FALSE];
        result.keepCallback = @0;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }

}

- (void)fetchTransactions:(CDVInvokedUrlCommand *)command {
    [(ANPWorldnetTerminal *)_anyPay.terminal fetchTransactions:[command.arguments objectAtIndex:0] orderID:[command.arguments objectAtIndex:1] fromDate:nil toDate:nil responseHandler:^(NSDictionary * _Nullable transactions) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:transactions];
        result.keepCallback = @0;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)adjustTip:(CDVInvokedUrlCommand *)command {
    if (_refTransaction) {
        [(ANPWorldnetTransaction *)_refTransaction updateWithTipAdjustment:[[ANPTipAdjustmentLineItem alloc] initWithName:@"Tip" rate:[ANPAmount amountWithString:[command.arguments objectAtIndex:0]] surchargeCalculationMethod:ANPSurchargeCalculationMethod_FLAT_RATE] resultHandler:^(BOOL submitted, ANPMeaningfulError * _Nullable err) {

            CDVPluginResult *result = nil;
            if (submitted) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:FALSE];
            }

            result.keepCallback = @0;
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
    else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:FALSE];
        result.keepCallback = @0;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)sendReceipt:(CDVInvokedUrlCommand *)command {
    if (_refTransaction) {
        [(ANPWorldnetTransaction *)_refTransaction sendReceiptToEmail:[command.arguments objectAtIndex:0] phone:nil resultHandler:^(BOOL sent, ANPMeaningfulError * _Nullable err) {
            CDVPluginResult *result = nil;
            if (sent) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:FALSE];
            }

            result.keepCallback = @0;
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
    else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:FALSE];
        result.keepCallback = @0;
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (ANPSignature *)pointsToSignatureArray:(NSArray *)signaturePoints {
    ANPSignature *signature = [ANPSignature new];
    signature.signaturePointsArray = @[].mutableCopy;

    [signaturePoints enumerateObjectsUsingBlock:^(NSArray *  _Nonnull sArray, NSUInteger idx, BOOL * _Nonnull stop) {
        [sArray enumerateObjectsUsingBlock:^(NSDictionary<NSString *, NSNumber *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ANPDrawPath *drawPath = [ANPDrawPath new];

            if (idx == 0) {
                drawPath.start = [NSValue valueWithCGPoint:CGPointMake(obj[@"x"].floatValue, obj[@"y"].floatValue)];
            }
            else if (idx == (sArray.count - 1)) {
                drawPath.end = [NSValue valueWithCGPoint:CGPointMake(obj[@"x"].floatValue, obj[@"y"].floatValue)];
            }
            else {
                drawPath.move = [NSValue valueWithCGPoint:CGPointMake(obj[@"x"].floatValue, obj[@"y"].floatValue)];
            }

            [signature.signaturePointsArray addObject:drawPath];
        }];
    }];

    return signature;
}

@end
