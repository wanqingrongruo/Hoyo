//
//  MXChipPair.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/26.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
//#import "MyHTTPConnection.h"
#import "Pair/ConfigurationDevice.h"
#import "../MXChip/MXChipIO.h"
@protocol MxChipPairDelegate <NSObject>

/*!
 @function 开始发送Wifi信息
 */
-(void)mxChipPairSendConfiguration;

/*!
 @function 等待设备连接
 */
-(void)mxChipPairWaitConnectWifi;

/*!
 @function 等待设备激活
 */
-(void)mxChipPairActivate;

//配网完成
-(void)mxChipComplete:(MXChipIO*)io;

//配网失败
-(void)mxChipFailure;

@end

@interface MXChipPair : NSObject<onFTCfinishedDelegate,NSNetServiceBrowserDelegate,NSNetServiceDelegate>
{
    NSThread* runThread;
    ConfigurationDevice* device;
    NSString* ssid;
    NSString* password;
    NSMutableArray* services;
    dispatch_semaphore_t semaphore;
    NSNetServiceBrowser* serviceBrowser;
}
@property (nonatomic, weak) id<MxChipPairDelegate> delegate;

/*!
 @function getWifiSSID
 @discussion 获取当前连接Wifi的SSID
 @result 返回null说明当前没有连接wifi
 */
+(NSString*)getWifiSSID;

-(void) start:(NSString*)ssid Password:(NSString*)password;
-(BOOL)isRuning;
-(void)cancel;


@end
