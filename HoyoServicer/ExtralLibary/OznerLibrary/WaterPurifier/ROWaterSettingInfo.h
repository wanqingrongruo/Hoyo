//
//  ROWaterSettingInfo.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 2016/10/25.
//  Copyright © 2016年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROWaterSettingInfo : NSObject
@property (strong,readonly) NSDate* rtc;
/*!
 @property Ozone_WorkTime
 @discussion 臭氧工作时间;
 */
@property (readonly) int Ozone_WorkTime;
/*!
 @property Ozone_Interval
 @discussion 臭氧工作间隔;
 */
@property (readonly) int Ozone_Interval;
@property (strong,readonly) NSDate* WaterStopDate;//水值到期日
@property (readonly) int WaterRemindDays;//水值剩余天数
-(void)load:(NSData*)data;
-(void)reset;

@end
