//
//  BluetoothAirPurifierStatus.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/17.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../Device/BaseOznerObject.h"
#import "BluetoothAirPurifierFilterStatus.h"
#import "OznerHeader.h"
//typedef struct _RecordTime
//{
//    UInt8 year;
//    UInt8 month;
//    UInt8 day;
//    UInt8 hour;
//    UInt8 min;
//    UInt8 sec;
//}*lpRecordTime,TRecordTime;
typedef void (^SendHandler)(Byte opCode,NSData* data,OperateCallback cb);

@interface BluetoothAirPurifierStatus : NSObject
{
    SendHandler callback;
}

-(instancetype)init:(SendHandler)cb;
@property (readonly) BOOL power;
@property (readonly) int RPM;
@property (strong,readonly) BluetoothAirPurifierFilterStatus* filterStatus;

-(void)setPower:(BOOL)power Callback:(OperateCallback)cb;
-(void)setRPM:(int)RPM Callback:(OperateCallback)cb;
-(void)resetFilterStatus:(OperateCallback)cb;

-(void)load:(NSData*)data;
-(void)loadFilter:(NSData*)data;
-(void)reset;
@end
