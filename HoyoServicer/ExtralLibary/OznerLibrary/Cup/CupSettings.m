//
//  TapSettings.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "CupSettings.h"

@implementation CupSettings

-(void)getBytes:(BytePtr)buffer
{
    if (self.remindEnable)
    {
        *(UInt32*)buffer=(UInt32)self.remindStart;
        *(UInt32*)(buffer+4)=(UInt32)self.remindEnd;
    }else
    {
        *(UInt32*)buffer=0;
        *(UInt32*)(buffer+4)=0;
    }
    *(buffer+8)=self.remindInterval;
    *(UInt32*)(buffer+9)=(UInt32)self.haloColor;
    *(buffer+13)=self.haloMode;
    *(buffer+14)=self.haloSpeed;
    *(buffer+15)=self.haloConter;
    *(buffer+16)=self.beepMode;
    *(buffer+17)=0;
    *(buffer+18)=0;
}
-(bool)getRemindEnable
{
    return [[self get:@"isRemind" Default:[NSNumber numberWithBool:YES]] boolValue];
}
-(void)setRemindEnable:(bool)remindEnable
{
    [self put:@"isRemind" Value:[NSNumber numberWithBool:remindEnable]];
}

-(uint)getRemindStart
{
    return [[self get:@"remindStart" Default:[NSNumber numberWithInt:9*3600]] intValue];
}

-(void)setRemindStart:(uint)remindStart
{
    [self put:@"remindStart" Value:[NSNumber numberWithInt:remindStart]];
}

-(uint)getRemindEnd
{
    return [[self get:@"remindEnd" Default:[NSNumber numberWithInt:19*3600]] intValue];
}
-(void)setRemindEnd:(uint)remindEnd
{
    [self put:@"remindEnd" Value:[NSNumber numberWithInt:remindEnd]];
}

-(uint)getRemindInterval
{
    return [[self get:@"remindInterval" Default:[NSNumber numberWithInt:15]] intValue];
}
-(void)setRemindInterval:(uint)remindInterval
{
    [self put:@"remindInterval" Value:[NSNumber numberWithInt:remindInterval]];
}

-(uint)getHaloColor
{
    return [[self get:@"remindColor" Default:[NSNumber numberWithInt:0xff00ff00]] intValue];
}

-(void)setHaloColor:(uint)haloColor
{
    [self put:@"remindColor" Value:[NSNumber numberWithInt:haloColor]];
}

-(uint)getHaloConter
{
    return [[self get:@"haloConter" Default:[NSNumber numberWithInt:15]] intValue];
}
-(void)setHaloConter:(uint)haloConter
{
    [self put:@"haloConter" Value:[NSNumber numberWithInt:haloConter]];
}
-(uint)getHaloMode
{
    return [[self get:@"haloMode" Default:[NSNumber numberWithInt:Halo_TDS]] intValue];
}
-(void)setHaloMode:(uint)haloMode
{
    [self put:@"haloMode" Value:[NSNumber numberWithInt:haloMode]];
}

-(uint)getHaloSpeed
{
    return [[self get:@"haloSpeed" Default:[NSNumber numberWithInt:Halo_Breathe]] intValue];
}
-(void)setHaloSpeed:(uint)haloSpeed
{
    [self put:@"haloSpeed" Value:[NSNumber numberWithInt:haloSpeed]];
}

-(uint)getBeepMode
{
    return [[self get:@"beepMode" Default:[NSNumber numberWithInt:Beep_Once]] intValue];
}
-(void)setBeepMode:(uint)beepMode
{
    [self put:@"beepMode" Value:[NSNumber numberWithInt:beepMode]];
}
@end
