//
//  OznerDeviceManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseOznerObject.h"
#import "OznerDevice.h"
#import "BaseDeviceIO.h"
@interface BaseDeviceManager : BaseOznerObject
-(OznerDevice*)loadDevice:(NSString*)identifier Type:(NSString*)type Settings:(NSString*)json;
-(BOOL)isMyDevice:(NSString*)type;
-(BOOL)checkBindMode:(BaseDeviceIO*)io;

/**---------------------------protected------------------------**/

 -(OznerDevice*)createDevice:(NSString*)identifier Type:(NSString*)type Settings:(NSString*)json;
@end
