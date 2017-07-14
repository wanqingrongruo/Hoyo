//
//  ConfigurationDevice.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/27.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "ConfigurationDevice.h"

@implementation ConfigurationDevice

+(id)getValue:(id)dict Name:(NSString*)name
{
    for (NSDictionary* list in dict) {
        if ([[list objectForKey:@"N"] isEqualToString:name])
        {
            return [list objectForKey:@"C"];
        }
    }
    return NULL;
}
+(instancetype)withJSON:(NSString*)json
{
    NSError *error;
    id object =[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (!error)
    {
        ConfigurationDevice* ret=[[ConfigurationDevice alloc] init];
        ret->_name=[NSString stringWithString:[object objectForKey:@"N"]];
        ret->_type=[[object objectForKey:@"FW"] stringByReplacingOccurrencesOfString:@"@" withString:@""];
        NSDictionary* cloudInfo=[ConfigurationDevice getValue:[object objectForKey:@"C"] Name:@"Cloud info"];
        if (cloudInfo)
        {
            ret->_activated=((NSNumber*)[ConfigurationDevice getValue:cloudInfo Name:@"activated"]).boolValue;
            id deviceId=[ConfigurationDevice getValue:cloudInfo Name:@"device_id"];
            ret->_deviceId=[NSString stringWithString: deviceId?deviceId:@""];
        }
        NSDictionary* cloudSettings=[ConfigurationDevice getValue:cloudInfo Name:@"Cloud settings"];
        if (cloudSettings)
        {
            NSDictionary* authentication=[ConfigurationDevice getValue:cloudSettings Name:@"Authentication"];
            ret->_login_id=[ConfigurationDevice getValue:authentication Name:@"login_id"];
            ret->_devPasswd=[ConfigurationDevice getValue:authentication Name:@"devPasswd"];
        }
        return ret;
    }else
        return NULL;
}

@end
