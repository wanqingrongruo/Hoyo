//
//  MQTTProxy.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/8.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTKit/MQTTKit.h"

#define MQTT_HOST @"api.easylink.io"
#define MQTT_PORT 1883
@class MQTTProxy;

@protocol MQTTProxyDelegate <NSObject>
-(void)MQTTProxyConnected:(MQTTProxy*)proxy;
-(void)MQTTProxyDisconnected:(MQTTProxy*)proxy;
@end
typedef void (^MQTTProxyOnPublishHandler)(NSString* topic,NSData* data);

@interface MQTTProxy : NSObject
{
    MQTTClient* mqtt;
    NSThread* runThread;
    NSRunLoop* runLoop;
    NSString* clientId;
    float waitTime;
    BOOL isQuit;
    NSMutableDictionary* onPublishList;
    int registerSeedId;
}
@property (readonly,nonatomic) BOOL connected;
@property (nonatomic, weak) id<MQTTProxyDelegate> delegate;

-(int)registerOnPublish:(MQTTProxyOnPublishHandler)onPublishHandler;
-(void)unregisterOnPublish:(int)registerId;
-(BOOL)subscribe:(NSString*)topic;
-(void)unsubscribe:(NSString*)topic;
-(BOOL)publish:(NSString*)topic Data:(NSData*)data;

@end
