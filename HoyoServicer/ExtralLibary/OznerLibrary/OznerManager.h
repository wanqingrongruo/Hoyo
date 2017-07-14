//
//  OznerManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/2.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helper/SqlLiteDB.h"
#import "Device/IOManagerList.h"
#import "Device/OznerDevice.h"

@protocol OznerManagerDelegate <NSObject>
@optional
/*!
 function OznerManagerDidOwnerChanged
 discussion 用户账户改变事件
 */
-(void)OznerManagerDidOwnerChanged:(NSString*)owner;
/*!
 function OznerManagerDidAddDevice
 discussion 有新的设备配对成功事件
 */
-(void)OznerManagerDidAddDevice:(OznerDevice*)device;
/*!
 function OznerManagerDidRemoveDevice
 discussion 删除一个配对设备事件
*/
-(void)OznerManagerDidRemoveDevice:(OznerDevice*)device;
/*!
 function OznerManagerDidRemoveDevice
 discussion 设置一个设备事件
 */
-(void)OznerManagerDidUpdateDevice:(OznerDevice*)device;

/*!
 function OznerManagerDidFoundDevice
 discussion 发现周围未配对的设备时通知
 */
-(void)OznerManagerDidFoundDevice:(BaseDeviceIO*)io;

@end

@interface OznerManager : NSObject<IOManagerDelegate>
{
    @private
    NSMutableDictionary* devices;
    BluetoothIOMgr* bluetoothMgr;
    NSString* owner;
    SqlLiteDB* db;
    NSArray* deviceMgrList;
}
@property (nonatomic, weak) id<OznerManagerDelegate> delegate;

/*!
 function setOwner
 discussion 设置当前运行账号
 */
-(void)setOwner:(NSString*)owner;
/*!
 @function getDevice
 @discussion 通过设备id获取设备对象
 */
-(OznerDevice*)getDevice:(NSString*)identifier;

/*!
 @function save
 @discussion 保存设备
 */
-(void)save:(OznerDevice*)device;
-(void)save:(OznerDevice*)device Callback:(OperateCallback)cb;


/*!
 @function getDevices
 @discussion 获取设备列表
 */
-(NSArray*)getDevices;

-(BOOL)hashDevice:(NSString*)identifier;
/*!
 @function remove
 @discussion 删除设备
 */

-(void)remove:(OznerDevice*)device;

/*!
 @function getDeviceByIO
 @discussion 获取通过扫描到的io获取设备
 */

-(OznerDevice*)getDeviceByIO:(BaseDeviceIO*)io;

/*!
 @function getDevices
 @discussion 获取周围未配对的设备
 */
-(NSArray*)getNotBindDevices;
/*!
 @function checkisBindMode
 @description 判断设备是否处于可配对状态
 */
-(BOOL)checkisBindMode:(BaseDeviceIO*)io;


+(instancetype)instance;

-(void)closeAll;


@property (strong,readonly) IOManagerList* ioManager;
@end
