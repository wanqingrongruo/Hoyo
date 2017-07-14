//
//  BluetoothIO.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "BluetoothIO.h"
#import "BluetoothSynchronizedObject.h"
#import "../Device/BaseDeviceIO.hpp"
@implementation BluetoothIO

#define Timeout 20.0f
#define UUID_Service @"FFF0"
#define UUID_CHAR_INPUT @"FFF2"
#define UUID_CHAR_OUTPUT @"FFF1"
#define UUID_DESC_CLINET_CFG @"2902"

-(instancetype)initWithPeripheral:(CBPeripheral*)Peripheral Address:(NSString*)address CentralManager:(CBCentralManager *)CentralManager BluetoothData:(ScanData *)scanData
{
    
    NSString* identifier=[NSString stringWithString:address];
    if (scanData.scanResponesType==0x20)
    {
        if ((scanData.scanResponesData) && (scanData.scanResponesData.length>7))
        {
            BytePtr bytes=(BytePtr)[scanData.scanResponesData bytes];
            identifier =[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
              bytes[6],bytes[5],bytes[4],bytes[3],bytes[2],bytes[1]];
            
        }
    }
    
    if (self=[super init:identifier Type:scanData.model])
    {
        self->centralManager=CentralManager;
        self->peripheral=Peripheral;
        self->_firmwareVersion=[NSDate dateWithTimeIntervalSince1970:[scanData.firmware timeIntervalSince1970]];
        self->_Platform=[NSString stringWithString:scanData.platform];
        peripheral.delegate=self;
       
    }
    return self;
}
-(void)setInfo:(NSString*)platform Firmware:(NSDate*)firmwareVersion
{
    self->_Platform=[NSString stringWithString:platform];
    self->_firmwareVersion=[firmwareVersion copy];
}
-(void)updateScarnResponse:(int)type Data:(NSData*)data
{
    self->_scanResponseType=type;
    self->_scanResponseData=[NSData dataWithData:data];
}

-(void)updateConnectStatus:(enum ConnectStatus)status
{
    NSLog(@"updateConnectStatus:%d",status);
    
    switch (status) {
        case Connecting:
            [self doConnecting];
            break;
        case Disconnect:
            [self doDisconnect];
            break;
        case Connected:
            [self doConnected];
            break;
    }
    [self set];
}


-(void)doDisconnect
{
    [super doDisconnect];
    [self close];
}

-(BOOL)wait
{
    NSError* error=[self wait:Timeout];
    if (error)
    {
        NSLog(@"error:%@",[error debugDescription]);
        return false;
    }
    return true;
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self set:error];
}

-(void)send:(NSData *)data Callback:(OperateCallback)cb
{
    if (!runThread)
    {
        cb([NSError errorWithDomain:@"BluetoothIO Closed" code:0 userInfo:nil]);
        return;
    }
    OperateData* op=[OperateData Operate:data Callback:cb];
    if ([[NSThread currentThread] isEqual:runThread])
    {
        [self postSend:op];
    }else
    {
        [self performSelector:@selector(postSend:) onThread:runThread withObject:op waitUntilDone:false];
    }
}

-(BOOL)send:(NSData*) data
{
    if (!runThread) return false;

    OperateData* op=[OperateData Operate:data Callback:nil];
    
    if ([[NSThread currentThread] isEqual:runThread])
    {
        return [self postSend:op];
    }else
    {
        [self performSelector:@selector(postSend:) onThread:runThread withObject:op waitUntilDone:true];
        return errorinfo==nil;
    }
}

-(BOOL)postSend:(OperateData*)data
{
    [self doSend:data.data];
    [peripheral writeValue:data.data forCharacteristic:input type:CBCharacteristicWriteWithResponse];
    NSError* error=[self wait:Timeout];
    if (data.callback)
    {
        data.callback(error);
    }
    return error==nil;
}
-(BOOL)runJob:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait
{
    if (runThread==NULL) return false;
    if (runThread.isCancelled) return false;
    [self performSelector:aSelector onThread:runThread withObject:arg waitUntilDone:wait];
    return true;
}
-(void)runThreadProc
{
    @autoreleasepool {
        self->loop=CFRunLoopGetCurrent();
        @try {
            @synchronized([BluetoothSynchronizedObject synchronizedObject]) {
                NSLog(@"start connect");
                [centralManager connectPeripheral:peripheral options:nil];
                if (![self wait])
                {
                    NSLog(@"connect timeout");
                    return;
                }
                
                [peripheral discoverServices:nil];
                if (![self wait])
                {
                    NSLog(@"discoverServices timeout");
                    return;
                }
                CBService* service=nil;
                //遍历服务，找到水杯的服务，然后开始查找Characteristic
                for (CBService* s in [peripheral services])
                {
                    if ([[[s UUID] UUIDString] isEqualToString:UUID_Service])
                    {
                        NSLog(@"didDiscoverServices:%@",[[s UUID] UUIDString]);
                        service=s;
                        break;
                    }
                }
                
                if (!service)
                {
                    NSLog(@"service is null");
                    return;
                }
                
                [peripheral discoverCharacteristics:nil forService:service];
                if (![self wait])
                {
                    NSLog(@"discoverCharacteristics timeout");
                    return;
                    
                }
                
                for (CBCharacteristic* characteristic in service.characteristics)
                {
                    if ([[[characteristic UUID] UUIDString] isEqualToString:UUID_CHAR_INPUT])
                    {
                        input=characteristic;
                    }
                    if ([[[characteristic UUID] UUIDString] isEqualToString:UUID_CHAR_OUTPUT])
                    {
                        output=characteristic;
                    }
                }
                if ((!input) || (!output))
                    return;
                NSLog(@"setNotifyValue");
                [peripheral setNotifyValue:YES forCharacteristic:output];
                if (![self wait]) return;
                [self doConnected];
            }

            if (![self doInit])
            {
                return;
            }
            
            NSLog(@"readly");
            [self doReady];
            
            while(![[NSThread currentThread] isCancelled])
            {
                CFRunLoopRun();
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception:%@",[exception debugDescription]);
        }
        @finally {
            NSLog(@"io close");
            [centralManager cancelPeripheralConnection:peripheral];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data=characteristic.value;
    if (data)
    {
        [self doRecv:data];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self set:error];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{

    [self set:error];
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self set:error];
}

-(void)open
{
    if (runThread) return;
    runThread=[[NSThread alloc]initWithTarget:self selector:@selector(runThreadProc) object:nil];
    [runThread start];
}

-(NSString *)description
{
    if (self.scanResponseData)
    {
        return [NSString stringWithFormat:@"respone:%@",[self.scanResponseData debugDescription]];
    }else
    {
        return @"";
    }
}
-(void)close
{
    [runThread cancel];
    runThread=NULL;
    NSLog(@"close");
}

@end
