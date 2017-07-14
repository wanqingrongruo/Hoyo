//
//  WaterReplenishmentMeterMgr.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/21.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "../Device/BaseDeviceManager.h"

@interface WaterReplenishmentMeterMgr : BaseDeviceManager
+(BOOL)isWaterReplenishmentMeter:(NSString*)type;
@end
