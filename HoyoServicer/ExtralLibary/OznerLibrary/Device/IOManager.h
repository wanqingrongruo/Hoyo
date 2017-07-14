//
//  IOManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceIO.h"
@class IOManager;

@protocol IOManagerDelegate<NSObject>
@required
-(void)IOManager:(IOManager*)ioManager Available:(BaseDeviceIO*)io;
-(void)IOManager:(IOManager*)ioManager Unavailable:(BaseDeviceIO*)io;
@end

@interface IOManager : NSObject
{
@private
    NSMutableDictionary* devices;
    NSLock* locker;
}
@property (nonatomic, weak) id<IOManagerDelegate> delegate;
-(BaseDeviceIO*)getAvailableDevice:(NSString*)identifier;
-(NSArray*)getAvailableDevices;
-(void)closeAll;


/**---------------------------protected------------------------**/


@end
