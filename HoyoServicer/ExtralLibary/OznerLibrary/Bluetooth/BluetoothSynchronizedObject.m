//
//  BluetoothSynchronizedObject.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "BluetoothSynchronizedObject.h"

@implementation BluetoothSynchronizedObject
NSObject* object=nil;
+(void)initSynchronizedObject
{
    object=[[NSObject alloc] init];
}

+(NSObject*)synchronizedObject
{
    return object;
}
@end
