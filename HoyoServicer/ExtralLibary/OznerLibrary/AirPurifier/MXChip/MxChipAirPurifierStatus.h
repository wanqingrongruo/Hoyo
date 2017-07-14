//
//  AirPurifierStatus.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MxChipAirPurifierFilterStatus.h"
#import "../../Device/OznerDevice.h"
typedef void (^updateStatusHandler)(Byte propertyId,NSData* data,OperateCallback cb);

@interface MxChipAirPurifierStatus : NSObject
{
    NSDictionary* propertys;
    updateStatusHandler callback;
}

#define FAN_SPEED_AUTO      0
//#define FAN_SPEED_HIGH      1
//#define FAN_SPEED_MID       2
//#define FAN_SPEED_LOW       3
#define FAN_SPEED_SILENT    4
#define FAN_SPEED_POWER     5


-(instancetype)init:(NSDictionary*)propertys Callback:(updateStatusHandler)cb;

@property (getter=getPower,readonly) BOOL power;
@property (getter=getLock,readonly) BOOL lock;
@property (getter=getSpeed,readonly) Byte speed;
@property (getter=getLight,readonly) Byte light;

/*!
 @discussion wifi强度 0-100
 */
@property (getter=getWifi,readonly) Byte wifi;


/*!
 @discussion 滤芯状态
 */
@property (getter=getFilterStatus,readonly) MxChipAirPurifierFilterStatus* filterStatus;
-(void)setSpeed:(Byte)speed Callback:(OperateCallback)cb;
-(void)setLight:(Byte)light Callback:(OperateCallback)cb;
-(void)setLock:(BOOL)lock Callback:(OperateCallback)cb;
-(void)setPower:(BOOL)power Callback:(OperateCallback)cb;

-(void)resetFilterStatus:(OperateCallback)cb;
@end
