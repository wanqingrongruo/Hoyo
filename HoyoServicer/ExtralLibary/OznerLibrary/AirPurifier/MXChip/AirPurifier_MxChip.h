//
//  AirPurifier_MxChip.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MxChipAirPurifierStatus.h"
#import "MxChipAirPurifierSensor.h"
#import "AirPurifierInfo.h"
#import "PowerTimer.h"
#import "../../Device/OznerDevice.h"
@interface AirPurifier_MxChip : OznerDevice
{
    }
@property (strong,nonatomic)MxChipAirPurifierStatus* status;
@property (strong,nonatomic)MxChipAirPurifierSensor* sensor;
@property (strong,nonatomic)AirPurifierInfo* info;
@property (strong,nonatomic)PowerTimer* powerTimer;
@property (readonly,nonatomic) bool isOffline;
@end
