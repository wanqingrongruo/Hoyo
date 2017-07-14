//
//  BluetoothAirPurifierStatus.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/17.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "BluetoothAirPurifierStatus.h"

@implementation BluetoothAirPurifierStatus
#define opCode_UpdateStatus 0x10
#define opCode_ResetFilter  0x41


-(instancetype)init:(SendHandler)cb
{
    if (self=[super init])
    {
        callback=cb;
        _filterStatus=[[BluetoothAirPurifierFilterStatus alloc] init];
        [self reset];
    }
    return self;
}
-(void)reset
{
    _power=false;
    _RPM=0;
    
}
-(void)sendStatus:(OperateCallback)cb
{
    Byte bytes[2];
    bytes[0]=_power?1:0;
    bytes[1]=(Byte)_RPM;
    callback(opCode_UpdateStatus,[NSData dataWithBytes:bytes length:sizeof(bytes)],cb);
}
-(void)setPower:(BOOL)power Callback:(OperateCallback)cb
{
    _power=power;
    [self sendStatus:cb];
}

-(void)setRPM:(int)RPM Callback:(OperateCallback)cb
{
    if (RPM>100) RPM=100;
    if (RPM<0) RPM=0;
    _RPM=RPM;
    [self sendStatus:cb];
}
-(void)load:(NSData *)data
{
    BytePtr bytes=(BytePtr)[data bytes];
    _power=bytes[0]==1;
    if (data.length>18)
    {
        _RPM=bytes[17];
    }
    lpRecordTime time=(lpRecordTime)(bytes+7);
    
    NSDateComponents* comp= [[NSDateComponents alloc]init];
    [comp setYear:2000+time->year];
    [comp setMonth:time->month];
    [comp setDay:time->day];
    [comp setHour:time->hour];
    [comp setMinute:time->min];
    [comp setSecond:time->sec];
    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _filterStatus.lastTime=[myCal dateFromComponents:comp];
    _filterStatus.workTime=*((uint*)(bytes+13));
    
}

-(void)loadFilter:(NSData *)data
{
    BytePtr bytes=(BytePtr)[data bytes];
    lpRecordTime time=(lpRecordTime)(bytes+6);
    NSDateComponents* comp= [[NSDateComponents alloc]init];
    [comp setYear:2000+time->year];
    [comp setMonth:time->month];
    [comp setDay:time->day];
    [comp setHour:time->hour];
    [comp setMinute:time->min];
    [comp setSecond:time->sec];
    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _filterStatus.stopTime=[myCal dateFromComponents:comp];
    
    _filterStatus.maxWorkTime=*((uint*)(bytes+12));
}

-(void)resetFilterStatus:(OperateCallback)cb
{
    Byte bytes[16];
    
    NSDate* time=[NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:time];
    
    lpRecordTime lastTime=(lpRecordTime)bytes;
    
    lastTime->year=[dateComps year]-2000;
    lastTime->month=[dateComps month];
    lastTime->day=[dateComps day];
    lastTime->hour=[dateComps hour];
    lastTime->min=[dateComps minute];
    lastTime->sec=[dateComps second];
    
    NSDate* nextTime=[cal dateByAddingUnit:NSCalendarUnitMonth value:3 toDate:time options:NSCalendarWrapComponents];
    
    NSDateComponents *stopComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:nextTime];
    
    lpRecordTime stopTime=(lpRecordTime)(bytes+6);
    stopTime->year=[stopComps year]-2000;
    stopTime->month=[stopComps month];
    stopTime->day=[stopComps day];
    stopTime->hour=[stopComps hour];
    stopTime->min=[stopComps minute];
    stopTime->sec=[stopComps second];
    
    *((int*)(bytes+12))=60*1000;
    callback(opCode_ResetFilter,[NSData dataWithBytes:bytes length:sizeof(bytes)],cb);
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"power:%d RPM:%d\n滤芯:%@",_power,_RPM,[_filterStatus description]];
}
@end
