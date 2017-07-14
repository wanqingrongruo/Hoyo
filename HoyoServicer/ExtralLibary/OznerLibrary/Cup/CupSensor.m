//
//  TapSensor.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "CupSensor.h"

@implementation CupSensor
typedef struct _Sensor
{
    short Battery;
    short BatteryFix;
    short Temperature;
    short TemperatureFix;
    short Weigth;
    short WeigthFix;
    short TDS;
    short TDSFix;
}*lpSensor;

-(float)powerPer
{
    if (self.Battery==CUP_SENSOR_ERROR) return CUP_SENSOR_ERROR;
    
    if (_Battery >= 3000) {
        float ret = (_Battery - 3000.0f) / (4200.0f - 3000.0f);
        if (ret > 100)
            ret = 100;
        return ret;
    } else
        return 0;
    
//    if (self.Battery>3000) return 1;
//    if (self.Battery>2900) return 0.9f;
//    if (self.Battery>2800) return 0.7f;
//    if (self.Battery>2700) return 0.5f;
//    if (self.Battery>2600) return 0.3f;
//    if (self.Battery>2500) return 0.17f;
//    if (self.Battery>2400) return 0.16f;
//    if (self.Battery>2300) return 0.15f;
//    if (self.Battery>2200) return 0.07f;
//    if (self.Battery>2100) return 0.03f;
//    return 0;
}

-(void)reset
{
    _TDS=CUP_SENSOR_ERROR;
    _Battery=CUP_SENSOR_ERROR;
    _Weight=CUP_SENSOR_ERROR;
    _Temperature=CUP_SENSOR_ERROR;
}
-(instancetype)init
{
    if (self=[super init])
    {
        [self reset];
    }
    return self;
}
-(void)load:(BytePtr)bytes
{
    lpSensor sensor=(lpSensor)bytes;
    _Battery=sensor->BatteryFix;
    _Temperature=sensor->TemperatureFix;
    _TDS=sensor->TDSFix;
    _Weight=sensor->WeigthFix;
}
-(NSString*) getValue:(int)value
{
    if (value==CUP_SENSOR_ERROR) return @"-";
    else
        return [NSString stringWithFormat:@"%d",value];
}

-(NSString *)description
{
    NSString* p=@"-%";
    if (self.Battery!=CUP_SENSOR_ERROR)
    {
        p=[NSString stringWithFormat:@"%d%%",(int)([self powerPer]*100)];
    }
    
    return [NSString stringWithFormat:@"Battery:%@(%@) Temperature:%@ Weight:%@ TDS:%@",[self getValue:self.Battery]
            ,p,[self getValue:self.Temperature],[self getValue:self.Weight],[self getValue:self.TDS]];
}
@end
