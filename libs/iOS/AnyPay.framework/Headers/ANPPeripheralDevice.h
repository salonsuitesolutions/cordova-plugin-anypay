//
//  ANPPeripheralDevice.h
//  AnyPay
//
//  Created by Ankit Gupta on 17/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPPeripheralDevice : NSObject

@property (nonatomic, copy) NSString *productID;
@property (nonatomic, copy) NSString *firmwareVersion;
@property (nonatomic) BOOL supportsOTAFirmwareUpdate;
@property (nonatomic, copy) NSString *batteryLevel;
@property (nonatomic, copy) NSString *batteryPercentage;

@end
