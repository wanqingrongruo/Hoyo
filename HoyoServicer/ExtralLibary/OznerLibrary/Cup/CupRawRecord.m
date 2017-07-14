//
//  RawRecord.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/16.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "CupRawRecord.h"
@implementation CupRawRecord


typedef struct _CupRawRecord
{
    TRecordTime time;
    short reserve;
    short vol;
    short index;
    short count;
    short temperature;
    short TDS;
}*lpCupRecord;

-(instancetype)init:(BytePtr)bytes
{
    if (self=[super init])
    {
        lpCupRecord record=(lpCupRecord)bytes;
        NSDateComponents* comp= [[NSDateComponents alloc]init];
        [comp setYear:2000+record->time.year];
        [comp setMonth:record->time.month];
        [comp setDay:record->time.day];
        [comp setHour:record->time.hour];
        [comp setMinute:record->time.min];
        [comp setSecond:record->time.sec];
        NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _time=[myCal dateFromComponents:comp];
        _Temperature=record->temperature;
        _TDS=record->TDS;
        _Vol=record->vol;
        _Count=record->count;
        _Index=record->index;
    }
    return self;
}
@end