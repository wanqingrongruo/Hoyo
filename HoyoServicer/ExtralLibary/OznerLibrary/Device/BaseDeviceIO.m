//
//  BaseDeviceIO.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "BaseDeviceIO.h"
#import "BaseDeviceIO.hpp"
@implementation OperateData

+(id)Operate:(NSData*)data Callback:(OperateCallback)cb
{
    OperateData* op=[[OperateData alloc] init];
    op.data=data;
    op.callback=cb;
    return op;
}
@end

@implementation BaseDeviceIO



-(instancetype)init:(NSString *)identifier Type:(NSString *)type
{
    if (self=[super init])
    {
        self->_identifier=[NSString stringWithString:identifier];
        self->_type=[NSString stringWithString:type];
    }
    return self;
}
-(enum ConnectStatus)connectStatus
{
    return Disconnect;
}
-(void)open
{
    
}
-(void)close
{
    
}

-(BOOL)send:(NSData *)data
{
    return false;
}

-(void)send:(NSData*)data Callback:(OperateCallback) cb;
{
}

-(BOOL)doInit
{
    if (self.delegate)
    {
        return [self.delegate DeviceIOWellInit:self];
    }
    return true;
}
-(void)doReady
{
    @try
    {
        [self.delegate DeviceIODidReadly:self];
    }
    @catch (NSException *exception) {
    }
    self->_isReady=true;
}
-(void)doConnected
{
    self->_status=Connected;
    self->_isReady=false;
    [self.delegate DeviceIODidConnected:self];
    NSLog(@"Connected:%@",self.identifier);

}
-(void)doConnecting
{
    self->_status=Connecting;
    [self.delegate DeviceIODidConnecting:self];
    NSLog(@"Connecting:%@",self.identifier);
    
}
-(void)doDisconnect
{
    NSLog(@"Disconnect:%@",self.identifier);
    self->_status=Disconnect;
    self->_isReady=false;
    [self.delegate DeviceIODidDisconnected:self];
}

-(void)doRecv:(NSData*)data
{
    @synchronized(self) {
        lastRecvPacket=[NSData dataWithData:data];
    }
    @try {
        [self.delegate DeviceIO:self recv:lastRecvPacket];
    }
    @catch (NSException *exception) {
    }
    
}

-(void)doSend:(NSData *)data
{
    @try {
        [self.delegate DeviceIO:self send:data];
    }
    @catch (NSException *exception) {
    }
}

-(NSData *)lastRecvPacket
{
    @synchronized(self) {
        return [NSData dataWithData:lastRecvPacket];
    }
}

@end
