//
//  RO_FilterInfo.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 2016/10/25.
//  Copyright © 2016年 Ozner. All rights reserved.
//

#import "RO_FilterInfo.h"

@implementation RO_FilterInfo

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
    _Filter_A_Time=0;
    _Filter_B_Time=0;
    _Filter_C_Time=0;
    _Filter_A_Percentage=0;
    _Filter_B_Percentage=0;
    _Filter_C_Percentage=0;
}
-(void)load:(NSData*)data
{
    Byte* bytes=(Byte*)[data bytes];
    _Filter_A_Time=*((UInt32*)bytes);
    _Filter_B_Time=*((UInt32*)(bytes+4));
    _Filter_C_Time=*((UInt32*)(bytes+4));
    _Filter_A_Percentage=bytes[12];
    _Filter_B_Percentage=bytes[13];
    _Filter_C_Percentage=bytes[14];
    
    _Filter_A_Percentage=(int)round(_Filter_A_Percentage/10.0)*10;
    _Filter_B_Percentage=(int)round(_Filter_B_Percentage/10.0)*10;
    _Filter_C_Percentage=(int)round(_Filter_C_Percentage/10.0)*10;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"滤芯 A:%d %d%%\n滤芯 B:%d %d%%\n滤芯 C:%d %d%%",
            _Filter_A_Time,_Filter_A_Percentage,
            _Filter_B_Time,_Filter_B_Percentage,
            _Filter_C_Time,_Filter_C_Percentage];
}
@end
