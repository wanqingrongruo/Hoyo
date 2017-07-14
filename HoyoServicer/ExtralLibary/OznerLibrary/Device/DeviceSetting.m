//
//  DeviceSetting.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "DeviceSetting.h"

@implementation DeviceSetting

-(instancetype)init
{
    if (self=[super init])
    {
        values=[[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype)initWithJSON:(NSString*)json
{
    if (self=[self init])
    {
        if (json)
        {
            NSData* data=[json dataUsingEncoding:NSUTF8StringEncoding];
            NSError* error;
            NSDictionary* dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error)
            {
                NSLog(@"error:%@",[error debugDescription]);
                
            }else{
                for (NSString* key in [dict allKeys]) {
                    [values setObject:[dict objectForKey:key] forKey:key];
                }
            }
        }
    }
    return self;
}

-(id)get:(NSString *)key Default:(id)def
{
    @synchronized(self) {
        id ret=[values objectForKey:key];
        if (ret==nil)
        {
            return def;
        }else
            return ret;
    }
}
-(void)put:(NSString *)key Value:(id)value
{
    @synchronized(self) {
        [values setObject:value forKey:key];
    }
}
-(NSString *)getName
{
    return [self get:@"name" Default:@""];
}
-(void)setName:(NSString *)name
{
    [self put:@"name" Value:[NSString stringWithString:name]];
}

-(NSString*)toJSON
{
    NSError* error;
    NSData* data=[NSJSONSerialization dataWithJSONObject:values options:kNilOptions error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
