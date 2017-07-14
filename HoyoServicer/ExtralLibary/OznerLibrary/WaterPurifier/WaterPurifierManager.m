//
//  WaterPurifierManager.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "WaterPurifierManager.h"
#import "../Device/BaseDeviceManager.hpp"
#import "WaterPurifier.h"
#import "OznerManager.h"
#import "ROWaterPurufier.h"
@implementation WaterPurifierManager

-(OznerDevice *)createDevice:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    OznerDevice* device=NULL;
    if ([self isBluetoothDevice:type])
    {
        device=[[ROWaterPurufier alloc] init:identifier Type:type Settings:json];
        
    }else
    {
        device=[[WaterPurifier alloc] init:identifier Type:type Settings:json];
        [[OznerManager instance].ioManager.mxchip createMXChipIO:identifier Type:type];
    }
    return device;
}
-(instancetype)init
{
    if (self=[super init])
    {
        [[OznerManager instance].ioManager.bluetooth registerScanResponseParser:self];
    }
    return self;
}
-(ScanData*) parserScanData:(CBPeripheral *)peripheral data:(NSData*)data;
{
    if ([peripheral.name isEqualToString:@"Ozner RO"])
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        
        Byte* bytes=(Byte*)[data bytes];
        
        NSString* platform=[[NSString alloc] initWithData:[NSData dataWithBytes:bytes length:3] encoding:NSASCIIStringEncoding];
        
        
        NSDate* firmware=[formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d %d:%d:%d",
                                                    +                                                    bytes[3],bytes[4],bytes[5],
                                                    +                                                    bytes[6],bytes[7],bytes[8]]];
        
        NSString* mainbroadPlatform=[[NSString alloc] initWithData:[NSData dataWithBytes:(bytes+9) length:3] encoding:NSASCIIStringEncoding];
        
        NSDate* mainbroadFirmware=[formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d %d:%d:%d",
                                                             +                                                    bytes[12],bytes[13],bytes[14],
                                                             +                                                    bytes[15],bytes[16],bytes[17]]];
        
        NSData* data=[NSData dataWithBytes:bytes+18 length:7];
        return [[ScanData alloc] init:@"Ozner RO" platform:platform firmware:firmware mainboardPlatform:mainbroadPlatform mainboardFirmware:mainbroadFirmware advertisement:data scanResponesType:0x11];
        
    }
    return NULL;
}
+(BOOL)isWaterPurifier:(NSString*)type
{
    return ([type isEqualToString:@"MXCHIP_HAOZE_Water"] || [type isEqualToString:@"16a21bd6"] || [type isEqualToString:@"Ozner RO"]);
}

-(BOOL)isMyDevice:(NSString *)type
{
    return [WaterPurifierManager isWaterPurifier:type];
}
-(BOOL)isBluetoothDevice:(NSString *)type
{
    return ([type isEqualToString:@"Ozner RO"]);
}

- (BOOL)checkBindMode:(BaseDeviceIO *)io
{
    if ([self isBluetoothDevice:io.type])
    {
        return [ROWaterPurufier isBindMode:(BluetoothIO*)io];
    }else
        return false;
}
@end
