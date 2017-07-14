//
//  PowerTimer.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "PowerTimer.h"

@implementation PowerTimer

-(BOOL)loadByBytes:(NSData *)data
{
    if ((data==nil) || (data.length<6)) return false;
    BytePtr bytes=(BytePtr)[data bytes];
    _enable=*bytes!=0;
    _powerOnTime=*((ushort*)(bytes+1));
    _powerOffTime=*((ushort*)(bytes+3));
    _week=*(bytes+5);
    return true;
}

-(BOOL)loadByJSON:(NSString *)json
{
    
    if (json)
    {
        NSData* data=[json dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error;
        NSDictionary* dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error)
        {
            NSLog(@"error:%@",[error debugDescription]);
            return false;
        }
        _enable=[[dict objectForKey:@"enable"] boolValue];
        _powerOnTime=[[dict objectForKey:@"powerOnTime"] intValue];
        _powerOffTime=[[dict objectForKey:@"powerOffTime"] intValue];
        _week=[[dict objectForKey:@"week"] intValue];
        return true;
    }
    else
        return false;
    
}

-(NSString *)toJSON
{
    NSMutableDictionary* dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithBool:_enable] forKey:@"enable"];
    [dict setObject:[NSNumber numberWithInt:_powerOnTime] forKey:@"powerOnTime"];
    [dict setObject:[NSNumber numberWithInt:_powerOffTime] forKey:@"powerOffTime"];
    [dict setObject:[NSNumber numberWithInt:_week] forKey:@"week"];
    NSError* error;
    NSData* data=[NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(NSData*)toBytes
{
    Byte bytes[6];
    bytes[0]=_enable?1:0;
    *((ushort*)(bytes+1))=_powerOnTime;
    *((ushort*)(bytes+3))=_powerOffTime;
    *(bytes+5)=_week;
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}
@end
