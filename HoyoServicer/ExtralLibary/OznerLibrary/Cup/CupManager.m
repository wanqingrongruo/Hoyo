//
//  TapManager.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "CupManager.h"
#import "../Device/BaseDeviceManager.hpp"
#import "Cup.h"

@implementation CupManager
+(BOOL)isCup:(NSString*)type
{
    return [type isEqualToString:@"CP001"];
}

-(BOOL)isMyDevice:(NSString *)type
{
    return [CupManager isCup:type];
}

-(OznerDevice *)createDevice:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if ([self isMyDevice:type])
    {
        return [[Cup alloc] init:identifier Type:type Settings:json];
    }else
        return nil;
}
- (BOOL)checkBindMode:(BaseDeviceIO *)io
{
    if ([self isMyDevice:io.type])
    {
        return [Cup isBindMode:(BluetoothIO*)io];
    }else
        return false;
}

@end
