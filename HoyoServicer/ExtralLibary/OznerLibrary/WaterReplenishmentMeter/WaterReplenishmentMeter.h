//
//  WaterReplenishmentMeter.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/21.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/OznerDevice.h"
#import "../Bluetooth/BluetoothIO.h"
#import "WaterReplenishmentMeterStatus.h"

typedef void (^TestCallback)(NSNumber* value);
@interface TestData : NSObject
{
}
@end

@interface WaterReplenishmentMeter : OznerDevice
{
    NSTimer* updateTimer;
    NSDate* lastDataTime;
}
@property (strong,readonly) WaterReplenishmentMeterStatus* status;

+(BOOL)isBindMode:(BluetoothIO*)io;
@end
