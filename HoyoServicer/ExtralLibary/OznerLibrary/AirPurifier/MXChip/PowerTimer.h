//
//  PowerTimer.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#define  Monday  0x01
#define  Tuesday  0x02
#define  Wednesday  0x04
#define  Thursday  0x08
#define  Friday  0x10
#define  Saturday  0x20
#define  Sunday  0x40


@interface PowerTimer : NSObject
@property (nonatomic) BOOL enable;
@property (nonatomic) int powerOnTime;
@property (nonatomic) int powerOffTime;
@property (nonatomic) int week;
-(BOOL)loadByBytes:(NSData*)data;
-(BOOL)loadByJSON:(NSString*)json;
-(NSData*)toBytes;
-(NSString*)toJSON;
@end
