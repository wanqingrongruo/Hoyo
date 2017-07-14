//
//  IOManagerList.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "IOManagerList.h"

@implementation IOManagerList
-(instancetype)init
{
    if (self=[super init])
    {
        _bluetooth=[[BluetoothIOMgr alloc] init];
        _mxchip=[[MXChipIOManager alloc] init];
    }
    return self;
}
-(BaseDeviceIO *)getAvailableDevice:(NSString *)identifier
{
    BaseDeviceIO* ret=NULL;
    ret=[_bluetooth getAvailableDevice:identifier];
    if (!ret)
        ret=[_mxchip getAvailableDevice:identifier];
    return ret;
}
-(NSArray *)getAvailableDevices
{
    NSMutableArray* array=[[NSMutableArray alloc] init];
    [array addObjectsFromArray:[_bluetooth getAvailableDevices]];
    [array addObjectsFromArray:[_mxchip getAvailableDevices]];
    return array;
}
-(void)closeAll
{
    [_bluetooth closeAll];
    [_mxchip closeAll];
}
@end
