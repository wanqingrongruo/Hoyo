//
//  RawRecord.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/16.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "TapRawRecord.h"
#import "OznerHeader.h"
@implementation TapRawRecord
//typedef struct _RecordTime
//{
//    UInt8 year;
//    UInt8 month;
//    UInt8 day;
//    UInt8 hour;
//    UInt8 min;
//    UInt8 sec;
//}*lpRecordTime,TRecordTime;
typedef struct _RawRecord
{
    TRecordTime time;
    short TDS;
    short index;
    short count;
}*lpTapRawRecord;

-(instancetype)init:(BytePtr)bytes
{
    if (self=[super init])
    {
        lpTapRawRecord record=(lpTapRawRecord)bytes;
        NSDateComponents* comp= [[NSDateComponents alloc]init];
        [comp setYear:2000+record->time.year];
        [comp setMonth:record->time.month];
        [comp setDay:record->time.day];
        [comp setHour:record->time.hour];
        [comp setMinute:record->time.min];
        [comp setSecond:record->time.sec];
        NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _time=[myCal dateFromComponents:comp];
        _TDS=record->TDS;
        _Count=record->count;
        _Index=record->index;
    }
    return self;
    
}
@end
