//
//  FirmwareTools.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/2.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothIO.h"
@class FirmwareTools;
@protocol FirmwareDelegate <NSObject>
-(void)firmwareUpdateDidStart;
-(void)firmwareUpdatePostion:(int)postion Size:(int)size;
-(void)firmwareUpdateDidFailure;
-(void)firmwareUpdateDidComplete;
@end

@interface FirmwareTools : NSObject
{
    BluetoothIO* bluetooth;
    NSString* firmwareFile;
}

@property (nonatomic, weak) id<FirmwareDelegate> delegate;
@property (nonatomic,copy) NSString* mac;
-(void) updateFirmware:(NSString*) path;
-(void)bind:(BluetoothIO*)io;


/**-------------------protected-----------------------------**/

-(void)run;

@end
