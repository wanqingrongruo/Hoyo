//
//  Tap.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/OznerDevice.h"
#import "TapSensor.h"
#import "TapRecordList.h"
#import "TapFirmware.h"
#import "TapSettings.h"
@class Tap;

@protocol TapDelegate <NSObject>
-(void)Tap:(Tap*)tap recvMAC:(NSString*)mac;
@end;

@interface Tap :OznerDevice
{
    NSMutableSet * dataHash;
    NSMutableArray* records;
    NSDate* lastDataTime;
    int requestCount;
    NSString* macAddress;
    NSTimer* updateTimer;
}
/*!
 @property sensor
 @discussion 传感器信息
 */
@property (strong,readonly) TapSensor* sensor;
/*!
 @property recordList
 @discussion 检测纪录
 */
@property (strong,readonly) TapRecordList* recordList;
/*!
 @property firmware
 @discussion 固件升级
 */
@property (strong,readonly) TapFirmware* firmware;
/*!
 @property settings
 @discussion 设置信息
 */

@property (strong) TapSettings* settings;
@property (nonatomic, weak) id<TapDelegate> tapDelegate;

+(BOOL)isBindMode:(BluetoothIO*)io;

@end
