//
//  DataPackage.h
//  WMSPlusdot
//
//  Created by Sir on 15-4-14.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEUtils.h"

static const int PACKET_LENGTH                      = 16;
static const int DATA_LENGTH                        = 13;
static const int COMPANG_LOGO                       = 0xA6;
static const int DEVICE_TYPE                        = 0x27;


@interface DataPackage : NSObject

/**
 * @param data的长度默认为@see DATA_LENGTH
 */
+ (id)packageWithCMD:(CMDType)cmd data:(Byte *)data;
+ (id)packageWithCMD:(CMDType)cmd data:(Byte *)data dataLength:(NSUInteger)length;

/**
 * @param data的长度默认为@see DATA_LENGTH
 */
- (void)setCMD:(CMDType)cmd data:(Byte *)data;
- (void)setCMD:(CMDType)cmd data:(Byte *)data dataLength:(NSUInteger)length;

- (void)reset;

- (Byte *)packet;

@end
