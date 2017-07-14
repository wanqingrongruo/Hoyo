//
//  HttpServer.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/23.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "HttpServer.h"

@implementation HttpServer

-(instancetype) init:(ushort)port
{
    if (self=[super init])
    {
        self->_port=port;

    }
    return self;
}

-(void)close
{
   if (_mainThread)
   {
       [_mainThread cancel];
       close(_socket);
   }
}

#define BuffSize 65535
#define HeadSize 1024
-(void)clientThreadRun:(NSNumber*)object
{
    @autoreleasepool {
        int socket=[object intValue];
        @try {
            int timeout=10;
            setsockopt(socket,SOL_SOCKET, SO_RCVTIMEO,  &timeout, sizeof(timeout));
            setsockopt(socket,SOL_SOCKET, SO_SNDTIMEO,  &timeout, sizeof(timeout));
            char buf[BuffSize];
            memset(buf, 0, BuffSize);
            
            NSMutableData *content=[[NSMutableData alloc] init];
            ssize_t len=recv(socket, buf, HeadSize, 0);
            if (len<=0)
            {
                NSLog(@"recv null");
                return;
            }
            NSString* request= [[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding];
            NSArray* lines=[request componentsSeparatedByString:@"\r\n"];
            int contentSize=0;
            for (NSString* line in lines)
            {
                NSRange range=[line rangeOfString:@"Content-Length:"];
                if (range.location!=NSNotFound)
                {
                    NSString* size=[[line substringFromIndex:range.location+range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    contentSize=[size intValue];
                }
            }
            
            NSRange pos=[request rangeOfString:@"\r\n\r\n"];
            if ((contentSize<=0) || (pos.location==NSNotFound))
            {
                return;
            }
            int recvCount=(int)(len-(pos.location+pos.length));
            if (recvCount>0)
            {
                [content appendBytes:(buf+pos.location+pos.length) length:recvCount];
            }
            int nextCount=contentSize-recvCount;
            while (nextCount>0)
            {
                len=recv(socket, buf, MIN(BuffSize, nextCount), 0);
                if (len>0)
                {
                    [content appendBytes:buf length:len];
                }
                if (len<=0) break;
                nextCount-=len;
            }
            
            NSLog(@"next recv:%d",contentSize-recvCount);
            NSMutableString* ret=[[NSMutableString alloc] init];
            
            NSString* output=@"{}";
            [ret appendString:@"HTTP/1.1 200 OK\r\n"];
            [ret appendString:@"Connection: keep-alive\r\n"];
            [ret appendString:@"Content-Type: application/json\r\n"];
            [ret appendFormat:@"Content-Length:%d\r\n",(int)output.length];
            [ret appendString:@"\r\n\r\n"];
            [ret appendString:output];
            NSData* data=[ret dataUsingEncoding:NSASCIIStringEncoding];
            write(socket, [data bytes], data.length);
            if (self.delegate)
            {
                if (content.length>0)
                {
                    [self.delegate onFTCfinished:[[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding]];
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            close(socket);
        }
    }
}
-(void)mainThreadRun
{
    @autoreleasepool {
        self->_socket=socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        NSAssert(_socket!=-1, @"socket error");
        struct  sockaddr_in local;      // 定义监听地址以及端口
        int len=sizeof(struct sockaddr_in);
        
        local.sin_len = len;
        local.sin_family = AF_INET;
        local.sin_port =htons(_port);
        local.sin_addr.s_addr = htonl(INADDR_ANY);
        
        UInt32 optval = 1;
        if (setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, // 允许重用本地地址和端口
                (void *)&optval, sizeof(optval))<0)
        {
            NSLog(@"setsockopt error:%d",errno);
        }
        @try {
            if (bind(_socket, (const struct sockaddr *)&local, sizeof(local))<0)
            {
                NSLog(@"bind error:%d",errno);
            }
            if (listen(_socket, 16)<0)
            {
                NSLog(@"listen error:%d",errno);
            }
            
            while (!_mainThread.cancelled) {
                struct  sockaddr_in addr;
                socklen_t len=sizeof(addr);
                //memset(&addr, 0, size);
                //addr.sin_len=size;
                bzero(&addr, len);
                addr.sin_len=len;
                
                NSLog(@"socket:%d",_socket);
                int s=accept(_socket, (struct sockaddr *)&addr, &len);
                if (s!=-1)
                {
                    NSThread* thread=[[NSThread alloc] initWithTarget:self
                                                             selector:@selector(clientThreadRun:)
                                                               object:[[NSNumber alloc] initWithInt:s]];
                    [thread start];
                }else
                {
                    NSLog(@"socket error:%d",errno);
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"main:%@",[exception debugDescription]);
        }
        @finally {
            NSLog(@"http close");
        }
        
    }
}
-(void)start
{
    if (!_mainThread)
    {
        _mainThread=[[NSThread alloc] initWithTarget:self selector:@selector(mainThreadRun) object:NULL];
        [_mainThread start];
    }

    
}
@end
