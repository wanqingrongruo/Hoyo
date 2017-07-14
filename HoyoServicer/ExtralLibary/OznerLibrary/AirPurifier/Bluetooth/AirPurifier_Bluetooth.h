//
//  AirPurifier_Bluetooth.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../Device/OznerDevice.h"
#import "../../Bluetooth/BluetoothIO.h"

#import "BluetoothAirPurifierSensor.h"
#import "BluetoothAirPurifierStatus.h"



@interface AirPurifier_Bluetooth : OznerDevice
{
    NSTimer* updateTimer;
    NSDate* lastDataTime;
    int requestCount;
}
@property (strong,readonly) BluetoothAirPurifierSensor* sensor;
@property (strong,readonly) BluetoothAirPurifierStatus* status;
+(BOOL)isBindMode:(BluetoothIO*)io;

@end
