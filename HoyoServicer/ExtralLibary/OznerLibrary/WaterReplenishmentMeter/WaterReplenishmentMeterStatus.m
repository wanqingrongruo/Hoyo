//
//  WaterReplenishmentMeterStatus.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/21.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "WaterReplenishmentMeterStatus.h"

@implementation WaterReplenishmentMeterStatus


static double testValueTable[][8]=
{
    {8, 220, -1, -1, -1, -1, 0, 0},
    {220,300,0.093,20 ,28 ,0.042,9 ,13},
    {300,350,0.092,28 ,32 ,0.041,12 ,14},
    {350,400,0.09,32 ,36 ,0.04,14 ,16},
    {400,450,0.089,36 ,40 ,0.039,16 ,18},
    {450,500,0.088,40 ,44 ,0.038,17 ,19},
    {500,600,0.087,44 ,52 ,0.037,19 ,22},
    {600,700,0.086,52 ,60 ,0.036,22 ,25},
    {700,800,0.085,60 ,68 ,0.035,25 ,28},
    {800,1023,0.084,67 ,86 ,0.034,27 ,35}
};

-(instancetype)init
{
    if (self=[super init])
    {
        [self reset];
    }
    return self;
}
-(void)startTest
{
    _testing=true;
    _moisture=0;
    _oil=0;
}
-(void)loadTest:(int)adc
{
    for (int i=0;i<sizeof(testValueTable);i++)
    {
        if ((adc>=testValueTable[i][0]) && (adc<=testValueTable[i][1]))
        {
            _moisture=(float)(ABS(testValueTable[i][1]-testValueTable[i][0])*testValueTable[i][2]+testValueTable[i][3]);
            _oil=(float)(ABS(testValueTable[i][1]-testValueTable[i][0])*testValueTable[i][5]+testValueTable[i][6]);
            break;
        }
    }
    _testing=false;
}
-(void)load:(NSData *)data
{
    BytePtr bytes=(BytePtr)[data bytes];
    _power=bytes[0];
    _battery=bytes[1]/100.0f;
}

-(void)reset
{
    _power=false;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"Power:%d Testing:%d Battery:%f moisture:%f oil:%f",_power,_testing, _battery,_moisture,_oil];
}
@end
