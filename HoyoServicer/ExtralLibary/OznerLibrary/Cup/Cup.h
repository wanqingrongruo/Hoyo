//
//  Tap.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/OznerDevice.h"
#import "CupSensor.h"
#import "CupRecordList.h"
#import "CupFirmware.h"
#import "CupSettings.h"

@class Cup;

@protocol CupDelegate <NSObject>
-(void)Cup:(Cup*)cup recvMAC:(NSString*)mac;
@end;

@interface Cup :OznerDevice
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
@property (strong,readonly) CupSensor* sensor;
/*!
 @property volumes
 @discussion 饮水量
 */
@property (strong,readonly) CupRecordList* volumes;
/*!
 @property firmware
 @discussion 固件升级
 */
@property (strong,readonly) CupFirmware* firmware;
/*!
 @property settings
 @discussion 水杯设置信息
 */
@property (strong) CupSettings* settings;

@property (nonatomic, weak) id<CupDelegate> cupDelegate;

+(BOOL)isBindMode:(BluetoothIO*)io;

@end
