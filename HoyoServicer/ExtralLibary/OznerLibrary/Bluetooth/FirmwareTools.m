//
//  FirmwareTools.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/2.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "FirmwareTools.h"

@implementation FirmwareTools

-(void)bind:(BluetoothIO*)io;
{
    self->bluetooth=io;
}

-(void)updateFirmware:(NSString *)path
{
    self->firmwareFile=[NSString stringWithString:path];
    if (!bluetooth)
    {
        [self.delegate firmwareUpdateDidFailure];
    }
    [bluetooth runJob:@selector(run) withObject:path waitUntilDone:false];
}

-(void)run
{
    
}
@end
