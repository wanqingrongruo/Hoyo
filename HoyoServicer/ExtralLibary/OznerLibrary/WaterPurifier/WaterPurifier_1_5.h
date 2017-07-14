//
//  WaterPurifier_1_5.h
//  OzneriFamily
//
//  Created by 赵兵 on 2017/5/27.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/OznerDevice.h"
#import "../Wifi/MXChip/MXChipIO.h"
#import "WaterPurifierInfo.h"
#import "WaterPurifierSensor.h"
#import "WaterPurifierStatus.h"

@interface WaterPurifier_1_5 : OznerDevice
{}
@property (strong,readonly,nonatomic) WaterPurifierInfo* info;
@property (strong,readonly,nonatomic) WaterPurifierStatus* status;
@property (strong,readonly,nonatomic) WaterPurifierSensor* sensor;
@property (readonly,nonatomic) bool isOffline;
@end
