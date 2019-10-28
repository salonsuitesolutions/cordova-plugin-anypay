//
//  ANPTerminal.h
//  AnyPay
//
//  Created by Ankit Gupta on 15/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import "ANPUser.h"
#import "ANPMeaningfulError.h"
#import "ANPEndpoint.h"

@protocol ANPTerminal <NSObject>

@property (nonatomic, strong) id<ANPEndpoint> _Nonnull endpoint;

@optional
@property (nonatomic, copy) NSString * _Nullable terminalID;
@property (nonatomic, copy) NSString * _Nullable terminalKey;
@property (nonatomic, strong) ANPUser * _Nullable user;
@property (nonatomic, copy) NSDate * _Nullable authenticationExpiryDate;

@required
- (nullable instancetype)initWithEndpoint:(nonnull id <ANPEndpoint>)endpoint;

- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)new NS_UNAVAILABLE;

- (void)authenticate:(void (^_Nonnull)(BOOL authenticated, ANPMeaningfulError *_Nullable))completionHandler;

@end
