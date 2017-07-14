//
//  TapRecord.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "TapRecord.h"

@implementation TapRecord
-(id)init
{
    if (self=[super init])
    {
        _Time=[NSDate dateWithTimeIntervalSince1970:0];
        _TDS=0;
    }
    return self;
}

-(id)initWithJSON:(NSDate *)time JSON:(NSString *)JSON
{
    if (self=[self init])
    {
        _Time=[NSDate dateWithTimeIntervalSince1970:[time timeIntervalSince1970]];
        NSData* data=[JSON dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error;
        NSDictionary* object=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (!error)
        {
            if ([object objectForKey:@"TDS"])
            {
                _TDS=[[object objectForKey:@"TDS"] intValue];
            }
        }
    }
    return self;
}
-(NSString *)json
{
    NSMutableDictionary* dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt: _TDS] forKey:@"TDS"];
    NSError* error;
    NSData* data=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (!error)
    {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else
        return nil;
}
@end
