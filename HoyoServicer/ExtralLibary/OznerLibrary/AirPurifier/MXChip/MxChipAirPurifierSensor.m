//
//  AirPurifierSensor.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "MxChipAirPurifierSensor.h"
#import "AirPurifierConsts.h"
@implementation MxChipAirPurifierSensor
-(instancetype)init:(NSDictionary *)Propertys
{
    if (self=[super init])
    {
        self->propertys=Propertys;
    }
    return self;
}
-(int)getInt:(int)propertyId
{
    @synchronized(propertys) {
        NSData* data=[propertys objectForKey:[NSString stringWithFormat:@"%d",propertyId]];
        if (data)
        {
            if (data.length>0)
            {
                return *((int*)[data bytes]);
            }else
                return AIR_PURIFIER_ERROR;
        }else
            return AIR_PURIFIER_ERROR;
    }
}
-(short)getShort:(int)propertyId
{
    @synchronized(propertys) {
        NSData* data=[propertys objectForKey:[NSString stringWithFormat:@"%d",propertyId]];
        if (data)
        {
            if (data.length>0)
            {
                return *((ushort*)[data bytes]);
            }else
                return AIR_PURIFIER_ERROR;
        }else
            return AIR_PURIFIER_ERROR;
    }
}
-(int)getTotalClean
{
    return [self getInt:PROPERTY_TOTAL_CLEAN];
}
-(int)getLight
{
    return [self getShort:PROPERTY_LIGHT_SENSOR];
}
-(int)getTemperature
{
    return [self getShort:PROPERTY_TEMPERATURE];
}
-(int)getVOC
{
    return [self getShort:PROPERTY_VOC];
}
-(int)getHumidity
{
    return [self getShort:PROPERTY_HUMIDITY];
}
-(int)getPM25
{
    return [self getShort:PROPERTY_PM25];
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"PM25:%d Temperature:%d VOC:%d Humidity:%d Light:%d TotalClean:%d",
            self.PM25,self.Temperature,self.VOC,self.Humidity,self.Light,self.TotalClean];
}

@end
