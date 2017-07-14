//
//  HttpServer.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/23.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@class HttpServer;

@protocol onFTCfinishedDelegate <NSObject>
@required
-(void)onFTCfinished:(NSString *)json;
@end

@interface HttpServer : NSObject
{
    ushort _port;
    int _socket;
    NSThread* _mainThread;
    
}
-(instancetype) init:(ushort)port;
-(void)start;
-(void)close;
@property (nonatomic, weak) id<onFTCfinishedDelegate> delegate;

@end
