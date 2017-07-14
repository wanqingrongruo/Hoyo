//
//  MXChipIO.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/8.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "MXChipIO.h"
#import "../../Device/BaseDeviceIO.hpp"
#import "../../Helper/Helper.h"

@implementation MXChipIO
-(instancetype)init:(NSString *)identifier MQTT:(MQTTProxy*)Proxy Type:(NSString *)type
{
    if (self=[super init:identifier Type:type])
    {
        self->proxy=Proxy;
    }
    return self;
}

-(void)close
{
    if (runThread)
    {
        [runThread cancel];
        runThread=nil;
    }
 
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
        [self performSelector:@selector(postSend:) onThread:runThread withObject:op waitUntilDone:false];
        return errorinfo==nil;
    }
}

-(BOOL)postSend:(OperateData*)data
{
    [self doSend:data.data];
    if ([proxy publish:inKey Data:data.data])
    {
        if (data.callback)
            data.callback(nil);
        return true;
    }else
    {
        if (data.callback)
            data.callback([NSError errorWithDomain:@"MXChipIO send error" code:0 userInfo:nil]);
        return false;
    }
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
    int msgId=0;
    @try {
        if (!proxy.connected)
            return ;
        [self doConnecting];
        
        msgId=[proxy registerOnPublish:^(NSString *topic, NSData *data) {
            if (outKey)
            {
                if ([topic isEqualToString:outKey])
                    [self doRecv:data];
            }
        }];

        if (![proxy subscribe:outKey])
            return;
        [self doConnected];
        
        if (![self doInit])
            return;
        
        [self doReady];
        while (![[NSThread currentThread] isCancelled]) {
            [[NSRunLoop currentRunLoop] run];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",[exception debugDescription]);
    }
    @finally {
        [proxy unsubscribe:outKey];
        [self->proxy unregisterOnPublish:msgId];
        [self doDisconnect];
    }
}

-(void)doDisconnect
{
    [self.statusDelegate IOClosed:self];
    [super doDisconnect];
    
}

-(void)open
{
    if (StringIsNullOrEmpty(outKey))
    {
        @throw [NSException exceptionWithName:@"MXChioIO" reason:@"out IsNull" userInfo:nil];
    }
    if (runThread) return;
    runThread=[[NSThread alloc] initWithTarget:self selector:@selector(runThreadProc) object:nil];
    [runThread start];
}

-(void)setSecureCode:(NSString*)secureCode;
{
    self->inKey=[NSString stringWithFormat:@"%@/%@/in",secureCode,[[self.identifier stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString]];
    self->outKey=[NSString stringWithFormat:@"%@/%@/out",secureCode,[[self.identifier stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString]];
}


@end
