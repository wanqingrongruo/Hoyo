//
//  TapDatas.h
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CupRawRecord.h"
#import "CupRecord.h"
#import "../Helper/SqlLiteDB.h"
enum QueryInterval {Raw,Hour,Day,Week,Month};

@interface CupRecordList : NSObject
{
    SqlLiteDB* mDB;
    NSString* mIdentifiter;
}
-(id)init:(NSString*)Identifiter;
/*!
 @function getLastDay
 @discussion 获取最后一天的数据
 @result null 没有数据
 */
-(CupRecord*) getLastDay;

/*!
 @function getLastHour
 @discussion 获取最后小时的数据
 @result null 没有数据
 */
-(CupRecord*) getLastHour;


-(void)AddRecord:(NSArray *)Records;
/*!
 @function getRecordByDate
 @discussion 获取指定时间开始的统计数据
 @result null 没有数据
 */
-(CupRecord*) getRecordByDate:(NSDate*) time;

/*!
 @function getRecordByDate
 @discussion 获取指定时间开始的统计数据
 @param interval 要查询的统计周期，比如raw返回每次喝水的原始统计数据,CupRecord.start＝饮时间，day,则返回指定时间开始每天的数据，CupRecord.start＝当日第一次饮水的时间，end＝当日最后一次饮水时间
 @result null 没有数据
 */
-(NSArray*) getRecordByDate:(NSDate*)time Interval:(enum QueryInterval)interval;
@end
