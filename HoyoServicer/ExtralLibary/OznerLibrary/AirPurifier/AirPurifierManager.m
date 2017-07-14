//
//  AirPurifierManager.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "AirPurifierManager.h"
#import "../OznerManager.h"
#import "MXChip/AirPurifier_MxChip.h"
#import "Bluetooth/AirPurifier_Bluetooth.h"

@implementation AirPurifierManager
+(BOOL)isMXChipAirPurifier:(NSString*)type
{
    return ([type isEqualToString:@"FOG_HAOZE_AIR"] || [type isEqualToString:@"580c2783"]);
    
}
+(BOOL)isBluetoothAirPurifier:(NSString*)type
{
    return [type isEqualToString:@"FLT001"];
}
-(BOOL)isMyDevice:(NSString *)type
{
    return [AirPurifierManager isBluetoothAirPurifier:type] || [AirPurifierManager isMXChipAirPurifier:type];
}

-(BOOL)checkBindMode:(BaseDeviceIO *)io
{
    if ([AirPurifierManager isBluetoothAirPurifier:io.type])
    {
        if ([io isKindOfClass:[BluetoothIO class]])
        {
            return [AirPurifier_Bluetooth isBindMode:(BluetoothIO*)io];
        }
    }
    return false;
}
-(OznerDevice *)createDevice:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if ([self isMyDevice:type])
    {
        if ([AirPurifierManager isBluetoothAirPurifier:type])
        {
            return [[AirPurifier_Bluetooth alloc] init:identifier Type:type Settings:json];
        }
        
        if ([AirPurifierManager isMXChipAirPurifier:type])
        {
            OznerDevice* device= [[AirPurifier_MxChip alloc]init:identifier Type:type Settings:json];
            [[OznerManager instance].ioManager.mxchip createMXChipIO:identifier Type:type];
            return device;
        }
    }
    return nil;
}
@end
