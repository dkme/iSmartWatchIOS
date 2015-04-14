//
//  DataPackage.m
//  WMSPlusdot
//
//  Created by Sir on 15-4-14.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "DataPackage.h"

@implementation DataPackage
{
    Byte packet[PACKET_LENGTH];
}

+ (id)packageWithCMD:(CMDType)cmd data:(Byte *)data
{
    return [self packageWithCMD:cmd data:data dataLength:DATA_LENGTH];
}
+ (id)packageWithCMD:(CMDType)cmd data:(Byte *)data dataLength:(NSUInteger)length;
{
    DataPackage *package = [[DataPackage alloc] init];
    [package setCMD:cmd data:data dataLength:length];
    return package;
}

- (Byte *)packet
{
    return packet;
}
- (void)reset
{
    memset(packet, 0, PACKET_LENGTH);
    packet[0] = COMPANG_LOGO;
    packet[1] = DEVICE_TYPE;
}
- (void)setCMD:(CMDType)cmd data:(Byte *)data
{
    [self setCMD:cmd data:data dataLength:DATA_LENGTH];
}
- (void)setCMD:(CMDType)cmd data:(Byte *)data dataLength:(NSUInteger)length
{
    [self reset];
    [self setCMD:cmd];
    [self setPacketData:data length:length];
}

- (NSString *)description
{
    NSString *str = @"package: 0x";
    for (int i=0; i<PACKET_LENGTH; i++) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%02X",self.packet[i]]];
    }
    return str;
}

#pragma mark - Private
- (void)setCMD:(CMDType)cmd
{
    packet[2] = cmd;
}
- (void)setPacketData:(Byte *)data length:(NSUInteger)dataLength
{
    const int i = 3;
    int size = DATA_LENGTH;
    if (dataLength < DATA_LENGTH) {
        size = (int)dataLength;
    }
    for (int j = 0; j < size; j++) {
        packet[i+j] = data[j];
    }
}

@end
