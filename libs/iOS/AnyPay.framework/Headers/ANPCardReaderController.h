//
//  ANPCardReaderController.h
//  AnyPay
//
//  Created by Ankit Gupta on 12/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#import "AnyPayCardReader.h"

@class AnyPayCardReader, ANPMeaningfulError, ANPBluetoothDevice, BBPOSDeviceEventDispatch, BBDeviceController, ANPBBPOSOTACredential, BBPOSDeviceOTAEventDispatch;
@interface ANPCardReaderController : NSObject

@property (nonatomic, readonly, nullable) AnyPayCardReader *connectedReader;
@property (nonatomic, readonly, nullable) BBPOSDeviceEventDispatch *eventDispatch;
@property (nonatomic, readonly, nullable) BBPOSDeviceOTAEventDispatch *otaEventDispatch;

- (void)subscribeOnCardReaderConnected:(void (^ _Nonnull)(AnyPayCardReader * _Nullable cardReader))connectionHandler;
- (void)subscribeOnCardReaderDisConnected:(void (^ _Nonnull)(void))handler;
- (void)subscribeOnCardReaderConnectionFailed:(void (^ _Nonnull)(ANPMeaningfulError * _Nullable error))errorHandler;
- (void)subscribeOnCardReaderError:(void (^ _Nonnull)(ANPMeaningfulError * _Nullable error))errorHandler;

- (void)unsubscribeOnCardReaderConnected:(void (^ _Nonnull)(AnyPayCardReader * _Nullable cardReader))connectionHandler;
- (void)unsubscribeOnCardReaderDisConnected:(void (^ _Nonnull)(void))handler;
- (void)unsubscribeOnCardReaderConnectionFailed:(void (^ _Nonnull)(ANPMeaningfulError * _Nullable error))errorHandler;
- (void)unsubscribeOnCardReaderError:(void (^ _Nonnull)(ANPMeaningfulError * _Nullable cardReader))errorHandler;

+ (instancetype _Nonnull )sharedController;

- (BOOL)isReaderConnected;

#pragma mark Audio
- (void)connectAudioReader;

#pragma mark Bluetooth
- (void)connectBluetoothReader:(void (^ _Nullable)(NSArray<ANPBluetoothDevice *> *_Nullable))availableBTReadersToConnectHandler;
- (void)connectToBluetoothReader:(ANPBluetoothDevice * _Nonnull)reader;
- (void)connectToBluetoothReaderWithSerial:(NSString * _Nonnull)serialNumber;

#pragma mark USB
- (void)connectUSBReader;

- (void)disconnectReader;

- (BBDeviceController *_Nullable)getBBDeviceControllerInstance;
- (void)enableReaderLogs:(BOOL)enable;

#pragma mark OTA

- (void)getTargetVersionWithData:(ANPBBPOSOTACredential * _Nonnull)credential completionHandler:(void (^ _Nonnull)(NSDictionary * _Nullable data, ANPMeaningfulError * _Nullable error))completionHandler;
- (void)getTargetVersionListWithData:(ANPBBPOSOTACredential * _Nonnull)credential completionHandler:(void (^ _Nonnull)(NSArray * _Nullable list, ANPMeaningfulError * _Nullable error))completionHandler;
- (void)updateFirmwareToTargetVersion:(NSString * _Nonnull)targetVersion credentials:(ANPBBPOSOTACredential * _Nonnull)credential completionHandler:(void (^ _Nonnull)(float percentUpdate, BOOL updated, ANPMeaningfulError * _Nullable))completionHandler;

@end
