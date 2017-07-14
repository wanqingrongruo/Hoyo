//
//  RO_WaterInfo.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 2016/10/25.
//  Copyright © 2016年 Ozner. All rights reserved.
//

#import "RO_WaterInfo.h"

@implementation RO_WaterInfo
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
    _TDS1=0;
    _TDS2=0;
    _TDS1_RAW=0;
    _TDS2_RAW=0;
    _TDS_Temperature=0;

}
-(void)load:(NSData*)data
{
    short* bytes=(short*)[data bytes];
    _TDS1=bytes[0];
    _TDS2=bytes[1];
    
    _TDS1_RAW=bytes[2];
    _TDS2_RAW=bytes[3];
    
    _TDS_Temperature=bytes[4];
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"TDS1:%d(%d) TDS2:%d(%d) 温度:%d",
            _TDS1,_TDS1_RAW,
            _TDS2,_TDS2_RAW,
            _TDS_Temperature];
}
@end
