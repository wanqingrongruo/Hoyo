//
//  EasyLinkSender.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/24.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define START_FLAG1  0x5AA
#define START_FLAG2  0x5AB
#define START_FLAG3  0x5AC
#define UDP_START_PORT  50000
#define lpBytes Byte*
#define byte Byte
@interface EasyLinkSender : NSObject
{
    BOOL small_mtu;
    byte user_info[5];
    byte buffer[1500];
    in_addr_t broadcatIp;
    Byte send_data[128];
    NSData* ssid_data;
    NSData* password_data;
}
-(instancetype)init:(NSString*)ssid Password:(NSString*)password;
-(void)send_easylink_v3;
-(void)send_easylink_v2;

@end
