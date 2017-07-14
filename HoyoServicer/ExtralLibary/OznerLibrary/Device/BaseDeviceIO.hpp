//
//  BaseDeviceIO.hpp
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//


#import "BaseDeviceIO.h"
@interface  BaseDeviceIO ()
-(void)doSend:(NSData*)data;
-(void)doRecv:(NSData*)data;
-(void)doReady;
-(void)doConnecting;
-(void)doDisconnect;
-(void)doConnected;
-(BOOL)doInit;
@end

@interface OperateData :NSObject
+(id)Operate:(NSData*)data Callback:(OperateCallback)cb;
@property (strong,nonatomic) OperateCallback callback;
@property (strong,nonatomic) NSData* data;
@end

