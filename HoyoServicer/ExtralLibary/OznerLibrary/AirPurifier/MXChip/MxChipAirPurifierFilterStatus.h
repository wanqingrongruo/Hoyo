//
//  FilterStatus.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MxChipAirPurifierFilterStatus : NSObject

@property (copy,readonly,nonatomic) NSDate* lastTime;
@property (copy,readonly,nonatomic) NSDate* stopTime;
@property (nonatomic,readonly) int workTime;
@property (nonatomic,readonly) int maxWorkTime;
-(instancetype)init:(NSData*)data;
-(NSData*)toBytes;
@end
