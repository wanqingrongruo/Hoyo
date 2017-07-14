//
//  WaterReplenishmentMeterMgr.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/21.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "WaterReplenishmentMeterMgr.h"
#import "WaterReplenishmentMeter.h"
@implementation WaterReplenishmentMeterMgr
+(BOOL)isWaterReplenishmentMeter:(NSString*)type
{
    return [type isEqualToString:@"BSY001"];
}

-(BOOL)isMyDevice:(NSString *)type
{
    return [WaterReplenishmentMeterMgr isWaterReplenishmentMeter:type];
}

-(OznerDevice *)createDevice:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if ([self isMyDevice:type])
    {
        return [[WaterReplenishmentMeter alloc] init:identifier Type:type Settings:json];
    }else
        return nil;
}

- (BOOL)checkBindMode:(BaseDeviceIO *)io
{
    if ([self isMyDevice:io.type])
    {
        return [WaterReplenishmentMeter isBindMode:(BluetoothIO*)io];
    }else
        return false;
}
@end
