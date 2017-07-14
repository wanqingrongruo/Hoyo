//
//  WaterPurifierSensor.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaterPurifierSensor : NSObject
#define WATER_PURIFIER_SENSOR_ERROR 0xffff
@property (nonatomic,readonly) int TDS1;
@property (nonatomic,readonly) int TDS2;
-(void)load:(BytePtr)bytes;
@end
