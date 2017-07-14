//
//  AirPurifierStatus.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "MxChipAirPurifierStatus.h"
#import "AirPurifierConsts.h"
@implementation MxChipAirPurifierStatus

-(instancetype)init:(NSDictionary*)Propertys Callback:(updateStatusHandler)cb;
{
    if (self=[super init])
    {
        self->callback=cb;
        self->propertys=Propertys;
    }
    return self;
}
-(BOOL)getBool:(int)propertyId
{
    @synchronized(propertys) {
        NSData* data=[propertys objectForKey:[NSString stringWithFormat:@"%d",propertyId]];
        if (data)
        {
            if (data.length>0)
            {
                return *((BytePtr)[data bytes])==1;
            }else
                return false;
        }else
            return false;
    }
}

-(Byte)getByte:(int)propertyId
{
    @synchronized(propertys) {
        NSData* data=[propertys objectForKey:[NSString stringWithFormat:@"%d",propertyId]];
        if (data)
        {
            if (data.length>0)
            {
                return *((BytePtr)[data bytes]);
            }else
                return 0;
        }else
            return 0;
    }
}

-(void)resetFilterStatus:(OperateCallback)cb
{
    MxChipAirPurifierFilterStatus* status=[[MxChipAirPurifierFilterStatus alloc] init];
    callback(PROPERTY_FILTER,[status toBytes],cb);
}
-(MxChipAirPurifierFilterStatus *)getFilterStatus
{
    @synchronized(propertys) {
        NSData* data=[propertys objectForKey:[NSString stringWithFormat:@"%d",PROPERTY_FILTER]];
        if (data)
        {
            if (data.length>0)
            {
                return [[MxChipAirPurifierFilterStatus alloc] init:data];
                
            }else
                return nil;
        }else
            return nil;
    }
}



-(void)setPower:(BOOL)power Callback:(OperateCallback)cb
{
    Byte data[1]={power?1:0};
    callback(PROPERTY_POWER,[NSData dataWithBytes:data length:sizeof(data)],cb);
}

-(BOOL)getPower
{
    return [self getBool:PROPERTY_POWER];
}

-(BOOL)getLock
{
    return [self getBool:PROPERTY_LOCK];
}
-(void)setLock:(BOOL)lock Callback:(OperateCallback)cb
{
    Byte data[1]={lock?1:0};
    callback(PROPERTY_LOCK,[NSData dataWithBytes:data length:sizeof(data)],cb);
}
-(Byte)getLight
{
    return [self getByte:PROPERTY_LIGHT];
}
-(void)setLight:(Byte)light Callback:(OperateCallback)cb
{
    Byte data[1]={light};
    callback(PROPERTY_LIGHT,[NSData dataWithBytes:data length:sizeof(data)],cb);
}
-(Byte)getSpeed
{
    return [self getByte:PROPERTY_SPEED];
}
-(void)setSpeed:(Byte)speed Callback:(OperateCallback)cb
{
    Byte data[1]={speed};
    callback(PROPERTY_SPEED,[NSData dataWithBytes:data length:sizeof(data)],cb);
}

-(Byte)getWifi
{
    return [self getByte:PROPERTY_WIFI];
}

-(NSString *)description
{
    NSString* speed=@"AUTO";
    switch (self.speed) {
        case FAN_SPEED_AUTO:
            speed=@"Auto";
            break;
//        case FAN_SPEED_HIGH:
//            speed=@"High";
//            break;
//        case FAN_SPEED_MID:
//            speed=@"Mid";
//            break;
//        case FAN_SPEED_LOW:
//            speed=@"Low";
//            break;
        case FAN_SPEED_SILENT:
            speed=@"Silent";
            break;
        case FAN_SPEED_POWER:
            speed=@"Power";
    }
    return [NSString stringWithFormat:@"Power:%d Speed:%@ Light:%d Lock:%d\nFilter:%@wifi:%d",
            self.power,speed,self.light,self.lock,[self.filterStatus description],self.wifi];
    
}
@end
