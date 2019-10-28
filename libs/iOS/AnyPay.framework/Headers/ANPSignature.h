//
//  ANPSignature.h
//  AnyPay
//
//  Created by Ankit Gupta on 14/05/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import AppKit;
#endif

#import "ANPDrawPath.h"

@interface ANPSignature : NSObject

@property (nonatomic, strong) NSMutableArray<ANPDrawPath *> *signaturePointsArray;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, strong) id info;

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIBezierPath *signaturePath;
#else
@property (nonatomic, strong) NSBezierPath *signaturePath;
#endif

@end
