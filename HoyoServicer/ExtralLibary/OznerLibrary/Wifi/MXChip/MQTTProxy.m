//
//  MQTTProxy.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/8.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "MQTTProxy.h"
#import "../../Helper/Helper.h"

@implementation MQTTProxy
#define defalutWaitTime 1

-(instancetype)init
{
    if (self=[super init])
    {
        clientId=[NSString stringWithFormat:@"v1-app-%@",[Helper rndString:12]];
        registerSeedId=0;
        onPublishList=[[NSMutableDictionary alloc] init];
        waitTime=defalutWaitTime;
        mqtt= [[MQTTClient alloc] initWithClientId:clientId];
        mqtt.port=MQTT_PORT;
        mqtt.username=@"admin";
        mqtt.password=@"admin";
        mqtt.keepAlive=60;
        mqtt.cleanSession=false;
        mqtt.reconnectDelay=10;
        //mqtt.username="
        __weak typeof(self) weakSelf = self;
        NSLog(@"start connect");
        [mqtt setDisconnectionHandler:^(NSUInteger code)
         {
             [weakSelf doDiconnected];
         }];
        
        [mqtt connectToHost:MQTT_HOST
                 completionHandler:^(NSUInteger code) {
                     switch (code) {
                         case ConnectionAccepted:
                             [self doConnected];
                             break;
                             
                         default:
                             NSLog(@"error:connect MQTT");
                             //[self doDiconnect];
                             break;
                     }
                 }];
        __strong typeof(self) strongSelf = self;
        [mqtt setMessageHandler:^(MQTTMessage *message) {
            
            NSArray* array=nil;
            @synchronized(strongSelf->onPublishList) {
                array=[NSArray arrayWithArray:[onPublishList allValues]];
            }
            
            for (MQTTProxyOnPublishHandler handler in array)
            {
                @try {
                    handler(message.topic,message.payload);
                }
                @catch (NSException *exception) {
                    
                }
            }
        }];

    }
    return self;
}



-(int)registerOnPublish:(MQTTProxyOnPublishHandler)onPublishHandler;
{
    @synchronized(onPublishList) {
        registerSeedId++;
        
        [onPublishList setObject:[onPublishHandler copy] forKey:[NSNumber numberWithUnsignedInteger:registerSeedId]];
        return registerSeedId;
    }
}

-(void)unregisterOnPublish:(int)registerId
{
    @synchronized(onPublishList) {
        [onPublishList removeObjectForKey:[NSNumber numberWithInt:registerId]];
    }
}

-(BOOL)subscribe:(NSString *)topic
{
    if (mqtt.connected)
    {
        [mqtt subscribe:topic withQos:AtLeastOnce completionHandler:nil];
        return true;
    }else
        return false;
}

-(void)unsubscribe:(NSString *)topic
{
    [mqtt unsubscribe:topic withCompletionHandler:nil];
}
-(BOOL)publish:(NSString*)topic Data:(NSData*)data
{
    if (mqtt.connected)
    {
        [mqtt publishData:data toTopic:topic withQos:AtMostOnce retain:false completionHandler:^(int mid) {
        }];
        return true;
    }else
        return false;
}



-(void)doConnected
{
    NSLog(@"mqtt connected");
    waitTime=defalutWaitTime;
    self->_connected=true;
    
    if ([self.delegate respondsToSelector:@selector(MQTTProxyConnected:)]) {
        
        [self.delegate MQTTProxyConnected:self];
        
    }
    
    
}
-(void)doDiconnected
{
    NSLog(@"mqtt connectionClosed");
    self->_connected=false;
    
    if ([self.delegate respondsToSelector:@selector(MQTTProxyDisconnected:)]) {
        
        [self.delegate MQTTProxyDisconnected:self];
        
    }
    
    
}

@end
