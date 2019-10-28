//
//  ANPAmount.h
//  AnyPay
//
//  Created by Ankit Gupta on 20/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPAmount : NSObject

@property (nonatomic, readonly) NSString *stringValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly) NSDecimalNumber *decimalValue;

@property (nonatomic) BOOL isPercentageType;

- (instancetype)initWithDecimal:(NSDecimalNumber *)amount NS_DESIGNATED_INITIALIZER;

+ (instancetype)amountWithString:(NSString *)amountString;
+ (instancetype)amountWithDouble:(double)amount;
+ (instancetype)amountWithDecimal:(NSDecimalNumber *)amount;
+ (instancetype)zero;

- (ANPAmount *)add:(ANPAmount *)amountToAdd;
- (ANPAmount *)subtract:(ANPAmount *)amountToSubtract;

- (BOOL)greaterThanZero;

@end
