//
//  OznerDeviceManager.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "BaseDeviceManager.h"
#import "../OznerManager.h"
#import "BaseDeviceManager.hpp"
@implementation BaseDeviceManager

-(OznerDevice*)loadDevice:(NSString*)identifier Type:(NSString*)type Settings:(NSString*)json
{
    if ([self isMyDevice:type])
    {
        OznerDevice* device=[[OznerManager instance] getDevice:identifier];
        if (!device)
        {
            device=[self createDevice:identifier Type:type Settings:json];
        }
        
        return device;
    }else
        return NULL;
}

-(BOOL)checkBindMode:(BaseDeviceIO*)io
{
    return false;
}

-(OznerDevice*)createDevice:(NSString*)identifier Type:(NSString*)type Settings:(NSString*)json
{
    return NULL;
}

-(BOOL)isMyDevice:(BaseDeviceIO*)io
{
    return false;
}
@end
