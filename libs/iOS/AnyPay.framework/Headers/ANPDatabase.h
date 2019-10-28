//
//  ANPDatabase.h
//  AnyPay
//
//  Created by Ankit Gupta on 24/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnyPayTransaction.h"

@interface ANPDatabase : NSObject

+ (id<AnyPayTransaction>)getTransactionWithId:(NSString *)ID;
+ (NSArray<id<AnyPayTransaction>> *)getAllTransactions;

@end
