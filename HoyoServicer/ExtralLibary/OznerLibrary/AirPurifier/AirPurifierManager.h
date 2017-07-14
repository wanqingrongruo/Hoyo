//
//  AirPurifierManager.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/BaseDeviceManager.h"

@interface AirPurifierManager : BaseDeviceManager
+(BOOL)isMXChipAirPurifier:(NSString*)type;
+(BOOL)isBluetoothAirPurifier:(NSString*)type;
@end
