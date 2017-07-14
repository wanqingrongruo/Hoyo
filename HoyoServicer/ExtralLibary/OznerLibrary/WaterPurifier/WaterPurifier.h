//
//  WaterPurifier.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/OznerDevice.h"
#import "../Wifi/MXChip/MXChipIO.h"
#import "WaterPurifierInfo.h"
#import "WaterPurifierSensor.h"
#import "WaterPurifierStatus.h"

@interface WaterPurifier : OznerDevice
{
    
}

@property (strong,readonly,nonatomic) WaterPurifierInfo* info;
@property (strong,readonly,nonatomic) WaterPurifierStatus* status;
@property (strong,readonly,nonatomic) WaterPurifierSensor* sensor;
@property (readonly,nonatomic) bool isOffline;
@end
