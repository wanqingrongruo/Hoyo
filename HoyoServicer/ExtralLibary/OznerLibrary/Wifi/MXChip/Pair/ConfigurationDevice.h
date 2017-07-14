//
//  ConfigurationDevice.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/27.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigurationDevice : NSObject
@property (copy)NSString* name;
@property (copy)NSString* type;
@property (readonly,nonatomic)BOOL activated;
@property (readonly,copy)NSString* deviceId;
@property (copy)NSString* login_id;
@property (copy)NSString* devPasswd;
@property (copy)NSString* ip;
@property (copy)NSString* mac;
+(instancetype)withJSON:(NSString*)json;

@end
