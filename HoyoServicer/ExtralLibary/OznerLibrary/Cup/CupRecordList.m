//
//  TapDatas.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "CupRecordList.h"

#import "CupDBRecord.h"

@implementation CupRecordList

-(id)init:(NSString*) Address 
{
    if (self=[super init])
    {
        self->mIdentifiter=[[NSString alloc]initWithString:Address];
        self->mDB=[[SqlLiteDB alloc] init:@"CupDB" Version:2];
        [self->mDB ExecSQLNonQuery:@"CREATE TABLE IF NOT EXISTS CupRecordTable (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Address VARCHAR NOT NULL, Time INTEGER NOT NULL,TDS INTEGER NOT NULL,VOLUME INTEGER NOT NULL,TEMPERATURE INTEGER NOT NULL, updated BOOLEAN NOT NULL)"  params:NULL];
    }
    return self;
}
-(CupRecord*) getLastDay
{
    @synchronized(self) {
        NSArray* data=[mDB ExecSQL:@"select time from CupRecordTable where address=? order by time desc limit 1;" params:[NSArray arrayWithObject:mIdentifiter]];
        if (data.count>0)
        {
            int time=[[[data objectAtIndex:0] objectAtIndex:0] intValue]/86400*86400;
            NSArray* values=[mDB ExecSQL:@"select time,tds,volume,temperature,updated from CupRecordTable where address=? and time>=?;" params:[NSArray arrayWithObjects:mIdentifiter,[NSNumber numberWithInt:time],nil]];
            if (values.count>0)
            {
                CupRecord* ret=[[CupRecord alloc] init];
                for (NSArray* value in values)
                {
                    [ret calcRecord:[[CupDBRecord alloc] initWithArray:value]];
                }
                return ret;
            }
            
        }
        return nil;
    }
}
-(CupRecord*) getLastHour
{
    @synchronized(self) {
        NSArray* data=[mDB ExecSQL:@"select time from CupRecordTable where address=? order by time desc limit 1;" params:[NSArray arrayWithObject:mIdentifiter]];
        if (data.count>0)
        {
            int time=[[[data objectAtIndex:0] objectAtIndex:0] intValue]/3600*3600;
            NSArray* values=[mDB ExecSQL:@"select time,tds,volume,Temperature,updated from CupRecordTable where address=? and time>=?;" params:[NSArray arrayWithObjects:mIdentifiter,[NSNumber numberWithInt:time],nil]];
            if (values.count>0)
            {
                CupRecord* ret=[[CupRecord alloc] init];
                for (NSArray* value in values)
                {
                    [ret calcRecord:[[CupDBRecord alloc] initWithArray:value]];
                }
                return ret;
            }
            
        }
        return nil;
    }
}
-(void)AddRecord:(NSArray *)Records
{
    @synchronized(self) {
        if (Records.count<=0) return;
        for (CupRawRecord* record in Records)
        {
            NSString* sql=@"Insert into CupRecordTable (address,time,tds,volume,temperature,updated) Values (?,?,?,?,?,0);";
            
            if ([mDB ExecSQLNonQuery:sql params:[NSArray arrayWithObjects:mIdentifiter
                                         ,[NSNumber numberWithInt:(int)[record.time timeIntervalSince1970]]
                                         ,[NSNumber numberWithInt:record.TDS]
                                         ,[NSNumber numberWithInt:record.Vol]
                                         ,[NSNumber numberWithInt:record.Temperature]
                                         , nil]])
            {
                NSLog(@"addRecord");
            }
        }
    }
}

-(CupRecord*) getRecordByDate:(NSDate*) time
{
    @synchronized(self) {
        NSArray* valueList=[mDB ExecSQL:@"select time,tds,volume,Temperature,updated from CupRecordTable where address=? and time>=?;"
                                 params:[NSArray arrayWithObjects:mIdentifiter,[NSNumber numberWithInt:(int)[time timeIntervalSince1970]],nil]];
        if (valueList.count<=0) return nil;
        
        CupRecord* ret=[[CupRecord alloc] init];
        for (NSArray* value in valueList)
        {
            [ret calcRecord:[[CupDBRecord alloc] initWithArray:value]];
        }
        return ret;
    }
}


-(NSArray*) getRecordByDate:(NSDate*)time Interval:(enum QueryInterval)interval
{
    @synchronized(self) {
        NSArray* valueList=[mDB ExecSQL:@"select time,tds,volume,temperature,updated from CupRecordTable where address=? and time>=?;"
                                 params:[NSArray arrayWithObjects:mIdentifiter,[NSNumber numberWithInt:(int)[time timeIntervalSince1970]],nil]];
        NSMutableArray* rets=[[NSMutableArray alloc] init];
        if (valueList.count<=0) return rets;
        NSInteger lastTime=0;
        NSInteger t=0;
        CupRecord* ret=nil;
        for (NSArray* value in valueList)
        {
            CupDBRecord* record=[[CupDBRecord alloc] initWithArray:value];
            switch (interval) {
                case Raw:
                    t=(int)[record.time timeIntervalSince1970];
                    break;
                case Hour:
                    t=((int)[record.time timeIntervalSince1970])/3600*3600;
                    break;
                case Day:
                    t=((int)[record.time timeIntervalSince1970])/86400*86400;
                    break;
                case Month:
                {
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth ;
                    NSDateComponents *components = [calendar components:unitFlags fromDate:record.time];
                    t=components.year*100+components.month;
                    break;
                }
                case Week:
                {
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    unsigned unitFlags = NSCalendarUnitWeekOfYear;
                    NSDateComponents *components = [calendar components:unitFlags fromDate:record.time];
                    t=components.weekOfYear;
                    break;
                }
                default:
                    break;
            }
            if (t!=lastTime)
            {
                if (ret)
                {
                    [rets addObject:ret];
                }
                ret=[[CupRecord alloc] init];
            }
            lastTime=t;
            [ret calcRecord:record];
            
        }
        [rets addObject:ret];
        return rets;
    }
}

@end
