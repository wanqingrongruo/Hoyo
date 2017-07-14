//
//  TapSensor.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CUP_SENSOR_ERROR 0xffff


@interface CupSensor : NSObject
{
    
}
-(void)load:(BytePtr)bytes;
-(void)reset;
/*!
 @function powerPer
 @discussion 获取当前电量百分比
 @result 返回TAP_SENSOR_ERROR没获取到数据
 */
-(float)powerPer;
@property (readonly) int Battery;
@property (readonly) int Temperature;
@property (readonly) int Weight;
@property (readonly) int TDS;

@end
