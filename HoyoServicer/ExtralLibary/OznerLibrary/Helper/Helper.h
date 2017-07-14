//
//  Helper.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

bool StringIsNullOrEmpty(NSString* str);

@interface Helper : NSObject

+(NSString*)md5:(NSString*)str;
+(NSString*)rndString:(int)len;
+(uint8_t)Crc8:(uint8_t*) inBuffer inLen:(uint16_t)inLen;
+ (NSData *) stringToHexData:(NSString*)str;
@end
