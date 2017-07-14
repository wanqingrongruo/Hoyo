//
//  OznerDeviceManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceManager.h"

@interface BaseDeviceManager ()
 -(OznerDevice*)createDevice:(NSString*)identifier Type:(NSString*)type Settings:(NSString*)json;
@end
