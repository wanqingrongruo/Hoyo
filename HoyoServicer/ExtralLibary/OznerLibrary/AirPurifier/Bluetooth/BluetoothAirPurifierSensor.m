//
//  AirPurifierSensor.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "BluetoothAirPurifierSensor.h"

@implementation BluetoothAirPurifierSensor

-(instancetype)init
{
    if (self=[super init])
    {
        [self reset];
    }
    return self;
}

-(void)reset
{
    _Humidity=AIR_PURIFIER_ERROR;
    _Temperature=AIR_PURIFIER_ERROR;
    _PM25=AIR_PURIFIER_ERROR;
    
}

-(void)load:(NSData *)data
{
    BytePtr bytes=(BytePtr)[data bytes];
    _Temperature = bytes[0];
    _Humidity = bytes[1];
    _PM25=*((ushort*)(bytes+2));
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Temperature:%d PM25:%d Humidity:%d",_Temperature,_PM25,_Humidity];
}
@end
