//
//  IOManagerList.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Bluetooth/BluetoothIOMgr.h"
#import "../Wifi/MXChip/MXChipIOManager.h"
@interface IOManagerList : NSObject
{
    
}
@property (strong,nonatomic) BluetoothIOMgr* bluetooth;
@property (strong,nonatomic) MXChipIOManager* mxchip;

-(void)closeAll;
-(BaseDeviceIO*) getAvailableDevice:(NSString*)identifier;
-(NSArray*) getAvailableDevices;

@end
