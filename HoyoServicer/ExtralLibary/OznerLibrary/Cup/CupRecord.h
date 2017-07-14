//
//  TapRecord.h
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CupDBRecord.h"

#define temperature_high    50
#define temperature_low     25
#define tds_bad             200
#define tds_good            50

@interface CupRecord : NSObject
//!@brief 数据周期起始时间
@property (copy,nonatomic) NSDate * start;
//!@brief 数据周期结束时间
@property (copy,nonatomic) NSDate * end;

//!@brief 饮水量
@property (nonatomic) int volume;

//!@brief TDS
@property (nonatomic) int tds;

//!@brief 温度最高值
@property (nonatomic) int temperature;

//!@brief TDS好的次数
@property (nonatomic) int TDS_Good;
//!@brief TDS中的次数
@property (nonatomic) int TDS_Mid;
//!@brief TDS差的次数
@property (nonatomic) int TDS_Bad;
//!@brief 水温低的次数
@property (nonatomic) int Temperature_Low;
//!@brief 水温中的次数
@property (nonatomic) int Temperature_Mid;
//!@brief 水温高的次数
@property (nonatomic) int Temperature_High;
//!@brief 温度最高值
@property (nonatomic) int Temperature_MAX;
//!@brief TDS 最高值
@property (nonatomic) int TDS_High;
//!@brief 饮水次数
@property (nonatomic) int Count;

-(void)calcRecord:(CupDBRecord*) record;

@end