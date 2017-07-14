//
//  MXChipIOManager.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/8.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTProxy.h"
#import "MXChipIO.h"
#import "../../Device/IOManager.h"

@interface MXChipIOManager : IOManager<MQTTProxyDelegate,MXChipIOStatusDelegate>
{
    MQTTProxy* proxy;
    NSMutableDictionary* listenDeviceList;
}
-(MXChipIO*)createMXChipIO:(NSString *)identifier Type:(NSString*)type;

@end
