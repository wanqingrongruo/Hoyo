//
//  AirPurifierInfo.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "AirPurifierInfo.h"
#import "AirPurifierConsts.h"

@implementation AirPurifierInfo

-(instancetype)init:(NSDictionary *)Propertys
{
    if (self=[super init])
    {
        self->propertys=Propertys;
    }
    return self;
}
-(NSString*) getString: (int)propertyId
{
    @synchronized(propertys) {
        NSData* data=[propertys objectForKey:[NSString stringWithFormat:@"%d",propertyId]];
        if (data)
        {
            if (data.length>0)
            {
                return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }else
                return @"";
        }else
            return @"";
    }
}

-(NSString *)getModel
{
    return [self getString:PROPERTY_MODEL];
}
-(NSString *)getType
{
    return [self getString:PROPERTY_DEVICE_TYPE];
}
-(NSString *)getMainboard
{
    return [self getString:PROPERTY_MAIN_BOARD];
}
-(NSString *)getControlboard
{
    return [self getString:PROPERTY_CONTROL_BOARD];
}
@end
