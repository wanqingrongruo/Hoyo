 //
//  WaterPurifier.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "WaterPurifier.h"
#import "../Device/OznerDevice.hpp"
#import "../Helper/Helper.h"
@interface WaterPurifier()
{
    NSTimer* updateTimer;
    int _requestCount;
}
@end
@implementation WaterPurifier

#define GroupCode_DeviceToApp 0xFB
#define GroupCode_AppToDevice 0xFA
#define GroupCode_DevceToServer 0xFC

#define Opcode_RequestStatus  0x01
#define Opcode_RespondStatus  0x01
#define Opcode_ChangeStatus  0x02
#define Opcode_DeviceInfo  0x03

#define SecureCode @"16a21bd6"

-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init:identifier Type:type Settings:json])
    {
        self->_info=[[WaterPurifierInfo alloc] init];
        self->_status=[[WaterPurifierStatus alloc] init:^(NSData *data,OperateCallback cb) {
            return [self setStatus:data Callback:cb];
        }];
        self->_sensor=[[WaterPurifierSensor alloc] init];
        _isOffline=false;
    }
    return self;
}
-(void)setStatus:(NSData*)data Callback:(OperateCallback)cb
{
    if (!io)
    {
        if (cb)
        {
            cb([NSError errorWithDomain:@"Connection Closed" code:0 userInfo:nil]);
        }
        return;
    }
    [io send:[self MakeWoodyBytes:GroupCode_AppToDevice Opcode:Opcode_ChangeStatus Data:data] Callback:cb];
    [self reqeusetStatsus];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Status:%@\nSensor:%@",
            
            [self.status description],[self.sensor description]];
}

-(void)doSetDeviceIO:(BaseDeviceIO *)oldio NewIO:(BaseDeviceIO *)newio
{
    [(MXChipIO*)newio setSecureCode:SecureCode];
}

-(NSString *)getDefaultName
{
    return @"Water Purifier";
}

-(NSData*) MakeWoodyBytes:(Byte)group Opcode:(Byte)opcode Data:(NSData*)payload
{
    int len = 10 + (payload == nil ? 3 : (int)payload.length + 3);
    Byte bytes[len];
    bytes[0] = group;
    *((short*)(bytes+1))=len;
    bytes[3]=opcode;
    NSData* mac=[Helper stringToHexData:[self.identifier stringByReplacingOccurrencesOfString:@":" withString:@""]];
    BytePtr tmp=(BytePtr)[mac bytes];
    bytes[4]=tmp[0];
    bytes[5]=tmp[1];
    bytes[6]=tmp[2];
    bytes[7]=tmp[3];
    bytes[8]=tmp[4];
    bytes[9]=tmp[5];
    bytes[10]=0;
    bytes[11]=0;
    if (payload)
    {
        memcpy(bytes+12, [payload bytes],  payload.length);
    }
    bytes[len-1]=[Helper Crc8:bytes inLen:len-1];
    return [NSData dataWithBytes:bytes length:len];
}

-(void)DeviceIO:(BaseDeviceIO *)io recv:(NSData *)data
{
    _requestCount=0;
    if (_isOffline)
    {
        _isOffline=false;
        [self doStatusUpdate];
    }
    
    if (data==nil) return;
    
    BytePtr bytes=(BytePtr)[data bytes];
    if (data.length > 10) {
        Byte group = bytes[0];
        Byte opCode = bytes[3];
        switch (group) {
            case GroupCode_DeviceToApp:
                switch (opCode)
            {
                case Opcode_RespondStatus:
                    [_status load:bytes];
                    [_sensor load:bytes];
                    [self doSensorUpdate];
                    [self doStatusUpdate];
                    break;
                case Opcode_DeviceInfo:
                    [_info load:bytes];
                    [self set];
                    break;
            }
            break;
        }
        
    }
}
-(BOOL)reqeusetStatsus
{
    if (io)
    {
        _requestCount++;
        if (_requestCount>=3)
        {
            _isOffline=true;
            [self doStatusUpdate];
        }
        return [io send:[self MakeWoodyBytes:GroupCode_AppToDevice Opcode:Opcode_RequestStatus Data:nil]];
    }else
        return false;
}

-(BOOL)DeviceIOWellInit:(BaseDeviceIO *)Io
{
    if ([Io send:[self MakeWoodyBytes:GroupCode_AppToDevice Opcode:Opcode_RequestStatus Data:nil]])
    {
        [self wait:5];
    }
    return true;
}


-(void)DeviceIODidReadly:(BaseDeviceIO *)Io
{
    [self reqeusetStatsus];
    [self start_auto_update];
    @try {
         [super DeviceIODidReadly:Io];
    }
    @catch (NSException *exception) {
        
    }
   
}

-(void)DeviceIODidDisconnected:(BaseDeviceIO *)Io
{
    [self stop_auto_update];
    @try {
        [super DeviceIODidDisconnected:Io];
    }
    @catch (NSException *exception) {
        
    }
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
        updateTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self
                                                   selector:@selector(auto_update)
                                                   userInfo:nil repeats:YES];
        [updateTimer fire];
    }
}

-(void)auto_update
{
    [self reqeusetStatsus];
}

@end

