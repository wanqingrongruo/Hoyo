//
//  TapManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Device/BaseDeviceManager.h"

@interface CupManager : BaseDeviceManager

+(BOOL)isCup:(NSString*)type;

@end
