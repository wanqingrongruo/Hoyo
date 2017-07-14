//
//  TapManager.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "TapManager.h"
#import "../Device/BaseDeviceManager.hpp"
#import "Tap.h"

@implementation TapManager
+(BOOL)isTap:(NSString*)type
{
    return [type isEqualToString:@"SC001"];
}

-(BOOL)isMyDevice:(NSString *)type
{
    return [TapManager isTap:type];
}

-(OznerDevice *)createDevice:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if ([self isMyDevice:type])
    {
        return [[Tap alloc] init:identifier Type:type Settings:json];
    }else
        return nil;
}

- (BOOL)checkBindMode:(BaseDeviceIO *)io
{
    if ([self isMyDevice:io.type])
    {
        return [Tap isBindMode:(BluetoothIO*)io];
    }else
        return false;
}

@end
