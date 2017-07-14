//
//  OznerDevice.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceIO.h"
#import "DeviceSetting.h"
@class OznerDevice;
@protocol OznerDeviceDelegate <NSObject>
@optional
-(void)OznerDeviceSensorUpdate:(OznerDevice*)device;
-(void)OznerDeviceStatusUpdate:(OznerDevice *)device;
@end
@interface OznerDevice : BaseOznerObject<DeviceIODelegate>
{
    BaseDeviceIO* io;
}

-(instancetype) init:(NSString*)identifier Type:(NSString*)type Settings:(NSString*)json;
-(BOOL)bind:(BaseDeviceIO*)newio;

-(void)updateSettings:(OperateCallback) cb;
-(void)saveSettings;
-(NSString *)getDefaultName;

@property (nonatomic, weak) id<OznerDeviceDelegate> delegate;
@property (strong) DeviceSetting* settings;
@property (readonly,copy)NSString* identifier;
@property (readonly,copy)NSString* type;
-(enum ConnectStatus) connectStatus;
@end
