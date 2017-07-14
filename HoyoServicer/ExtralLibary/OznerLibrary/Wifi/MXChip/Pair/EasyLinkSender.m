//
//  EasyLinkSender.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/24.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "EasyLinkSender.h"

@implementation EasyLinkSender

- (NSString *)getWifiIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                NSLog(@"name:%@",[NSString stringWithUTF8String:temp_addr->ifa_name] );
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}


-(void) make_easylink_v3
{
    byte* ssid=(byte*)[ssid_data bytes];
    byte* passwd=(byte*)[password_data bytes];
    
//    String ipString = ((broadcatIp & 0xff) + "." + (broadcatIp >> 8 & 0xff) + "."
//                       + (broadcatIp >> 16 & 0xff) + "." + (broadcatIp >> 24 & 0xff));
//    this.address = InetAddress.getByName(ipString);
    
    
    short checksum = 0;
    int i = 1;
    self->send_data[0] = (byte) (3 + ssid_data.length + password_data.length + sizeof(user_info) + 2);
    
    send_data[i++] = (byte) ssid_data.length;
    send_data[i++] = (byte) password_data.length;
    
    int j;
    for (j = 0; j < ssid_data.length; ++i) {
        send_data[i] = ssid[j];
        ++j;
    }
    
    for (j = 0; j < password_data.length; ++i) {
        send_data[i] = passwd[j];
        ++j;
    }
    
    for (j = 0; j < sizeof(user_info); ++i) {
        send_data[i] = user_info[j];
        ++j;
    }
    
    for (j = 0; j < i; ++j) {
        checksum = (short) (checksum + (send_data[j] & 255));
    }
    
    send_data[i++] = (byte) ((checksum & (short)0xffff) >> 8);
    send_data[i++] = (byte) (checksum & 255);
}

//public boolean send_easylink_v3() {
//    try {
//        this.port = UDP_START_PORT;
//        int k = 0;
//        this.UDP_SEND(START_FLAG1);
//        this.UDP_SEND(START_FLAG2);
//        this.UDP_SEND(START_FLAG3);
//        int i = 0;
//        
//        for (int j = 1; i < send_data[0]; ++i) {
//            len = j * 256 + (send_data[i] & 255);
//            this.UDP_SEND(len);
//            if (i % 4 == 3) {
//                ++k;
//                len = 1280 + k;
//                this.UDP_SEND(len);
//            }
//            
//            ++j;
//            if (j == 5) {
//                j = 1;
//            }
//        }
//        return true;
//    } catch (Exception e) {
//        e.printStackTrace();
//        return false;
//    }
//    
//}
-(void)send_broadcat:(int)socket Length:(int)len
{
    struct sockaddr_in dstAdd;
    bzero(&dstAdd, sizeof(dstAdd));
    dstAdd.sin_family=AF_INET;
    dstAdd.sin_port=htons(UDP_START_PORT);
    dstAdd.sin_addr.s_addr=broadcatIp;
    dstAdd.sin_len=sizeof(dstAdd);
    ssize_t ret=sendto(socket,buffer,len,0,(struct sockaddr*)&dstAdd,sizeof(dstAdd));
    NSAssert(ret!=-1,@"sendto error:%d",errno);
    if (ret<0)
    {
        NSLog(@"send_broadcat_error:%d",errno);
    }
    [NSThread sleepForTimeInterval:0.02f];
}
static int port=10000;
-(void)send_multicast:(int)socket address:(NSString*)ip Data:(const void*) data Length:(uint)len
{
    struct sockaddr_in dstAdd;
    bzero(&dstAdd, sizeof(dstAdd));
    dstAdd.sin_len=sizeof(dstAdd);
    dstAdd.sin_family=AF_INET;
    dstAdd.sin_port=htons(port);
    port++;
    if (port>65523)
    {
        port=10000;
    }
    
    dstAdd.sin_addr.s_addr=inet_addr([[ip dataUsingEncoding:NSASCIIStringEncoding] bytes]);
    ssize_t ret=sendto(socket, data, len, 0, (struct sockaddr *)&dstAdd, sizeof(dstAdd));
    if (ret<0)
    {
        NSLog(@"send_multicast_error:%d",errno);
    }
    //NSLog(@"send_multicast:%d",(int)ret);
    [NSThread sleepForTimeInterval:0.03f];
}

-(void)send_easylink_v2
{
    NSString* head=@"239.118.0.0";
    NSString* syncHString = @"abcdefghijklmnopqrstuvw";
    NSData* syncHBuffer=[syncHString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableData* data=[[NSMutableData alloc] init];
    byte t=ssid_data.length;
    [data appendBytes:&t length:1];
    t=password_data.length;
    [data appendBytes:&t length:1];
    [data appendData:ssid_data];
    [data appendData:password_data];
    
    int s=socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    UInt32 opt = 1;
    if (setsockopt(s, SOL_SOCKET, SO_BROADCAST, (const void *)&opt, sizeof(opt))<0)
    {
        NSLog(@"setsockopt error:%d",errno); //设置广播
    }
    NSAssert(s!=-1, @"socket error:%d",errno);
    @try {
        for (int i=0;i<5;i++)
        {
            [self send_multicast:s address:head Data:[syncHBuffer bytes] Length:20];
        }
        if (data.length%2==0)
        {
            byte temp[2]={(byte)sizeof(user_info),0};
            [data appendBytes:temp length:sizeof(temp)];
            
        }else{
            byte temp[3]={0,(byte)sizeof(user_info),0};
            [data appendBytes:temp length:sizeof(temp)];
        }
        [data appendBytes:user_info length:sizeof(user_info)];
        for (int k=0;k<data.length;k+=2)
        {
            NSMutableString* ip=[NSMutableString stringWithString:@"239.126."];
            lpBytes bytes=(lpBytes)[data bytes];
            if (k + 1 < data.length)
                [ip appendFormat:@"%d.%d",bytes[k] & 0xff,bytes[k+1]&0xff];
            else
                [ip appendFormat:@"%d.%d",bytes[k] & 0xff,0];
            int len=k/2+20;
            byte bbbb[len];
            
            [self send_multicast:s address:ip Data:bbbb Length:len];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",[exception description]);
    }
    @finally {
        close(s);
    }
    
 
}
//public void send_easylink_v2() {
//    try {
//        String head = "239.118.0.0";
//        String ip;
//        String syncHString = "abcdefghijklmnopqrstuvw";
//        
//        InetSocketAddress sockAddr;
//        byte[] syncHBuffer = syncHString.getBytes();
//        byte[] data = new byte[2];
//        int userlength = user_info.length;
//        
//        if (userlength == 0) {
//            userlength++;
//            user_info = new byte[1];
//            user_info[0] = 0;
//        }
//        
//        data[0] = (byte) ssid.length;
//        data[1] = (byte) key.length;
//        byte[] temp = Helper.byteMerger(ssid, key);
//        data = Helper.byteMerger(data, temp);
//        
//        for (int i = 0; i < 5; i++) {
//            sockAddr = new InetSocketAddress(InetAddress.getByName(head),
//                                             getRandomNumber());
//            sendData(new DatagramPacket(syncHBuffer, 20, sockAddr), head);
//            Thread.sleep(10);
//        }
// {
//            if (data.length % 2 == 0) {
//                if (user_info.length == 0) {
//                    byte[] temp_length = {(byte) userlength, 0, 0};
//                    data = Helper.byteMerger(data, temp_length);
//                } else {
//                    byte[] temp_length = {(byte) userlength, 0};
//                    data = Helper.byteMerger(data, temp_length);
//                }
//            } else {
//                byte[] temp_length = {0, (byte) userlength, 0};
//                data = Helper.byteMerger(data, temp_length);
//            }
//            data = Helper.byteMerger(data, user_info);
//            for (int k = 0; k < data.length; k += 2) {
//                if (k + 1 < data.length)
//                    ip = "239.126." + (data[k] & 0xff) + "."
//                    + (data[k + 1] & 0xff);
//                else
//                    ip = "239.126." + (data[k] & 0xff) + ".0";
//                sockAddr = new InetSocketAddress(InetAddress.getByName(ip),
//                                                 getRandomNumber());
//                byte[] bbbb = new byte[k / 2 + 20];
//                sendData(new DatagramPacket(bbbb, k / 2 + 20, sockAddr), ip);
//                Thread.sleep(10);
//            }
//        }
//    } catch (Exception e) {
//        
//    }
//}
-(void)send_easylink_v3
{
    int s=socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    NSAssert(s!=-1, @"socket error:%d",errno);
    @try {
        
        UInt32 opt = 1;
        if (setsockopt(s, SOL_SOCKET, SO_BROADCAST, (const void *)&opt, sizeof(opt))<0)
        {
            NSLog(@"setsockopt error:%d",errno); //设置广播
        }
        opt=0;
        [self send_broadcat:s Length:START_FLAG1];
        [self send_broadcat:s Length:START_FLAG2];
        [self send_broadcat:s Length:START_FLAG3];
        for (int j = 1,i = 0,k = 0; i < send_data[0]; ++i) {
            int len = j * 256 + (send_data[i] & 255);
            [self send_broadcat:s Length:len];
            if (i % 4 == 3) {
                ++k;
                len = 1280 + k;
                [self send_broadcat:s Length:len];
            }
            ++j;
            if (j == 5) {
                j = 1;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",[exception description]);
    }
    @finally {
        close(s);
    }
}
-(instancetype)init:(NSString *)ssid Password:(NSString *)password
{
    if(self=[super init])
    {
        NSString* strIP = [self getWifiIPAddress];
        NSLog(@"local:%@",strIP);
        
        NSData* data=[strIP dataUsingEncoding:NSASCIIStringEncoding];
        void* ipBytes=malloc(16); //[data bytes] 返回的字符串可能有非0结尾的字符串，导致取ip错误，分配一个内存来，来吧data的数据复制进去，后面0结尾来修正
        memset(ipBytes, 0, 16);
        memcpy(ipBytes, [data bytes], data.length);
        in_addr_t ipAddress= inet_addr((const char*)ipBytes);
        free(ipBytes);
        //broadcatIp = 0xFF000000 | ipAddress;
        broadcatIp=0xFFFFFFFF;
        
        user_info[0]=0x23;
        user_info[1]=((lpBytes)&ipAddress)[3];
        user_info[2]=((lpBytes)&ipAddress)[2];
        user_info[3]=((lpBytes)&ipAddress)[1];
        user_info[4]=((lpBytes)&ipAddress)[0];
        
        //memcpy(&user_info[1], &ipAddress, sizeof(ipAddress));
        ssid_data=[ssid dataUsingEncoding:NSUTF8StringEncoding];
        password_data=[password dataUsingEncoding:NSUTF8StringEncoding];
        struct in_addr addr={broadcatIp};
        NSLog(@"broadcatIp:%s",inet_ntoa(addr));
        [self make_easylink_v3];
    }
    return self;
}
@end
