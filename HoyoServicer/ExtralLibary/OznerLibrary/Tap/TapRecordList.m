//
//  TapDatas.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "TapRecordList.h"


@implementation TapRecordList

-(id)init:(NSString*) Address
{
    if (self=[super init])
    {
        self->mIdentifiter=[[NSString alloc]initWithString:Address];
        self->mDB=[[SqlLiteDB alloc] init:@"TapDB" Version:2];
        [self->mDB ExecSQLNonQuery:@"CREATE TABLE IF NOT EXISTS TapDataTable (Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Identifiter VARCHAR NOT NULL, Time INTEGER NOT NULL, JSON TEXT NOT NULL, UpdateFlag BOOLEAN NOT NULL)" params:NULL];
    
    }
    return self;
}


-(TapRecord*) last
{
    NSArray* data=[mDB ExecSQL:@"select Id,Time,JSON from TapDataTable where Identifiter=? order by time desc limit 1;" params:[NSArray arrayWithObject:mIdentifiter]];
    if ([data count]>0)
    {
        NSDate* time=[[NSDate alloc] initWithTimeIntervalSince1970: [[[data objectAtIndex:0] objectAtIndex:1] intValue]];
        TapRecord* item= [[TapRecord alloc] initWithJSON:time JSON:[[data objectAtIndex:0] objectAtIndex:2]];
        item.Id=[[[data objectAtIndex:0] objectAtIndex:0] intValue];
        return item;
    }else
        return NULL;
}

-(void) AddRecord:(NSArray*)Records
{
    TapRecord* last=[self last];  //取小时表最后一条数据
    if (!last)            //如果没有数据初始化一个
        last=[[TapRecord alloc] init];
    
    int min=(int)[last.Time timeIntervalSince1970]/60;//取整分钟
    BOOL lastChange=NO;
    //循环
    for (TapRawRecord* item in Records) {
        int inv= [item.time timeIntervalSince1970];
        if ((int)inv/60==min)
        {
            last.TDS=item.TDS;
            lastChange=YES;
        }else
        {
            if (lastChange) //如果小时不一样，看上次没有有改过数据，如果有数据更新到数据库中
            {
                NSString* sql= @"Update TapDataTable set JSON=? where Id=?;";
                [mDB ExecSQL:sql params:[NSArray arrayWithObjects:
                                         [last json],
                                         [[NSString alloc] initWithFormat:@"%d",last.Id],nil]];
            }
            
            last=[[TapRecord alloc] init];
            min=inv/60;
            last.Time=[NSDate dateWithTimeIntervalSince1970:min*60];
            last.TDS=item.TDS;
            ///吧新建的数据在数据库中加一条
            NSString* sql=@"Insert into TapDataTable (Identifiter,Time,JSON,UpdateFlag) Values (?,?,?,0);";
            if ([mDB ExecSQL:sql params:[NSArray arrayWithObjects:mIdentifiter
                                         ,[[NSString alloc] initWithFormat:@"%d",(int)[last.Time timeIntervalSince1970]]
                                         ,[last json], nil]])
            {
                ///拿到加的那条数据ID
                last.Id=[[mDB ExecSQLOneRet:@"select LAST_INSERT_ROWID();" params:nil] intValue];
            }
            lastChange=NO;
        }
        

    }
    ///如果前面循环有数据变更，更新下数据库
    if (lastChange)
    {
        NSString* sql= @"Update TapDataTable set JSON=? where Id=?;";
        [mDB ExecSQL:sql params:[NSArray arrayWithObjects:
                                 [last json],
                                 [[NSString alloc] initWithFormat:@"%d",last.Id],nil]];
    }
    
}


-(TapRecord *)GetRecordByDate:(NSDate *)Time
{
    int start=(int)[Time timeIntervalSince1970]/86400*86400;
    NSString* sql=[[NSString alloc] initWithFormat:@"select Id,Time,JSON from TapDataTable where Identifiter=? and Time=%d;",start];
    NSArray* ret=[mDB ExecSQL:sql params:[NSArray arrayWithObject:mIdentifiter]];
    for (NSArray* row in ret)
    {
        NSDate* time=[[NSDate alloc] initWithTimeIntervalSince1970: [[row objectAtIndex:1] intValue]];
        TapRecord* item=[[TapRecord alloc] initWithJSON:time JSON:[row objectAtIndex:2]];
        item.Id=[[row objectAtIndex:0] intValue];
        return item;
    }
    return nil;
}
-(NSArray*)GetRecordsByDate:(NSDate *)Time
{
    NSMutableArray* rets=[[NSMutableArray alloc] init];
    int start=(int)[Time timeIntervalSince1970]/86400*86400;
    NSString* sql=[[NSString alloc] initWithFormat:@"select Id,Time,JSON from TapDataTable where Identifiter=? and Time>=%d;",start];
    NSArray* ret=[mDB ExecSQL:sql params:[NSArray arrayWithObject:mIdentifiter]];
    for (NSArray* row in ret)
    {
        NSDate* time=[[NSDate alloc] initWithTimeIntervalSince1970: [[row objectAtIndex:1] intValue]];
        TapRecord* item=[[TapRecord alloc] initWithJSON:time JSON:[row objectAtIndex:2]];
        item.Id=[[row objectAtIndex:0] intValue];
        [rets addObject:item];
    }
    return rets;
}

-(NSArray*) GetNoSyncItenDay:(NSDate*) Time
{
    NSMutableArray* rets=[[NSMutableArray alloc] init];
    NSString* sql=[NSString stringWithFormat:@"select Id,Time,JSON from TapDataTable where Identifiter=? and Time>=%d and UpdateFlag=0",
                   (int)[Time timeIntervalSince1970]];
    
    NSArray* ret=[mDB ExecSQL:sql params:[NSArray arrayWithObjects:mIdentifiter, nil]];
    
    for (NSArray* row in ret)
    {
        NSDate* time=[[NSDate alloc] initWithTimeIntervalSince1970: [[row objectAtIndex:1] intValue]];
        TapRecord* item=[[TapRecord alloc] initWithJSON:time JSON:[row objectAtIndex:2]];
        item.Id=[[row objectAtIndex:0] intValue];
        [rets addObject:item];
    }
    
    return rets;
}


-(void) SetSyncTime:(NSDate*) Time
{
    NSString* sql=[NSString stringWithFormat:@"update TapDataTable set UpdateFlag=1 where Identifiter=? and Time<=%d",(int)[Time timeIntervalSince1970]];
    [mDB ExecSQLNonQuery:sql params:[NSArray arrayWithObjects:mIdentifiter, nil]];
}
@end
