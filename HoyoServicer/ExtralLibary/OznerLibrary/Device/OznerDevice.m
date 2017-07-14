//
//  OznerDevice.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "OznerDevice.h"
#import "../Helper/Helper.h"
@interface OznerDevice()
-(void)doSetDeviceIO:(nullable BaseDeviceIO*)oldio NewIO:(nullable BaseDeviceIO*)newio;
@end

@implementation OznerDevice
-(BOOL)DeviceIOWellInit:(BaseDeviceIO *)io
{
    return true;
}
-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init])
    {
        self->_identifier=[NSString stringWithString:identifier];
        self->_type=[NSString stringWithString:type];
        self->_settings=[self InitSettings:json];
        if (StringIsNullOrEmpty(_settings.name))
        {
            _settings.name=[self getDefaultName];
        }
    }
    return self;
}

-(DeviceSetting*)InitSettings:(NSString*)json
{
    return [[DeviceSetting alloc] initWithJSON:json];
}


-(NSString *)getDefaultName
{
    return @"ozner";
}

-(BOOL)bind:(BaseDeviceIO *)newio
{
    if (self->io==newio) return false;
    
    [self doSetDeviceIO:self->io NewIO:newio];
    if (self->io)
    {
        self->io.delegate=nil;
        self->io=nil;
    }
    self->io=newio;
    if (self->io)
    {
        self->io.delegate=self;
        [self->io open];
    }
    return true;
}

-(void)updateSettings:(OperateCallback) cb
{
    
}
-(void)saveSettings
{
    
}
-(enum ConnectStatus)connectStatus
{
    if (!io) return Disconnect;
    return io.status;
}
-(BOOL)checkTransmissionsComplete
{
    return true;
}
-(void)doSensorUpdate
{
    [self performSelectorOnMainThread:@selector(sensorUpdate) withObject:nil waitUntilDone:true];
}
-(void)doStatusUpdate
{
    [self performSelectorOnMainThread:@selector(statusUpdate) withObject:nil waitUntilDone:true];
}
-(void)statusUpdate
{
    @try {
        [self.delegate OznerDeviceStatusUpdate:self];
    }
    @catch (NSException *exception) {
        
    }
}
-(void)sensorUpdate
{
    @try {
        [self.delegate OznerDeviceSensorUpdate:self];
    }
    @catch (NSException *exception) {
        
    }
}

-(void)doSetDeviceIO:(BaseDeviceIO *)oldio NewIO:(BaseDeviceIO *)newio
{
    
}

-(void)DeviceIODidConnected:(BaseDeviceIO *)io
{
    [self doStatusUpdate];
}
-(void)DeviceIODidDisconnected:(BaseDeviceIO *)io
{
    [self doStatusUpdate];
}
-(void)DeviceIODidConnecting:(BaseDeviceIO*)io
{
    [self doStatusUpdate];
}

-(void)DeviceIO:(BaseDeviceIO *)io send:(NSData *)data
{
    
}
@end

