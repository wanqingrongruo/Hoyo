//
//  AirPurifier_Bluetooth.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "AirPurifier_Bluetooth.h"
#import "../../Device/OznerDevice.hpp"
@implementation AirPurifier_Bluetooth
#define opCode_UpdateTime  0x40
#define opCode_Request  0x20
#define opCode_Power  0x10
#define opCode_StatusResp  0x21
#define opCode_SensorResp  0x22
#define opCode_A2DPResp  0x24
#define opCode_FilterResp  0x23
#define opCode_ResetFilter  0x41
#define opCode_A2DPPair 0x42
#define type_status  1
#define type_sensor  2
#define type_filter  3
#define type_a2dp  4

-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init:identifier Type:type Settings:json])
    {
        _sensor=[[BluetoothAirPurifierSensor alloc] init];
        _status=[[BluetoothAirPurifierStatus alloc] init:^(Byte opCode, NSData *data, OperateCallback cb) {
            [self send:opCode Data:data Callback:cb];
        }];
        
    }
    return self;
}

-(void)DeviceIODidDisconnected:(BaseDeviceIO *)Io
{
    [_sensor reset];
    [super DeviceIODidDisconnected:Io];
}

+(BOOL)isBindMode:(BluetoothIO*)Io
{
    return true;
//    if (Io.scanResponseType==0x20)
//    {
//        if (Io.scanResponseData)
//        {
//            if (Io.scanResponseData.length>7)
//            {
//                BytePtr bytes=(BytePtr)[Io.scanResponseData bytes];
//                return bytes[0]!=0;
//            }
//        }
//    }
//    return false;
}
-(BOOL) sendTime;
{
    NSDate* now=[NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:now];
    TRecordTime time;
    time.year=[dateComps year]-2000;
    time.month=[dateComps month];
    time.day=[dateComps day];
    time.hour=[dateComps hour];
    time.min=[dateComps minute];
    time.sec=[dateComps second];
    return [self send:opCode_UpdateTime Data:[NSData dataWithBytes:&time length:sizeof(time)]];
}

-(NSData*)makePacket:(Byte)code Bytes:(NSData*)data
{
    int len=(int)data.length+2;
    Byte bytes[len];
    memset(bytes, 0, len);
    bytes[0]=code;
    memcpy(bytes+1, [data bytes], data.length);
    Byte checksum=0;
    for (int i=0;i<len;i++)
    {
        checksum+=bytes[i];
    }
    bytes[len-1]=checksum;
    return [NSData dataWithBytes:bytes length:len];
}

-(BOOL)send:(UInt8)code Data:(NSData*)data
{
    if (!io) return false;
    @try {

        return [io send:[self makePacket:code Bytes:data]];
    }
    @catch (NSException *exception) {
        
    }
}

-(void)send:(UInt8)code Data:(NSData*)data Callback:(OperateCallback)cb
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
        return [io send:[self makePacket:code Bytes:data] Callback:cb];
    }
    @catch (NSException *exception) {
        
    }
}

-(BOOL)requestFilter {
    Byte byte[1]={type_filter};
    return [self send:opCode_Request Data:[NSData dataWithBytes:byte length:sizeof(byte)]];
}

-(BOOL)requestStatus {
    Byte byte[1]={type_status};
    return [self send:opCode_Request Data:[NSData dataWithBytes:byte length:sizeof(byte)]];
}

-(BOOL)requestSensor {
    Byte byte[1]={type_sensor};
    return [self send:opCode_Request Data:[NSData dataWithBytes:byte length:sizeof(byte)]];
}

-(BOOL)DeviceIOWellInit:(BaseDeviceIO *)io
{
    if (![self sendTime])
        return false;
    sleep(0.1f);
    
    if (![self requestFilter])
        return false;
    
    sleep(0.1f);
    if (![self requestStatus])
        return false;
    sleep(0.1f);
    if (![self requestSensor])
        return false;

    return true;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"status:%@\nsensor:%@",[_status description],[_sensor description]];
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
        case opCode_SensorResp:
            [_sensor load:[NSData dataWithBytes:bytes+1 length:data.length-1]];
            [self doSensorUpdate];
            break;
        case opCode_FilterResp:
            [_status loadFilter:[NSData dataWithBytes:bytes+1 length:data.length-1]];
            [self doStatusUpdate];
            break;
        case opCode_A2DPResp:
            break;
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
    if ((requestCount % 2) == 0) {
        [self requestSensor];
    } else {
        [self requestStatus];
    }
    requestCount++;
}



@end
