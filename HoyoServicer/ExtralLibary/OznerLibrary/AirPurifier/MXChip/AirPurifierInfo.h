//
//  AirPurifierInfo.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AIR_PURIFIER_ERROR 0xffff

@interface AirPurifierInfo : NSObject
{
     NSDictionary* propertys;
}
-(instancetype)init:(NSDictionary*)propertys;

@property (copy,readonly,getter=getModel)NSString* model;
@property (copy,readonly,getter=getType)NSString* type;
@property (copy,readonly,getter=getMainboard)NSString* mainboard;
@property (copy,readonly,getter=getControlboard)NSString* controlboard;


@end
