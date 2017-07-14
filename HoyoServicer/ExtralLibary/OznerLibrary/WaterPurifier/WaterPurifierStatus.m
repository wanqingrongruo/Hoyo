//
//  WaterPurifierStatus.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "WaterPurifierStatus.h"

@implementation WaterPurifierStatus
-(instancetype)init:(onWaterPurifierStatusSetHandler)cb
{
    if (self=[super init])
    {
        self->callback=cb;
    }
    return self;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"Power:%d Cool:%d Hot:%d Sterilization:%d",self.power,self.cool,self.hot,self.sterilization];
}
-(void)load:(BytePtr)bytes
{
    _hot = bytes[12] != 0;
    _cool = bytes[13] != 0;
    _power = bytes[14] != 0;
    _sterilization = bytes[15] != 0;
}
-(void)toSet:(OperateCallback)cb
{
    Byte bytes[4];
    bytes[0]=self.hot?1:0;
    bytes[1]=self.cool?1:0;
    bytes[2]=self.power?1:0;
    bytes[3]=self.sterilization?1:0;
    NSData* data=[NSData dataWithBytes:bytes length:4];
    callback(data,cb);
}


-(void)setPower:(BOOL)power Callback:(OperateCallback)cb
{
    _power=power;
    [self toSet:cb];
}
-(void)setSterilization:(BOOL)sterilization Callback:(OperateCallback)cb
{
    _sterilization=sterilization;
    [self toSet:cb];
}
-(void)setCool:(BOOL)cool Callback:(OperateCallback)cb
{
    _cool=cool;
    [self toSet:cb];
}
-(void)setHot:(BOOL)hot Callback:(OperateCallback)cb
{
    _hot=hot;
    [self toSet:cb];
}
@end
