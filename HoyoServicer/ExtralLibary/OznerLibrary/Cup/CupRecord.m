//
//  TapRecord.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "CupRecord.h"

@implementation CupRecord
-(id)init
{
    if (self=[super init])
    {

    }
    return self;
}

-(void)calcRecord:(CupDBRecord*) record
{
    if (_start==nil)
        _start=[NSDate dateWithTimeIntervalSince1970:[record.time timeIntervalSince1970]];
    _end=[NSDate dateWithTimeIntervalSince1970:[record.time timeIntervalSince1970]];
    
    _volume+=record.volume;
    _tds=record.tds;
    _temperature=record.temperature;
    
    _TDS_High=MAX(_TDS_High,record.tds);
    _Temperature_MAX=MAX(_Temperature_MAX,record.temperature);
    _Count++;
    if (record.tds < tds_good)
        _TDS_Good++;
    else if (record.tds > tds_bad)
        _TDS_Bad++;
    else
        _TDS_Mid++;
    
    if (record.temperature < temperature_low)
        _Temperature_Low++;
    else if (record.temperature > temperature_high)
        _Temperature_High++;
    else
        _Temperature_Mid++;
}

-(NSString *)description
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if ([_start isEqualToDate:_end])
    {
        return [NSString stringWithFormat:@"time:%@\nvol:%d tds:%d temp:%d count:%d\n温度高:%d 温度中:%d 温度低:%d\nTDS好:%d TDS中:%d TDS差:%d TDS最高:%d 温度最高:%d",
        [dateFormatter stringFromDate:_start],
        _volume,_tds,_temperature,_Count,
        _Temperature_High, _Temperature_Mid, _Temperature_Low,
        _TDS_Good, _TDS_Mid, _TDS_Bad,_TDS_High,_Temperature_MAX];
    }else
    {
        return [NSString stringWithFormat:@"start:%@\nend:%@\nvol:%d tds:%d temp:%d count:%d\n温度高:%d 温度中:%d 温度低:%d\nTDS好:%d TDS中:%d TDS差:%d TDS最高:%d 温度最高:%d",
                             [dateFormatter stringFromDate:_start],
                             [dateFormatter stringFromDate:_end],
                             _volume,_tds,_temperature,_Count,
                             _Temperature_High, _Temperature_Mid, _Temperature_Low,
                             _TDS_Good, _TDS_Mid, _TDS_Bad,
                             _TDS_High,_Temperature_MAX
                ];
    }
    
}
//
//-(id)initWithJSON:(NSDate *)time JSON:(NSString *)JSON
//{
//    if (self=[self init])
//    {
//        _Time=[NSDate dateWithTimeIntervalSince1970:[time timeIntervalSince1970]];
//        NSData* data=[JSON dataUsingEncoding:NSUTF8StringEncoding];
//        NSError* error;
//        NSDictionary* object=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//        if (!error)
//        {
//            if ([object objectForKey:@"Volume"])
//            {
//                _Vol=[[object objectForKey:@"Volume"] intValue];
//            }
//            if ([object objectForKey:@"TDS_50_200"])
//            {
//                _TDS_50_200=[[object objectForKey:@"TDS_50_200"] intValue];
//            }
//            if ([object objectForKey:@"TDS_50"])
//            {
//                _TDS_50=[[object objectForKey:@"TDS_50"] intValue];
//            }
//            if ([object objectForKey:@"TDS_200"])
//            {
//                _TDS_200=[[object objectForKey:@"TDS_200"] intValue];
//            }
//            if ([object objectForKey:@"Temp_65"])
//            {
//                _Temp_65=[[object objectForKey:@"Temp_65"] intValue];
//            }
//            if ([object objectForKey:@"Temp_25_65"])
//            {
//                _Temp_25_65=[[object objectForKey:@"Temp_25_65"] intValue];
//            }
//            if ([object objectForKey:@"Temp_25"])
//            {
//                _Temp_25=[[object objectForKey:@"Temp_25"] intValue];
//            }
//            if ([object objectForKey:@"Temp_High"])
//            {
//                _Temp_High=[[object objectForKey:@"Temp_High"] intValue];
//            }
//            if ([object objectForKey:@"TDS_High"])
//            {
//                _TDS_High=[[object objectForKey:@"TDS_High"] intValue];
//            }
//            if ([object objectForKey:@"Count"])
//            {
//                _Count=[[object objectForKey:@"Count"] intValue];
//            }
//        }
//    }
//    return self;
//}
//-(NSString *)json
//{
//    NSMutableDictionary* dict=[[NSMutableDictionary alloc] init];
//    [dict setObject:[NSNumber numberWithInt: _volume] forKey:@"Volume"];
//    [dict setObject:[NSNumber numberWithInt: _temperature] forKey:@"TDS_50_200"];
//    [dict setObject:[NSNumber numberWithInt: _tds] forKey:@"TDS_50"];
//    [dict setObject:[NSNumber numberWithInt: _TDS_Good] forKey:@"TDS_200"];
//    [dict setObject:[NSNumber numberWithInt: _TDS_Mid] forKey:@"Temp_65"];
//    [dict setObject:[NSNumber numberWithInt: _TDS_Bad] forKey:@"Temp_25_65"];
//    [dict setObject:[NSNumber numberWithInt: _Temperature_High] forKey:@"Temp_25"];
//    [dict setObject:[NSNumber numberWithInt: _Temperature_Mid] forKey:@"Temp_High"];
//    [dict setObject:[NSNumber numberWithInt: _Temperature_Low] forKey:@"TDS_High"];
//    
//    [dict setObject:[NSNumber numberWithInt: _Count] forKey:@"Count"];
//    
//    NSError* error;
//    NSData* data=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    if (!error)
//    {
//        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }else
//        return nil;
//}
@end
