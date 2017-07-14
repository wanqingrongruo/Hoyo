//
//  Tap.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "Tap.h"
#import "TapRawRecord.h"
#import "TapManager.h"
#import "../Device/OznerDevice.hpp"
#import "OznerHeader.h"
@implementation Tap
#define opCode_SetDetectTime  0x10
#define opCode_ReadSensor  0x12
#define opCode_ReadSensorRet  0xA2
#define opCode_ReadTapRecord  0x17
#define opCode_ReadTapRecordRet  0xA7
#define opCode_ReadMAC   0x18
#define opCode_ReadMACRet   0xA8
#define opCode_UpdateTime  0xF0
#define opCode_Foreground 0x21

//typedef struct _RecordTime
//{
//    UInt8 year;
//    UInt8 month;
//    UInt8 day;
//    UInt8 hour;
//    UInt8 min;
//    UInt8 sec;
//}*lpRecordTime,TRecordTime;

-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init:identifier Type:type Settings:json])
    {
        self->_sensor=[[TapSensor alloc] init];
        self->dataHash=[[NSMutableSet alloc] init];
        self->records=[[NSMutableArray alloc] init];
        self->_recordList=[[TapRecordList alloc] init:identifier];
        self->_firmware=[[TapFirmware alloc] init];
        self->requestCount=0;
    }
    return self;
}


-(DeviceSetting*)InitSettings:(NSString*)json
{
    return [[TapSettings alloc] initWithJSON:json];
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
    TapSettings* setting=(TapSettings*)self.settings;
    UInt8 data[12];
    memset(data, 0, 12);

    if (setting.isDetectTime1)
    {
        data[0]=(UInt8)((int)setting.DetectTime1 / 3600);
        data[1]=(UInt8)((int)setting.DetectTime1 % 3600 / 60);
        data[2]=(UInt8)((int)setting.DetectTime1 % 60);
    }
    
    if (setting.isDetectTime2)
    {
        data[3]=(UInt8)((int)setting.DetectTime2 / 3600);
        data[4]=(UInt8)((int)setting.DetectTime2 % 3600 / 60);
        data[5]=(UInt8)((int)setting.DetectTime2 % 60);
    }
    if (setting.isDetectTime3)
    {
        data[6]=(UInt8)((int)setting.DetectTime3 / 3600);
        data[7]=(UInt8)((int)setting.DetectTime3 % 3600 / 60);
        data[8]=(UInt8)((int)setting.DetectTime3 % 60);
    }
    if (setting.isDetectTime4)
    {
        data[9]=(UInt8)((int)setting.DetectTime4 / 3600);
        data[10]=(UInt8)((int)setting.DetectTime4 % 3600 / 60);
        data[11]=(UInt8)((int)setting.DetectTime4 % 60);
    }
    
    [self send:opCode_SetDetectTime Bytes:data Length:12 Callback:cb];
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
        [io send:data Callback:cb];
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

-(void)DeviceIO:(BaseDeviceIO *)io recv:(NSData *)data
{
    BytePtr bytes=(BytePtr)data.bytes;
    Byte opCode=*bytes;
    switch (opCode) {
        case opCode_ReadSensorRet:
        {
            NSLog(@"Recv Sensor");
            [self->_sensor load:bytes+1];
            NSLog(@"Sensor TDS:%d Battery:%d",_sensor.TDS,_sensor.Battery);
            [self doSensorUpdate];
            
            break;
        }
        case opCode_ReadMACRet:
        {
            NSLog(@"Recv MAC");
            if ([data length]>=6)
            {
                BytePtr address=(BytePtr)[data bytes];
                self->macAddress=[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               address[5],address[4],address[3],address[2],address[1],address[0]];
                self.firmware.mac=macAddress;
                [self.tapDelegate Tap:self recvMAC:macAddress];
                [self set];
            }
            break;
        }
        case opCode_ReadTapRecordRet:
        {
            TapRawRecord* record=[[TapRawRecord alloc] init:bytes+1];
            if (record.TDS>0)
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
                    [self.recordList AddRecord:records];
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
    
    if (![self send:opCode_ReadMAC Bytes:nil Length:0])
    {
        return false;
    }else
    {
        [self wait];
    }
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
        [self send:opCode_ReadTapRecord Bytes:nil Length:0];
    } else {
        [self send:opCode_ReadSensor Bytes:nil Length:0];
    }
    requestCount++;
}

+(BOOL)isBindMode:(BluetoothIO*)io
{
    if ([TapManager isTap:io.type])
    {
        if ((io.scanResponseData) && (io.scanResponseData.length>0))
        {
            return ((BytePtr)[io.scanResponseData bytes])[0]==1;
        }else
            return false;
    }else
        return false;
}
-(NSString *)getDefaultName
{
    return @"Ozner Tap";
}

-(void)updateSettings:(OperateCallback)cb
{
    if (io && (io.isReady))
    {
        [self sendSetting:nil];
    }
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"Sensor:%@",[self.sensor description]];
}
@end
