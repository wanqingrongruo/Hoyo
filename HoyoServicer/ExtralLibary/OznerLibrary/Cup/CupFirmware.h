//
//  TapFirmware.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/2.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Bluetooth/FirmwareTools.h"
@interface CupFirmware : FirmwareTools
{
    NSString* Platform;
    NSDate* Version;
    NSData* firmware;
    UInt32 frimwareCheckSum;
}
@end
