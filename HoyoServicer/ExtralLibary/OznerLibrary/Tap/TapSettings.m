//
//  TapSettings.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "TapSettings.h"

@implementation TapSettings

-(BOOL)get_isDetectTime1
{
    return [[self get:@"isDetectTime1" Default:[NSNumber numberWithBool:YES]] boolValue];
}
-(NSTimeInterval)get_DetectTime1
{
    return [[self get:@"DetectTime1" Default:[NSNumber numberWithInt:8*3600]] intValue];
}
-(void)set_isDetectTime1:(BOOL)isDetectTime1
{
    [self put:@"isDetectTime1" Value:[NSNumber numberWithBool:isDetectTime1]];
}
-(void)set_DetectTime1:(NSTimeInterval)DetectTime1
{
    [self put:@"DetectTime1" Value:[NSNumber numberWithInt:DetectTime1]];
}

-(BOOL)get_isDetectTime2
{
    return [[self get:@"isDetectTime2" Default:[NSNumber numberWithBool:YES]] boolValue];
}
-(NSTimeInterval)get_DetectTime2
{
    return [[self get:@"DetectTime2" Default:[NSNumber numberWithInt:8*3600]] intValue];
}
-(void)set_isDetectTime2:(BOOL)isDetectTime2
{
    [self put:@"isDetectTime2" Value:[NSNumber numberWithBool:isDetectTime2]];
}
-(void)set_DetectTime2:(NSTimeInterval)DetectTime2
{
    [self put:@"DetectTime2" Value:[NSNumber numberWithInt:DetectTime2]];
}


-(BOOL)get_isDetectTime3
{
    return [[self get:@"isDetectTime3" Default:[NSNumber numberWithBool:YES]] boolValue];
}
-(NSTimeInterval)get_DetectTime3
{
    return [[self get:@"DetectTime3" Default:[NSNumber numberWithInt:8*3600]] intValue];
}
-(void)set_isDetectTime3:(BOOL)isDetectTime3
{
    [self put:@"isDetectTime3" Value:[NSNumber numberWithBool:isDetectTime3]];
}
-(void)set_DetectTime3:(NSTimeInterval)DetectTime3
{
    [self put:@"DetectTime3" Value:[NSNumber numberWithInt:DetectTime3]];
}


-(BOOL)get_isDetectTime4
{
    return [[self get:@"isDetectTime4" Default:[NSNumber numberWithBool:YES]] boolValue];
}
-(NSTimeInterval)get_DetectTime4
{
    return [[self get:@"DetectTime4" Default:[NSNumber numberWithInt:8*4600]] intValue];
}
-(void)set_isDetectTime4:(BOOL)isDetectTime4
{
    [self put:@"isDetectTime4" Value:[NSNumber numberWithBool:isDetectTime4]];
}
-(void)set_DetectTime4:(NSTimeInterval)DetectTime4
{
    [self put:@"DetectTime4" Value:[NSNumber numberWithInt:DetectTime4]];
}

@end
