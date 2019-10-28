//
//  ANPCardReaderConnectionStatuses.h
//  AnyPay
//
//  Created by Ankit Gupta on 17/01/18.
//  Copyright © 2018 Dan McCann. All rights reserved.
//

#ifndef ANPCardReaderConnectionStatuses_h
#define ANPCardReaderConnectionStatuses_h

typedef NS_ENUM(NSInteger, ANPCardReaderConnectionStatus) {
    ANPCardReaderConnectionStatusUNKNOWN = 0,
    ANPCardReaderConnectionStatusCONNECTING = 1,
    ANPCardReaderConnectionStatusCONNECTED,
    ANPCardReaderConnectionStatusDISCONNECTING,
    ANPCardReaderConnectionStatusDISCONNECTED
};

#endif /* ANPCardReaderConnectionStatuses_h */
