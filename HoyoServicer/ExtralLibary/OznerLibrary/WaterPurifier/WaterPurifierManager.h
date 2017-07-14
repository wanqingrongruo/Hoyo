//
//  WaterPurifierManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/BaseDeviceManager.h"

@interface WaterPurifierManager : BaseDeviceManager
+(BOOL)isWaterPurifier:(NSString*)type;

@end
