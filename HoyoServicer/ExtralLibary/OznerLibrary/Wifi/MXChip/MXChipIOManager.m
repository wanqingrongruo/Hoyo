//
//  MXChipIOManager.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/8.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "MXChipIOManager.h"

#import "../../Device/IOManager.hpp"
#import "../../OznerManager.h"
@implementation MXChipIOManager
-(instancetype)init
{
    if (self=[super init])
    {
        proxy=[[MQTTProxy alloc] init];
        proxy.delegate=self;
        listenDeviceList=[[NSMutableDictionary alloc] init];
    }
    return self;
}
-(MXChipIO*)newIO:(NSString *)identifier Type:(NSString*)type
{
    MXChipIO* io=[[MXChipIO alloc] init:identifier MQTT:proxy Type:type];
    io.statusDelegate=self;
    return io;
}
-(void)IOClosed:(MXChipIO *)io
{
    [self doUnavailable:io];
}

-(MXChipIO*)createMXChipIO:(NSString *)identifier Type:(NSString*)type;
{
    @synchronized(listenDeviceList) {
        if (![listenDeviceList objectForKey:identifier])
        {
            [listenDeviceList setObject:type forKey:identifier];
        }
    }
    if (proxy.connected)
    {
        MXChipIO* io=[self newIO:identifier Type:type];
        [self doAvailable:io];
        return io;
    }else
        return nil;
}
-(void)holdMQTT
{
    [self->proxy subscribe:@"16a21bd6/123456789012/out"];
}
-(void)MQTTProxyConnected:(MQTTProxy *)proxy
{
    @synchronized(listenDeviceList) {
        for (NSString* identifier in [listenDeviceList allKeys])
        {
            NSString* type=[listenDeviceList objectForKey:identifier];
            [self doAvailable:[self newIO:identifier Type:type]];
        }
    }
    [self performSelector:@selector(holdMQTT) withObject:NULL afterDelay:1];
}

-(void)MQTTProxyDisconnected:(MQTTProxy *)proxy
{
    @synchronized(listenDeviceList) {
        for (NSString* address in [listenDeviceList allKeys])
        {
            BaseDeviceIO* io=[self getAvailableDevice:address];
            if (io)
                [self doUnavailable:io];
        }
    }
}

-(void) delayedAvailable:(NSString*)identifier
{
    NSLog(@"delayedAvailable");
    if (![[OznerManager instance] hashDevice:identifier])
    {
        return;
    }
    @synchronized(listenDeviceList) {
        NSString* type=[listenDeviceList objectForKey:identifier];
        if (type)
        {
            [self doAvailable:[self newIO:identifier Type:type]];
        }
    }
}

-(void)doUnavailable:(BaseDeviceIO *)io
{
    [super doUnavailable:io];
    if (![[OznerManager instance] hashDevice:io.identifier])
    {
        @synchronized(listenDeviceList) {
            [listenDeviceList removeObjectForKey:io.identifier];
        }
    }else{
        if (proxy.connected)
        {
           [self performSelectorInBackground:@selector(delayedAvailable:) withObject:io.identifier]; //重新进io
        }
        
    }
}
@end
