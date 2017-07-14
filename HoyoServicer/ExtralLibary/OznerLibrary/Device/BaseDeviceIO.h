//
//  BaseDeviceIO.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseOznerObject.h"
@class BaseDeviceIO;

enum ConnectStatus {Connecting,Disconnect,Connected};

@protocol DeviceIODelegate <NSObject>

@optional
-(void)DeviceIODidConnected:(BaseDeviceIO*)io;
-(void)DeviceIODidDisconnected:(BaseDeviceIO*)io;
-(void)DeviceIODidConnecting:(BaseDeviceIO*)io;

-(void)DeviceIODidReadly:(BaseDeviceIO*)io;
-(void)DeviceIO:(BaseDeviceIO*)io recv:(NSData*)data;
-(void)DeviceIO:(BaseDeviceIO*)io send:(NSData*)data;
@required
-(BOOL)DeviceIOWellInit:(BaseDeviceIO*)io;

@end
@interface BaseDeviceIO : BaseOznerObject
{
    NSData* lastRecvPacket;
}
-(instancetype) init:(NSString*)identifier Type:(NSString*)type;
/*!
 @property identifier=mac
 **/
@property (readonly,copy)NSString* identifier;

@property (readonly,copy)NSString* type;

@property (copy)NSString* name;

@property (readonly) BOOL isReady;

/*!
 @discussion 连接状态
 */
@property (readonly) enum ConnectStatus status;

/*!
 @function lastRecvPacket
 @discussion 获取最后一次和设备交互时收到的数据包
 @result null没有数据
 */
-(NSData*)lastRecvPacket;

@property (nonatomic, weak) id<DeviceIODelegate> delegate;
-(void)open;
-(void)close;
-(BOOL)send:(NSData*)data;
-(void)send:(NSData*)data Callback:(OperateCallback) cb;



/**---------------------------protected------------------------**/


@end
