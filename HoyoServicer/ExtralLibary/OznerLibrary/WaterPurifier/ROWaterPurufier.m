//
//  ROWaterPurufier.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 2016/10/24.
//  Copyright © 2016年 Ozner. All rights reserved.
//

#import "ROWaterPurufier.h"
#import "../Device/OznerDevice.hpp"
#import "DateTools.h"
#import "AirPurifierConsts.h"
#import "Helper.h"
@interface ROWaterPurufier()
{
    NSMutableDictionary* propertys;
}
@end
@implementation ROWaterPurufier


#define opCode_request_info 0x20
#define opCode_reset 0xa0
#define opCode_respone_setting 0x21
#define opCode_respone_water 0x22
#define opCode_respone_filter 0x23
#define opCode_update_setting 0x40

-(instancetype)init:(NSString *)identifier Type:(NSString *)type Settings:(NSString *)json
{
    if (self=[super init:identifier Type:type Settings:json])
    {
        _filterInfo=[[RO_FilterInfo alloc] init];
        _settingInfo=[[ROWaterSettingInfo alloc] init];
        _waterInfo=[[RO_WaterInfo alloc] init];
    }
    return self;
}

-(void)updateSettings:(OperateCallback)cb
{
    //NSString* json=[self.settings get:@"powerTimer" Default:@""];
    NSData* data=[_powerTimer toBytes];
    [propertys setObject:data forKey:[NSString stringWithFormat:@"%d",PROPERTY_POWER_TIMER]];
    [self setProperty:PROPERTY_POWER_TIMER Data:data Callback:cb];
    [super updateSettings:cb];
    
}

-(void)setProperty:(Byte)propertyId Data:(NSData*)value Callback:(OperateCallback)cb
{
    if (!io)
    {
        if (cb)
        {
            cb([NSError errorWithDomain:@"Connection Closed" code:0 userInfo:nil]);
        }
        return;
    }
    
    int len=13 + (int)value.length;
    Byte bytes[len];
    memset(bytes, 0, len);
    bytes[0] = (Byte) 0xfb;
    *((ushort*)(bytes+1))=(ushort)len;
    
    bytes[3] =  CMD_SET_PROPERTY;
    
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
    bytes[12] = propertyId;
    memcpy(bytes+13, [value bytes], value.length);
    [io send:[NSData dataWithBytes:bytes length:len] Callback:cb];
}


-(void)DeviceIODidDisconnected:(BaseDeviceIO *)io
{
    //[_filterInfo reset];
    [_settingInfo reset];
    //[_filterInfo reset];
}



Byte calcSum(Byte* data,int size)
{
    Byte sum=0;
    for (int i=0;i<size;i++)
        sum+=data[i];
    return sum;
}
-(void)requestSettingInfo
{
    if (!io) return;
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[3];
    bytes[0]=opCode_request_info;
    bytes[1]=1;
    bytes[2]=calcSum(bytes,2);
    [data appendBytes:bytes length:3];
    
    [io send:data];
}

-(void)requestWaterInfo
{
    if (!io) return;
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[3];
    bytes[0]=opCode_request_info;
    bytes[1]=2;
    bytes[2]=calcSum(bytes,2);
    [data appendBytes:bytes length:3];
    
    [io send:data];
}

-(void)requestFilterInfo
{
    if (!io) return;
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[3];
    bytes[0]=opCode_request_info;
    bytes[1]=3;
    bytes[2]=calcSum(bytes,2);
    [data appendBytes:bytes length:3];
    
    [io send:data];
}

/*!
 滤芯历史信息
 */
-(void)requestFilterHisInfo
{
    if (!io) return;
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[3];
    bytes[0]=opCode_request_info;
    bytes[1]=3;
    bytes[2]=calcSum(bytes,2);
    [data appendBytes:bytes length:3];
    
    [io send:data];
}
-(BOOL)updateSetting:(int)interval Ozone_WorkTime:(int)worktime ResteFilter:(BOOL)reset
{
    if (!io) return false;
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[11];
    bytes[0]=opCode_update_setting;
    NSDate* time=[NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:time];
    
    bytes[1]=[dateComps year]-2000;
    bytes[2]=[dateComps month];
    bytes[3]=[dateComps day];
    bytes[4]=[dateComps hour];
    bytes[5]=[dateComps minute];
    bytes[6]=[dateComps second];
    
    bytes[7]=interval;
    bytes[8]=worktime;
    bytes[9]=reset?1:0;
    bytes[10]=calcSum(bytes,9);
    [data appendBytes:bytes length:11];
    
    return [io send:data];
    
}
-(BOOL) reset
{
    if (!io) return false;
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[3];
    bytes[0]=opCode_reset;
    bytes[1]=calcSum(bytes,1);
    [data appendBytes:bytes length:2];
    
    return [io send:data];
}


-(BOOL)DeviceIOWellInit:(BaseDeviceIO *)io
{
    return true;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"%@\n%@\n%@",[_settingInfo description],
            [_waterInfo description],[_filterInfo description]];
    //return [NSString stringWithFormat:@"status:%@",[_status description]];
}

-(void)DeviceIO:(BaseDeviceIO *)io recv:(NSData *)data
{
    if (data==nil) return;
    if (data.length<1) return;
    BytePtr bytes=(BytePtr)[data bytes];
    NSData* needData=[NSData dataWithBytes:bytes+1 length:data.length-1];
    Byte opCode=bytes[0];
    lastDataTime=[NSDate dateWithTimeIntervalSinceNow:0];
    switch (opCode) {
        case opCode_respone_setting:
            [_settingInfo load:needData];
            [self doSensorUpdate];
            //settingInfo.fromBytes(data);
            break;
        case opCode_respone_water:
            [_waterInfo load:needData];
            [self doSensorUpdate];
            //waterInfo.fromBytes(data);
            break;
        case opCode_respone_filter:
            [_filterInfo load:needData];
            [self doSensorUpdate];
            
            //filterInfo.fromBytes(data);
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
    if ((requestCount%2)==0)
    {
        [self requestFilterInfo];
        [self requestSettingInfo];
    }else
        [self requestWaterInfo];
    requestCount++;
}
//冲水
-(BOOL)addWaterMonths:(int)months{
    if (!io) return false;
    NSDate* curWaterDate = _settingInfo.WaterStopDate;
    if ([curWaterDate timeIntervalSince1970]==0) {//没有获取到水值信息
        [self requestSettingInfo];
        return false;
    }
    
    NSMutableData* data=[[NSMutableData alloc] init];
    Byte bytes[19];
    bytes[0]=opCode_update_setting;
    NSDate* time=[NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:time];
    
    bytes[1]=[dateComps year]-2000;
    bytes[2]=[dateComps month];
    bytes[3]=[dateComps day];
    bytes[4]=[dateComps hour];
    bytes[5]=[dateComps minute];
    bytes[6]=[dateComps second];
    
    bytes[7]=_settingInfo.Ozone_Interval;
    bytes[8]=_settingInfo.Ozone_WorkTime;
    bytes[9]=0;
    NSDate* stopDate=[[NSDate alloc] init];
    if ([_settingInfo.WaterStopDate timeIntervalSinceDate:stopDate]>0) {
        stopDate=_settingInfo.WaterStopDate;
    }
    stopDate=[stopDate dateByAddingMonths:months];
    bytes[10]=[stopDate year]-2000;
    bytes[11]=[stopDate month];
    bytes[12]=[stopDate day];
    bytes[13]=[stopDate hour];
    bytes[14]=[stopDate minute];
    bytes[15]=[stopDate second];
    bytes[16]=0x88;
    bytes[17]=0x16;
    bytes[18]=calcSum(bytes,18);
    [data appendBytes:bytes length:19];
    [io send:data];
    sleep(1);
    [self requestSettingInfo];
    sleep(2);
    if ([stopDate month]==[_settingInfo.WaterStopDate month]&&[stopDate year]==[_settingInfo.WaterStopDate year]) {
        return true;
    }
    else{
        return false;
    }
    
}
//重置滤芯时间
-(BOOL) resetFilter
{
    if (_settingInfo.Ozone_Interval<=0) return false;
    if (_settingInfo.Ozone_WorkTime<=0) return false;
    
    return [self updateSetting:_settingInfo.Ozone_Interval Ozone_WorkTime:_settingInfo.Ozone_WorkTime ResteFilter:true];
    
}
//返回是否允许滤芯重置
-(BOOL) isEnableFilterReset
{
    return true;
}

+(BOOL)isBindMode:(BluetoothIO*)io
{
    if (io)
    {
        if (io.scanResponseData)
        {
            Byte flag=((Byte*)[io.scanResponseData bytes])[0];
            return flag;
        }
        return false;
    }
    else
        return false;
}
@end
