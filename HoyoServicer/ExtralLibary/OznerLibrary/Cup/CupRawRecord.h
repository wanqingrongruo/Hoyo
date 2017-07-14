//
//  RawRecord.h
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/16.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
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
@interface CupRawRecord : NSObject
{
    
}
-(instancetype)init:(BytePtr)bytes;
@property (copy,nonatomic) NSDate* time;
@property (nonatomic) int Vol;
@property (nonatomic) int Temperature;
@property (nonatomic) int TDS;
@property (nonatomic) int Count;
@property (nonatomic) int Index;
@end

