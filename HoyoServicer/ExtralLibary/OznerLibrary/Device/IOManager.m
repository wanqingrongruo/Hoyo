//
//  IOManager.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "IOManager.h"
#import "IOManager.hpp"


@implementation IOManager

-(instancetype)init
{
    if (self=[super init])
    {
        locker=[[NSLock alloc] init];
        devices=[[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void)doAvailable:(BaseDeviceIO*)io
{
    [locker lock];
    @try{
        [devices setObject:io forKey:io.identifier];
    }
    @finally{
        [locker unlock];
    }
    [self.delegate IOManager:self Available:io];
}

-(void)doUnavailable:(BaseDeviceIO*)io
{
    [locker lock];
    @try{
        [devices removeObjectForKey:io.identifier];
    }
    @finally{
        [locker unlock];
    }
    [self.delegate IOManager:self Unavailable:io];
}

-(NSArray*)getAvailableDevices
{
    [locker lock];
    @try {
        return [NSArray arrayWithArray:[devices allValues]];
    }
    @finally {
        [locker unlock];
    }
}

-(BaseDeviceIO*)getAvailableDevice:(NSString*)identifier;
{
    [locker lock];
    @try {
        return [devices objectForKey:identifier];
    }
    @finally {
        [locker unlock];
    }
}

-(void)closeAll
{
    NSArray* array;
    [locker lock];
    @try {
        array=[NSArray arrayWithArray:[devices allValues]];
    }
    @finally {
        [locker unlock];
    }
    for (BaseDeviceIO* io in array) {
        [io close];
    }

}
@end
