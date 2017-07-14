//
//  TapDatas.h
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/27.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TapRawRecord.h"
#import "TapRecord.h"
#import "../Helper/SqlLiteDB.h"
@interface TapRecordList : NSObject
{
    SqlLiteDB* mDB;
    NSString* mIdentifiter;
}
-(id)init:(NSString*)Identifiter;
-(void) AddRecord:(NSArray*)Records;
//获取未同步的数据
-(NSArray*) GetNoSyncItenDay:(NSDate*) Time;
//更新同步日期
-(void) SetSyncTime:(NSDate*) Time;
-(TapRecord*)GetRecordByDate:(NSDate*) Time;
-(NSArray*)GetRecordsByDate:(NSDate*) Time;
@end
