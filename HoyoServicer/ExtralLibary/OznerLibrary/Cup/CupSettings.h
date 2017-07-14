//
//  TapSettings.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/DeviceSetting.h"
#define Halo_Remind  0x1
#define Halo_Temperature  0x2
#define Halo_TDS  0x3

#define Halo_Fast  0xA0
#define Halo_Slow  0x90
// 呼吸
#define Halo_Breathe  0x80
//不闪烁
#define Halo_None  0x00

#define Beep_Nono  0x00
#define Beep_Once  0x80
#define Beep_Dobule  0x90

@interface CupSettings : DeviceSetting
{
    
}
/*!
 @property remindEnable
 @discussion 是否运行定时提醒
 */
@property (getter=getRemindEnable,setter=setRemindEnable:) bool remindEnable;
/*!
 @property remindStart
 @discussion 提醒起始时间，当日0时起的秒单位，比如9点30时间为9x3600+30X60;
 */
@property (getter=getRemindStart,setter=setRemindStart:) uint remindStart;
/*!
 @property remindEnd
 @discussion 提醒结束时间，当日0时起的秒单位，比如9点30时间为9x3600+30X60;
 */
@property (getter=getRemindEnd,setter=setRemindEnd:) uint remindEnd;
/*!
 @property remindInterval
 @discussion 提醒间隔，分钟单位
 */
@property (getter=getRemindInterval,setter=setRemindInterval:) uint remindInterval;
/*! 
 @property haloColor 
 @discussion 光环颜色 RGB
*/
@property (getter=getHaloColor,setter=setHaloColor:) uint haloColor;
/*!
 @property haloMode
 @discussion 光环模式 Halo_Remind，Halo_Temperature，Halo_TDS
 */
@property (getter=getHaloMode,setter=setHaloMode:) uint haloMode;

/*!
 @property haloSpeed
 @discussion 光环闪烁速度，Halo_Fast,Halo_Slow,Halo_Breathe,Halo_None
 */
@property (getter=getHaloSpeed,setter=setHaloSpeed:) uint haloSpeed;

/*!
 @property haloConter
 @discussion 光环闪烁次数
 */
@property (getter=getHaloConter,setter=setHaloConter:) uint haloConter;

/*!
 @property beepMode
 @discussion 光环模式响铃模式 Beep_Nono，Beep_Once，Beep_Dobule
 */
@property (getter=getBeepMode,setter=setBeepMode:) uint beepMode;

-(void)getBytes:(BytePtr)buffer;

@end
