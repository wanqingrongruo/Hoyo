//
//  TapSensor.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "TapSensor.h"

@implementation TapSensor
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
    if (self.Battery==TAP_SENSOR_ERROR) return TAP_SENSOR_ERROR;
    if (self.Battery>3000) return 1;
    if (self.Battery>2900) return 0.9f;
    if (self.Battery>2800) return 0.7f;
    if (self.Battery>2700) return 0.5f;
    if (self.Battery>2600) return 0.3f;
    if (self.Battery>2500) return 0.17f;
    if (self.Battery>2400) return 0.16f;
    if (self.Battery>2300) return 0.15f;
    if (self.Battery>2200) return 0.07f;
    if (self.Battery>2100) return 0.03f;
    return 0;
}
-(void)reset
{
    _TDS=TAP_SENSOR_ERROR;
    _Battery=TAP_SENSOR_ERROR;
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
    _TDS=sensor->TDSFix;
}
-(NSString*) getValue:(int)value
{
    if (value==TAP_SENSOR_ERROR) return @"-";
    else
        return [NSString stringWithFormat:@"%d",value];
}
-(NSString *)description
{
    NSString* p=@"-%";
    if (self.Battery!=TAP_SENSOR_ERROR)
    {
        p=[NSString stringWithFormat:@"%d%%",(int)([self powerPer]*100)];
    }
    
    return [NSString stringWithFormat:@"Battery:%@(%@) TDS:%@",[self getValue:self.Battery]
            ,p,[self getValue:self.TDS]];
}
@end
