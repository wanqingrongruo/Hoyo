//
//  TapRecord.h
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TapRecord : NSObject
@property (nonatomic) int Id;
//!@brief 时间，小时或天的取整时间
@property (copy,nonatomic) NSDate * Time;
//!@brief TDS
@property (nonatomic) int TDS;
-(id) initWithJSON:(NSDate*)time JSON:(NSString*)JSON;
-(NSString*)json;
@end