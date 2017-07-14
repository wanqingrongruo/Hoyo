//
//  DeviceSetting.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/1.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceSetting : NSObject
{
    NSMutableDictionary * values;
}
@property (getter=getName,setter=setName:) NSString* name;
-(instancetype)init;
-(instancetype)initWithJSON:(NSString*)json;
-(id)get:(NSString*)key Default:(id)def;
-(void)put:(NSString*)key Value:(id)value;
-(NSString*)toJSON;
@end
