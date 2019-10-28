//
//  AnyPayEndpoint.h
//  AnyPay
//
//  Created by Ankit Gupta on 11/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import "ANPEndpoint.h"

@interface AnyPayEndpoint : NSObject<ANPEndpoint>

- (NSString *)getGatewayURL;
- (void)setGatewayURL:(NSString *)url;

- (instancetype)initWithGatewayURL:(NSString *)url;

@end
