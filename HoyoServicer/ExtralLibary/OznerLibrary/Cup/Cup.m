//
//  Tap.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "Cup.h"
#import "CupRawRecord.h"
#import "CupManager.h"
#import "CupGravity.h"
#import "../Device/OznerDevice.hpp"

@implementation Cup
#define opCode_SetName  0x80
#define opCode_SetRemind  0x11
#define opCode_ReadSensor  0x12
#define opCode_ReadSensorRet  0xA2

#define opCode_ReadGravity  0x13
#define opCode_ReadGravityRet  0xA3
#define opCode_DeviceInfo  0x15
#define opCode_DeviceInfoRet  0xA5
#define opCode_ReadRecord  0x14
#define opCode_ReadRecordRet  0xA4
#define opCode_UpdateTime  0xF0
#define opCode_Foreground 0x21
#define opCode_ReadInfo 0x82
#define opCode_ReadInfoRet 0x82

-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init:identifier Type:type Settings:json])
    {
        self->_sensor=[[CupSensor alloc] init];
        self->dataHash=[[NSMutableSet alloc]init];
        self->records=[[NSMutableArray alloc] init];
        self->_volumes=[[CupRecordList alloc] init:identifier];
        self->_firmware=[[CupFirmware alloc] init];
        self->requestCount=0;
    }
    return self;
}


-(DeviceSetting*)InitSettings:(NSString*)json
{
    return [[CupSettings alloc] initWithJSON:json];
}
-(BOOL) sendReadInfo
{
    return [self send:opCode_ReadInfo Bytes:nil Length:0];
}
-(BOOL) sendTime;
{
    NSDate* time=[NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:time];
    TRecordTime cupTime;
    cupTime.year=[dateComps year]-2000;
    cupTime.month=[dateComps month];
    cupTime.day=[dateComps day];
    cupTime.hour=[dateComps hour];
    cupTime.min=[dateComps minute];
    cupTime.sec=[dateComps second];
    NSLog(@"sendTime:%d-%d-%d %d:%d:%d",cupTime.year,cupTime.month,cupTime.day,cupTime.hour,cupTime.min,cupTime.sec);
    return [self send:opCode_UpdateTime Bytes:(Byte*)&cupTime Length:sizeof(cupTime)];
}

-(void) sendSetting:(OperateCallback)cb
{
    Byte buffer[19];
    [self.settings getBytes:buffer];
    [self send:opCode_SetRemind Bytes:buffer Length:19 Callback:cb];
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
-(BOOL)checkTransmissionsComplete
{
    if (lastDataTime)
    {
         //如果2秒没收到消息，认为传输完成
        if (ABS([lastDataTime timeIntervalSinceNow])>2)
        {
            return true;
        }else
            return false;
    }else
        return true;
}

-(void)DeviceIO:(BaseDeviceIO *)Io recv:(NSData *)data
{
    BytePtr bytes=(BytePtr)data.bytes;
    Byte opCode=*bytes;
    switch (opCode) {
        case opCode_ReadInfoRet:
        {
            NSString* platform=[[NSString alloc] initWithBytes:(BytePtr)(bytes+1) length:3 encoding:NSASCIIStringEncoding];
            
            NSString* month=[[NSString alloc] initWithBytes:(BytePtr)(bytes+4) length:3 encoding:NSASCIIStringEncoding];
            
            NSString* day=[[NSString alloc] initWithBytes:(BytePtr)(bytes+7) length:2 encoding:NSASCIIStringEncoding];
            
            NSString* year=[[NSString alloc] initWithBytes:(BytePtr)(bytes+9) length:4 encoding:NSASCIIStringEncoding];
            
            
            NSString* hour=[[NSString alloc] initWithBytes:(BytePtr)(bytes+13) length:2 encoding:NSASCIIStringEncoding];
            
            NSString* min=[[NSString alloc] initWithBytes:(BytePtr)(bytes+15) length:2 encoding:NSASCIIStringEncoding];
            
            NSString* sec=[[NSString alloc] initWithBytes:(BytePtr)(bytes+17) length:2 encoding:NSASCIIStringEncoding];
            
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
            NSDate* date= [formatter dateFromString:[NSString stringWithFormat:@"%@ %@ %@ %@:%@:%@",month,day,year,hour,min,sec]];
            
            [((BluetoothIO*)Io) setInfo:platform Firmware:date];
            
        }
        case opCode_ReadSensorRet:
        {
            NSLog(@"Recv Sensor");
            [self->_sensor load:bytes+1];
            NSLog(@"Sensor TDS:%d Battery:%d",_sensor.TDS,_sensor.Battery);
            [self doSensorUpdate];
            break;
        }

        case opCode_ReadRecordRet:
        {
            CupRawRecord* record=[[CupRawRecord alloc] init:bytes+1];
            if (record.Vol>0)
            {
                NSString* hash=[NSString stringWithFormat:@"%f-%d",[record.time timeIntervalSince1970],record.TDS];
                if ([self->dataHash containsObject:hash])
                {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                    NSLog(@"重复数据：%@-%d",[formatter stringFromDate:record.time],record.TDS);
                }
                @synchronized(records) {
                    [records addObject:record];
                }
            }
            lastDataTime=[NSDate dateWithTimeIntervalSinceNow:0];
            @synchronized(records) {
                if (([records count]>0) && (record.Index==record.Count))
                {
                    [self.volumes AddRecord:records];
                    [records removeAllObjects];
                    [dataHash removeAllObjects];
                    [self doSensorUpdate];
                }
            }
            break;
        }
        
        default:
            break;
    }
}
-(BOOL)wait
{
    NSError* error=[self wait:5.0f];
    if (error)
    {
        NSLog(@"error:%@",[error debugDescription]);
        return false;
    }
    return true;
}

-(void)DeviceIODidReadly:(BaseDeviceIO *)Io
{
    [self send:opCode_ReadSensor Bytes:nil Length:0];
    
    [self start_auto_update];
    [super DeviceIODidReadly:Io];
}

-(void)DeviceIODidDisconnected:(BaseDeviceIO *)Io
{
    [self stop_auto_update];
    [super DeviceIODidDisconnected:Io];
    [self.sensor reset];
    
}

-(void)doSetDeviceIO:(BaseDeviceIO *)oldio NewIO:(BaseDeviceIO *)newio
{
    if (!newio)
    {
        [self stop_auto_update];
    }
    [_firmware bind:(BluetoothIO*)newio];
    [super doSetDeviceIO:oldio NewIO:newio];
    
}
-(BOOL)DeviceIOWellInit:(BaseDeviceIO *)io
{
    if (![self sendTime])
    {
        return false;
    }
    if (![self sendReadInfo])
    {
        return false;
    }
    
    sleep(0.1f);
    [self sendSetting:nil];
    sleep(0.1f);
    

    if (self.runingMode==Foreground)
    {
        if (![self send:opCode_Foreground Bytes:nil Length:0])
        {
            return false;
        }
    }
    sleep(0.1f);
    
    return true;
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
    if (![self checkTransmissionsComplete])
    {
        return;
    }
    if ((requestCount % 2) == 0) {
        [self send:opCode_ReadRecord Bytes:nil Length:0];
    } else {
        [self send:opCode_ReadSensor Bytes:nil Length:0];
    }
    requestCount++;
}

+(BOOL)isBindMode:(BluetoothIO*)io
{
    if ([CupManager isCup:io.type])
    {
        if ((io.scanResponseType==1) && (io.scanResponseData!=NULL))
        {
            CupGravity* gravity=[[CupGravity alloc] initWithData:io.scanResponseData];
            return [gravity IsHandstand];
        }else
            return false;
    }else
        return false;
}
-(NSString *)getDefaultName
{
    return @"Ozner Cup";
}
-(void)updateSettings:(OperateCallback) cb
{
    if (io && (io.isReady))
    {
        [self sendSetting:cb];
    }
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"Sensor:%@",[self.sensor description]];
}
@end
