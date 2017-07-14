//
//  TapSettings.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/DeviceSetting.h"
@interface TapSettings : DeviceSetting

@property (getter=get_isDetectTime1,setter=set_isDetectTime1:) BOOL isDetectTime1;
@property (getter=get_DetectTime1,setter=set_DetectTime1:) NSTimeInterval DetectTime1;
@property (getter=get_isDetectTime2,setter=set_isDetectTime2:) BOOL isDetectTime2;
@property (getter=get_DetectTime2,setter=set_DetectTime2:) NSTimeInterval DetectTime2;
@property (getter=get_isDetectTime3,setter=set_isDetectTime3:) BOOL isDetectTime3;
@property (getter=get_DetectTime3,setter=set_DetectTime3:) NSTimeInterval DetectTime3;
@property (getter=get_isDetectTime4,setter=set_isDetectTime4:) BOOL isDetectTime4;
@property (getter=get_DetectTime4,setter=set_DetectTime4:) NSTimeInterval DetectTime4;


@end
