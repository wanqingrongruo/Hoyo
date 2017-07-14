//
//  BluetoothAirPurifierFilterStatus.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/17.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "BluetoothAirPurifierFilterStatus.h"

@implementation BluetoothAirPurifierFilterStatus

-(instancetype)init
{
    if (self=[super init])
    {
        _workTime=-1;
    }
    return self;
}
-(NSString *)description
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    return [NSString stringWithFormat:@"更换时间%@\n到期时间:%@\n工作时间:%d 分钟\n最大工作时间:%d分钟",
            [formatter stringFromDate:_lastTime],[formatter stringFromDate:_stopTime],_workTime,_maxWorkTime];
}
@end
