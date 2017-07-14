//
//  WaterReplenishmentMeter.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/21.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "WaterReplenishmentMeter.h"
#import "../Device/OznerDevice.hpp"

@implementation TestData
@end

@implementation WaterReplenishmentMeter


#define opCode_RequestStatus    0x20
#define opCode_StatusResp       0x21
#define opCode_StartTest        0x32
#define opCode_TestResp         0x33
#define opCode_Testing          0x34


-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init:identifier Type:type Settings:json])
    {
        _status=[[WaterReplenishmentMeterStatus alloc] init];
    }
    return self;
}

-(void)DeviceIODidDisconnected:(BaseDeviceIO *)Io
{
    [_status reset];
    // TODO: - 解决补水仪断开时状态不更新问题
    [super DeviceIODidDisconnected:Io];
}

+(BOOL)isBindMode:(BluetoothIO*)io
{
    if (io.scanResponseType==0x20)
    {
        if (io.scanResponseData)
        {
            if (io.scanResponseData.length>1)
            {
                BytePtr bytes=(BytePtr)[io.scanResponseData bytes];
                return bytes[0]!=0;
            }
        }
    }
    return false;
}


-(void)send:(UInt8)code Bytes:(Byte*)bytes Length:(UInt8)size Callback:(OperateCallback)cb
{
    if (!io)
    {
        if (cb)
        {
            cb([NSError errorWithDomain:@"Connection Closed" code:0 userInfo:nil]);
        }
        return;
    }
    @try {
        NSMutableData* data=[[NSMutableData alloc] init];
        [data appendBytes:&code length:1];
        if (bytes && size>0)
            [data appendBytes:bytes length:size];
        return [io send:data Callback:cb];
    }
    @catch (NSException *exception) {
        
    }
}
-(BOOL)send:(UInt8)code Bytes:(Byte*)bytes Length:(UInt8)size
{
    if (!io) return false;
    @try {
        NSMutableData* data=[[NSMutableData alloc] init];
        [data appendBytes:&code length:1];
        if (bytes && size>0)
            [data appendBytes:bytes length:size];
        return [io send:data];
    }
    @catch (NSException *exception) {
        return false;
    }
}



-(BOOL)requestStatus {
    return [self send:opCode_RequestStatus Bytes:nil Length:0];
}


-(BOOL)DeviceIOWellInit:(BaseDeviceIO *)io
{
    return true;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"status:%@",[_status description]];
}
-(void)stopTest
{
    [_status loadTest:0];
}
-(void)DeviceIO:(BaseDeviceIO *)io recv:(NSData *)data
{
    if (data==nil) return;
    if (data.length<1) return;
    BytePtr bytes=(BytePtr)[data bytes];
    Byte opCode=bytes[0];
    lastDataTime=[NSDate dateWithTimeIntervalSinceNow:0];
    switch (opCode) {
        case opCode_StatusResp:
            [_status load:[NSData dataWithBytes:bytes+1 length:data.length-1]];
            [self doStatusUpdate];
            break;
        case opCode_Testing:
            [_status startTest];
            [self performSelector:@selector(startTest) withObject:self afterDelay:6];
            [self doSensorUpdate];
            break;
        case opCode_TestResp:
        {
            short adc=*((short*)(bytes+1));
            [_status loadTest:adc];
            break;
        }
    }
}


-(void)DeviceIODidReadly:(BaseDeviceIO *)io
{
    [self start_auto_update];
}

-(void)stop_auto_update
{
    if (self->updateTimer)
    {
        [updateTimer invalidate];
        updateTimer=nil;
    }
}

-(void)start_auto_update
{
    if (updateTimer)
        [self stop_auto_update];
    if (!updateTimer)
    {
        updateTimer=[NSTimer scheduledTimerWithTimeInterval:3 target:self
                                                   selector:@selector(auto_update)
                                                   userInfo:nil repeats:YES];
        [updateTimer fire];
    }
}


-(void)auto_update
{
    [self requestStatus];
}


@end
